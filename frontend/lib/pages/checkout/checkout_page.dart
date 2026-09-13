import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/address_model.dart';
import '../../providers/address_provider.dart';
import '../../providers/order_provider.dart';
import '../orders/orders_page.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  AddressModel? _selectedAddress;
  bool _submitting = false;

  Future<void> _checkout() async {
    final address = _selectedAddress;
    if (address == null) return;

    setState(() => _submitting = true);
    try {
      final order = await ref.read(orderRepositoryProvider).checkout(
            addressId: address.id,
          );
      if (!mounted) return;
      final payment = await ref.read(orderRepositoryProvider).pay(order.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('پرداخت موفق بود: ${payment.status}')),
      );
      ref.invalidate(ordersProvider);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OrdersPage()),
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
      appBar: AppBar(title: const Text('تکمیل سفارش')),
      body: addresses.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('خطا: $error')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'هنوز آدرسی ثبت نشده است. ابتدا یک آدرس اضافه کنید.',
                  textAlign: TextAlign.center,
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
              const Text(
                'انتخاب آدرس ارسال',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...items.map(
                (address) => Card(
                  child: RadioListTile<int>(
                    value: address.id,
                    groupValue: _selectedAddress?.id,
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _selectedAddress = items.firstWhere(
                          (item) => item.id == value,
                        );
                      });
                    },
                    title: Text(address.title?.isNotEmpty == true
                        ? address.title!
                        : address.city),
                    subtitle: Text(
                      '${address.recipientName} - ${address.phone}\n${address.province}، ${address.city}\n${address.address}\nکدپستی: ${address.postalCode}',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _submitting ? null : _checkout,
                icon: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.payment),
                label: Text(_submitting ? 'در حال ثبت سفارش...' : 'ثبت سفارش و پرداخت'),
              ),
            ],
          );
        },
      ),
    );
  }
}
