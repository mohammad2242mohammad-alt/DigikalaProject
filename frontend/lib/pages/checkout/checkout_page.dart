import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/address_model.dart';
import '../../providers/address_provider.dart';
import '../../providers/order_provider.dart';
import '../address/address_page.dart';
import '../orders/orders_page.dart';
import '../../core/widgets/store_app_bar.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  AddressModel? _selectedAddress;
  bool _submitting = false;

  Future<void> _openAddresses() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddressPage()),
    );
    if (!mounted) return;
    setState(() => _selectedAddress = null);
    ref.invalidate(addressesProvider);
  }

  Future<void> _checkout() async {
    final address = _selectedAddress;
    if (address == null) return;

    setState(() => _submitting = true);
    try {
      await ref.read(ordersProvider.notifier).checkout(addressId: address.id);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OrdersPage()),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('سفارش ثبت شد. برای نهایی شدن، پرداخت را انجام دهید.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final addresses = ref.watch(addressesProvider);

    return Scaffold(
      appBar: const StoreAppBar(title: 'تکمیل سفارش'),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: addresses.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('خطا: $error')),
          data: (items) {
            if (items.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_off_outlined, size: 56),
                      const SizedBox(height: 16),
                      const Text('هنوز آدرسی ثبت نشده است. ابتدا یک آدرس اضافه کنید.', textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _openAddresses,
                        icon: const Icon(Icons.add_location_alt_outlined),
                        label: const Text('افزودن آدرس'),
                      ),
                    ],
                  ),
                ),
              );
            }

            _selectedAddress ??= items.firstWhere(
              (item) => item.isDefault,
              orElse: () => items.first,
            );

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text('انتخاب آدرس ارسال', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                    TextButton.icon(
                      onPressed: _openAddresses,
                      icon: const Icon(Icons.edit_location_alt_outlined),
                      label: const Text('مدیریت آدرس‌ها'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...items.map(
                  (address) => Card(
                    child: RadioListTile<int>(
                      value: address.id,
                      groupValue: _selectedAddress?.id,
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _selectedAddress = items.firstWhere((item) => item.id == value));
                      },
                      title: Text(address.title?.isNotEmpty == true ? address.title! : address.city),
                      subtitle: Text('${address.recipientName} - ${address.phone}\n${address.province}، ${address.city}\n${address.address}\nکدپستی: ${address.postalCode}'),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _submitting ? null : _checkout,
                  icon: _submitting
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.arrow_forward),
                  label: Text(_submitting ? 'در حال ثبت سفارش...' : 'ثبت سفارش'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
