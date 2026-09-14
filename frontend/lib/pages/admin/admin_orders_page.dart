import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/order_model.dart';
import '../../providers/admin_provider.dart';

class AdminOrdersPage extends ConsumerWidget {
  const AdminOrdersPage({super.key});

  static const statuses = <String>[
    'pending',
    'paid',
    'processing',
    'shipped',
    'delivered',
    'cancelled',
  ];

  Future<void> _refresh(WidgetRef ref) async {
    await ref.read(adminOrdersProvider.notifier).refresh();
  }

  Future<void> _changeStatus(BuildContext context, WidgetRef ref, OrderModel order) async {
    final selected = await showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text('وضعیت سفارش #${order.id}'),
        children: statuses
            .map(
              (status) => SimpleDialogOption(
                onPressed: () => Navigator.pop(context, status),
                child: Row(
                  children: [
                    if (status == order.status) const Icon(Icons.check, size: 18),
                    if (status == order.status) const SizedBox(width: 8),
                    Text(_statusLabel(status)),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
    if (selected == null || selected == order.status || !context.mounted) return;
    try {
      await ref.read(adminOrdersProvider.notifier).updateStatus(order.id, selected);
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  String _statusLabel(String status) {
    const labels = {
      'pending': 'در انتظار پرداخت',
      'paid': 'پرداخت شده',
      'processing': 'در حال پردازش',
      'shipped': 'ارسال شده',
      'delivered': 'تحویل شده',
      'cancelled': 'لغو شده',
    };
    return labels[status] ?? status;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(adminOrdersProvider);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('مدیریت سفارش‌ها')),
        body: ordersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('خطا: $error')),
          data: (orders) {
            if (orders.isEmpty) return const Center(child: Text('سفارشی ثبت نشده است.'));
            return RefreshIndicator(
              onRefresh: () => _refresh(ref),
              child: ListView.builder(
                itemCount: orders.length,
                itemBuilder: (_, index) {
                  final order = orders[index];
                  return Card(
                    margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                    child: ExpansionTile(
                      title: Text('سفارش #${order.id}'),
                      subtitle: Text('${_statusLabel(order.status)} | ${order.total.toStringAsFixed(0)} تومان'),
                      trailing: IconButton(
                        tooltip: 'تغییر وضعیت',
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _changeStatus(context, ref, order),
                      ),
                      children: [
                        ...order.items.map(
                          (item) => ListTile(
                            dense: true,
                            title: Text(item.productName),
                            subtitle: Text('${item.quantity} × ${item.unitPrice.toStringAsFixed(0)} تومان'),
                            trailing: Text('${item.totalPrice.toStringAsFixed(0)} تومان'),
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          title: Text('${order.recipientName} - ${order.phone}'),
                          subtitle: Text('${order.province}، ${order.city}\n${order.address}'),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: FilledButton.icon(
                              onPressed: () => _changeStatus(context, ref, order),
                              icon: const Icon(Icons.sync),
                              label: Text('تغییر وضعیت: ${_statusLabel(order.status)}'),
                            ),
                          ),
                        ),
                      ],
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
