import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/product.dart';
import '../../providers/admin_provider.dart';

class AdminProductsPage extends ConsumerWidget {
  const AdminProductsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(adminProductsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('مدیریت محصولات'),
        actions: [
          IconButton(
            onPressed: () => ref.read(adminProductsProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showDialog<void>(
            context: context,
            builder: (_) => const _ProductDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: products.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
        data: (items) => ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final product = items[index];
            return ListTile(
              title: Text(product.name),
              subtitle: Text('${product.price}'),
              onTap: () async {
                await showDialog<void>(
                  context: context,
                  builder: (_) => _ProductDialog(product: product),
                );
              },
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () async {
                  await ref.read(adminProductsProvider.notifier).delete(product.id);
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
  const _ProductDialog({this.product});

  final Product? product;

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
    final product = widget.product;
    _name = TextEditingController(text: product?.name ?? '');
    _description = TextEditingController(text: product?.description ?? '');
    _price = TextEditingController(text: product?.price.toString() ?? '');
    _discount = TextEditingController(text: product?.discountPrice?.toString() ?? '');
    _image = TextEditingController(text: product?.image ?? '');
    _stock = TextEditingController(text: product?.stock.toString() ?? '0');
    _categoryId = product?.categoryId;
    _active = product?.isActive ?? true;
  }

  @override
  void dispose() {
    for (final c in [_name, _description, _price, _discount, _image, _stock]) {
      c.dispose();
    }
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
      final notifier = ref.read(adminProductsProvider.notifier);
      if (widget.product == null) {
        await notifier.create(data);
      } else {
        await notifier.saveProduct(widget.product!.id, data);
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
                TextFormField(controller: _description, decoration: const InputDecoration(labelText: 'توضیحات')),
                TextFormField(controller: _price, decoration: const InputDecoration(labelText: 'قیمت'), keyboardType: TextInputType.number, validator: _required),
                TextFormField(controller: _discount, decoration: const InputDecoration(labelText: 'قیمت تخفیف')),
                TextFormField(controller: _image, decoration: const InputDecoration(labelText: 'تصویر')),
                TextFormField(controller: _stock, decoration: const InputDecoration(labelText: 'موجودی'), keyboardType: TextInputType.number, validator: _required),
                SwitchListTile(value: _active, onChanged: (value) => setState(() => _active = value), title: const Text('فعال')),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.pop(context), child: const Text('انصراف')),
        FilledButton(onPressed: _saving ? null : _save, child: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('ذخیره')),
      ],
    );
  }
}
