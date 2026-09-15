import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../models/product_model.dart';
import '../../providers/api_provider.dart';
import '../../providers/auth_provider.dart';
import '../../data/repositories/seller_repository.dart';

final sellerRepositoryProvider = Provider<SellerRepository>(
  (ref) => SellerRepository(ref.watch(apiClientProvider)),
);

class SellerPanelPage extends ConsumerStatefulWidget {
  const SellerPanelPage({super.key});

  @override
  ConsumerState<SellerPanelPage> createState() => _SellerPanelPageState();
}

class _SellerPanelPageState extends ConsumerState<SellerPanelPage> {
  final _storeNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _loading = false;
  Map<String, dynamic>? _profile;
  List<Product> _products = const [];
  String? _error;

  @override
  void dispose() {
    _storeNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadSellerData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repository = ref.read(sellerRepositoryProvider);
      _profile = await repository.getProfile();
      if (_profile?['status'] == 'approved') {
        _products = await repository.getProducts();
      }
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'خطا در دریافت اطلاعات فروشنده';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _apply() async {
    final storeName = _storeNameController.text.trim();
    if (storeName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('نام فروشگاه را وارد کنید')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await ref.read(sellerRepositoryProvider).apply(
            storeName: storeName,
            description: _descriptionController.text,
          );
      ref.invalidate(authProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('درخواست فروشندگی ثبت شد و منتظر تأیید است')),
        );
        await _loadSellerData();
      }
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).valueOrNull;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('برای ورود به پنل فروشنده وارد شوید')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('پنل فروشنده')),
      body: RefreshIndicator(
        onRefresh: _loadSellerData,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (_error != null)
              Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(_error!))),
            if (_profile == null && user.role != 'seller') _buildApplication(),
            if (_profile == null && user.role == 'seller') ...[
              const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
              if (!_loading) Center(child: FilledButton(onPressed: _loadSellerData, child: const Text('دریافت اطلاعات'))),
            ],
            if (_profile != null) _buildSellerContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildApplication() => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('درخواست فروشندگی', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('فروشگاه خودت را بساز و بعد از تأیید ادمین محصول اضافه کن.'),
              const SizedBox(height: 20),
              TextField(controller: _storeNameController, decoration: const InputDecoration(labelText: 'نام فروشگاه', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: _descriptionController, maxLines: 4, decoration: const InputDecoration(labelText: 'توضیحات فروشگاه', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              FilledButton(onPressed: _loading ? null : _apply, child: _loading ? const CircularProgressIndicator() : const Text('ثبت درخواست فروشندگی')),
            ],
          ),
        ),
      );

  Widget _buildSellerContent() {
    final status = _profile?['status']?.toString() ?? 'pending';
    final statusText = switch (status) {
      'approved' => 'تأیید شده',
      'rejected' => 'رد شده',
      'suspended' => 'تعلیق شده',
      _ => 'در انتظار تأیید',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: ListTile(
            title: Text(_profile?['store_name']?.toString() ?? 'فروشگاه'),
            subtitle: Text('وضعیت: $statusText'),
            leading: const CircleAvatar(child: Icon(Icons.storefront)),
          ),
        ),
        const SizedBox(height: 16),
        if (status == 'rejected' && _profile?['rejection_reason'] != null)
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Text('دلیل رد: ${_profile!['rejection_reason']}'))),
        if (status == 'approved') ...[
          Row(
            children: [
              Expanded(child: _statCard('محصولات', '${_products.length}', Icons.inventory_2_outlined)),
              const SizedBox(width: 12),
              Expanded(child: _statCard('موجودی', '${_products.fold<int>(0, (sum, p) => sum + p.stock)}', Icons.warehouse_outlined)),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(onPressed: () => _showProductForm(context), icon: const Icon(Icons.add), label: const Text('افزودن محصول')),
          const SizedBox(height: 12),
          const Text('محصولات من', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._products.map(_productTile),
        ] else
          const Card(child: Padding(padding: EdgeInsets.all(20), child: Text('پس از تأیید فروشگاه، امکان افزودن و مدیریت محصول فعال می‌شود.'))),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [Icon(icon, size: 30), const SizedBox(height: 8), Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), Text(title)])));

  Widget _productTile(Product product) => Card(
        child: ListTile(
          title: Text(product.name),
          subtitle: Text('موجودی: ${product.stock}  |  ${product.effectivePrice.toStringAsFixed(0)} تومان'),
          trailing: Icon(product.isActive ? Icons.check_circle : Icons.hourglass_top),
        ),
      );

  Future<void> _showProductForm(BuildContext context) async {
    final name = TextEditingController();
    final description = TextEditingController();
    final price = TextEditingController();
    final stock = TextEditingController(text: '1');
    final formKey = GlobalKey<FormState>();
    final created = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('افزودن محصول'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(children: [
              TextFormField(controller: name, decoration: const InputDecoration(labelText: 'نام محصول'), validator: (v) => v!.trim().isEmpty ? 'نام محصول الزامی است' : null),
              TextFormField(controller: description, decoration: const InputDecoration(labelText: 'توضیحات')),
              TextFormField(controller: price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'قیمت'), validator: (v) => double.tryParse(v ?? '') == null ? 'قیمت نامعتبر است' : null),
              TextFormField(controller: stock, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'موجودی'), validator: (v) => int.tryParse(v ?? '') == null ? 'موجودی نامعتبر است' : null),
            ]),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('انصراف')),
          FilledButton(onPressed: () async {
            if (!formKey.currentState!.validate()) return;
            try {
              await ref.read(sellerRepositoryProvider).createProduct(
                    name: name.text,
                    description: description.text,
                    price: double.parse(price.text),
                    stock: int.parse(stock.text),
                  );
              if (context.mounted) Navigator.pop(context, true);
            } on ApiException catch (e) {
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
            }
          }, child: const Text('ثبت')),
        ],
      ),
    );
    name.dispose();
    description.dispose();
    price.dispose();
    stock.dispose();
    if (created == true) await _loadSellerData();
  }
}
