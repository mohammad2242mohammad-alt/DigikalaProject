import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/admin_repository.dart';
import '../../models/order_model.dart';

class AdminOrdersPage extends ConsumerStatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  ConsumerState<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends ConsumerState<AdminOrdersPage> {
  late Future<List<OrderModel>> _future;

  static const statuses = <String>[
    'pending',
    'paid',
    'processing',
    'shipped',
    'delivered',
    'cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _future = ref.read(adminRepositoryProvider).getOrders();
  }

  Future<void> _refresh() async {
    setState(() => _future = ref.read(adminRepositoryProvider).getOrders());
    await _future;
  }

  Future<void> _changeStatus(OrderModel order) async {
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
    if (selected == null || selected == order.status || !mounted) return;
    try {
      await ref.read(adminRepositoryProvider).updateOrderStatus(order.id, selected);
      await _refresh();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
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
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('مدیریت سفارش‌ها')),
        body: FutureBuilder<List<OrderModel>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) return Center(child: Text('خطا: ${snapshot.error}'));
            final orders = snapshot.data ?? const <OrderModel>[];
            if (orders.isEmpty) return const Center(child: Text('سفارشی ثبت نشده است.'));
            return RefreshIndicator(
              onRefresh: _refresh,
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
                        onPressed: () => _changeStatus(order),
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
                              onPressed: () => _changeStatus(order),
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
