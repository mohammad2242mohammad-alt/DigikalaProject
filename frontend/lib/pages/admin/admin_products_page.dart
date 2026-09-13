import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/admin_repository.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../core/network/api_client.dart';

final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => AdminRepository(ref.watch(apiClientProvider)),
);

class AdminProductsPage extends ConsumerStatefulWidget {
  const AdminProductsPage({super.key});

  @override
  ConsumerState<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends ConsumerState<AdminProductsPage> {
  late Future<List<Product>> _productsFuture;
  List<CategoryModel> _categories = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _productsFuture = ref.read(adminRepositoryProvider).getProducts();
    ref.read(adminRepositoryProvider).getCategories().then((value) {
      if (mounted) setState(() => _categories = value);
    });
  }

  Future<void> _refresh() async {
    setState(_load);
    await _productsFuture;
  }

  Future<void> _edit([Product? product]) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _ProductDialog(product: product, categories: _categories),
    );
    if (result == true) await _refresh();
  }

  Future<void> _delete(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف محصول'),
        content: Text('محصول «${product.name}» حذف شود؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('لغو')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await ref.read(adminRepositoryProvider).deleteProduct(product.id);
      await _refresh();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('مدیریت محصولات')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _edit(),
          icon: const Icon(Icons.add),
          label: const Text('محصول جدید'),
        ),
        body: FutureBuilder<List<Product>>(
          future: _productsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('خطا: ${snapshot.error}'));
            }
            final products = snapshot.data ?? const <Product>[];
            if (products.isEmpty) return const Center(child: Text('محصولی ثبت نشده است.'));
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 90),
                itemCount: products.length,
                itemBuilder: (_, index) {
                  final product = products[index];
                  return Card(
                    margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                    child: ListTile(
                      leading: product.image?.isNotEmpty == true
                          ? Image.network(product.image!, width: 55, height: 55, fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported))
                          : const Icon(Icons.image_outlined, size: 42),
                      title: Text(product.name),
                      subtitle: Text(
                        'قیمت: ${product.effectivePrice.toStringAsFixed(0)} تومان\n'
                        'موجودی: ${product.stock} | ${product.isActive ? 'فعال' : 'غیرفعال'}',
                      ),
                      isThreeLine: true,
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') _edit(product);
                          if (value == 'delete') _delete(product);
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'edit', child: Text('ویرایش')),
                          PopupMenuItem(value: 'delete', child: Text('حذف')),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProductDialog extends ConsumerStatefulWidget {
  const _ProductDialog({this.product, required this.categories});

  final Product? product;
  final List<CategoryModel> categories;

  @override
  ConsumerState<_ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends ConsumerState<_ProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _price;
  late final TextEditingController _discount;
  late final TextEditingController _image;
  late final TextEditingController _stock;
  int? _categoryId;
  bool _active = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = TextEditingController(text: p?.name ?? '');
    _description = TextEditingController(text: p?.description ?? '');
    _price = TextEditingController(text: p?.price.toStringAsFixed(0) ?? '');
    _discount = TextEditingController(text: p?.discountPrice?.toStringAsFixed(0) ?? '');
    _image = TextEditingController(text: p?.image ?? '');
    _stock = TextEditingController(text: p?.stock.toString() ?? '0');
    _categoryId = p?.categoryId;
    _active = p?.isActive ?? true;
  }

  @override
  void dispose() {
    for (final c in [_name, _description, _price, _discount, _image, _stock]) c.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final data = <String, dynamic>{
        'category_id': _categoryId,
        'name': _name.text.trim(),
        'description': _description.text.trim().isEmpty ? null : _description.text.trim(),
        'price': double.parse(_price.text.trim()),
        'discount_price': _discount.text.trim().isEmpty ? null : double.parse(_discount.text.trim()),
        'image': _image.text.trim().isEmpty ? null : _image.text.trim(),
        'stock': int.parse(_stock.text.trim()),
        'is_active': _active,
      };
      final repo = ref.read(adminRepositoryProvider);
      if (widget.product == null) {
        await repo.createProduct(data);
      } else {
        await repo.updateProduct(widget.product!.id, data);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _required(String? value) => value == null || value.trim().isEmpty ? 'این فیلد الزامی است' : null;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product == null ? 'محصول جدید' : 'ویرایش محصول'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'نام'), validator: _required),
                TextFormField(controller: _description, decoration: const InputDecoration(labelText: 'توضیحات'), maxLines: 3),
                DropdownButtonFormField<int?>(
                  initialValue: _categoryId,
                  decoration: const InputDecoration(labelText: 'دسته‌بندی'),
                  items: [
                    const DropdownMenuItem<int?>(value: null, child: Text('بدون دسته')),
                    ...widget.categories.map((c) => DropdownMenuItem<int?>(value: c.id, child: Text(c.name))),
                  ],
                  onChanged: (value) => setState(() => _categoryId = value),
                ),
                TextFormField(controller: _price, decoration: const InputDecoration(labelText: 'قیمت'), keyboardType: TextInputType.number, validator: _required),
                TextFormField(controller: _discount, decoration: const InputDecoration(labelText: 'قیمت تخفیف'), keyboardType: TextInputType.number),
                TextFormField(controller: _stock, decoration: const InputDecoration(labelText: 'موجودی'), keyboardType: TextInputType.number, validator: _required),
                TextFormField(controller: _image, decoration: const InputDecoration(labelText: 'آدرس تصویر'), keyboardType: TextInputType.url),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('محصول فعال باشد'),
                  value: _active,
                  onChanged: (value) => setState(() => _active = value),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.pop(context), child: const Text('لغو')),
        FilledButton.icon(
          onPressed: _saving ? null : _save,
          icon: _saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save),
          label: const Text('ذخیره'),
        ),
      ],
    );
  }
}
