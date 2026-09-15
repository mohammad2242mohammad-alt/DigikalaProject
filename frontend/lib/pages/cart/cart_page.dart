import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/price_formatter.dart';
import '../../models/cart_model.dart';
import '../../providers/cart_provider.dart';
import '../checkout/checkout_page.dart';
import '../../core/widgets/store_app_bar.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  String _money(double value) => '${PriceFormatter.format(value)} تومان';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(cartProvider);

    return Scaffold(
      appBar: const StoreAppBar(title: 'سبد خرید'),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: cartAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('دریافت سبد خرید ناموفق بود'),
                  const SizedBox(height: 8),
                  Text('$error', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => ref.read(cartProvider.notifier).refreshCart(),
                    child: const Text('تلاش دوباره'),
                  ),
                ],
              ),
            ),
          ),
          data: (cart) {
            if (cart.items.isEmpty) {
              return const Center(
                child: Text('سبد خرید خالی است', style: TextStyle(fontSize: 20)),
              );
            }

            return RefreshIndicator(
              onRefresh: () => ref.read(cartProvider.notifier).refreshCart(),
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  ...cart.items.map((item) => _CartItemTile(item: item, money: _money)),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('جمع سبد خرید', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(_money(cart.subtotal), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CheckoutPage()),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart_checkout),
                    label: const Text('ادامه و تکمیل سفارش'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _confirmClear(context, ref),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('خالی کردن سبد'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('خالی کردن سبد'),
        content: const Text('همه کالاهای سبد خرید حذف شوند؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('انصراف')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف همه')),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(cartProvider.notifier).clear();
    }
  }
}

class _CartItemTile extends ConsumerWidget {
  const _CartItemTile({required this.item, required this.money});

  final CartItemModel item;
  final String Function(double) money;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(cartProvider.notifier);
    final imageUrl = item.product.image;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          textDirection: TextDirection.ltr,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 72,
                height: 72,
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.image_not_supported_outlined,
                          size: 34,
                        ),
                      )
                    : const Icon(Icons.image_outlined, size: 34),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.product.name, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Text(money(item.unitPrice)),
                    const SizedBox(height: 8),
                    Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: item.quantity >= item.product.stock
                              ? null
                              : () => notifier.updateItem(itemId: item.id, quantity: item.quantity + 1),
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                        Text('${item.quantity}'),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: item.quantity <= 1
                              ? () => notifier.removeItem(item.id)
                              : () => notifier.updateItem(itemId: item.id, quantity: item.quantity - 1),
                          icon: Icon(item.quantity <= 1 ? Icons.delete_outline : Icons.remove_circle_outline),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                money(item.totalPrice),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
