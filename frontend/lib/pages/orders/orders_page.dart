import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/price_formatter.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';

class OrdersPage extends ConsumerWidget {
  const OrdersPage({super.key});

  String _money(double value) => '${PriceFormatter.format(value)} تومان';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(ordersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('سفارش‌های من')),
      body: orders.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('خطا: $error')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('هنوز سفارشی ثبت نشده است.'));
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(ordersProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _OrderCard(
                order: items[index],
                money: _money,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.money});

  final OrderModel order;
  final String Function(double) money;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Text('سفارش #${order.id}'),
        subtitle: Text('${order.status} • ${money(order.total)}'),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          ...order.items.map(
            (item) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(item.productName),
              subtitle: Text('${item.quantity} عدد × ${money(item.unitPrice)}'),
              trailing: Text(money(item.totalPrice)),
            ),
          ),
          const Divider(),
          _Row(label: 'مبلغ کالاها', value: money(order.subtotal)),
          _Row(label: 'هزینه ارسال', value: money(order.shippingPrice)),
          _Row(label: 'تخفیف', value: money(order.discountAmount)),
          _Row(label: 'مبلغ نهایی', value: money(order.total)),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${order.province}، ${order.city}\n${order.address}',
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text(value)],
      ),
    );
  }
}
