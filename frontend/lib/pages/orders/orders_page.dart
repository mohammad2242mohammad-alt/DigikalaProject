import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/price_formatter.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';

class OrdersPage extends ConsumerWidget {
  const OrdersPage({super.key});

  String _money(double value) => '${PriceFormatter.format(value)} تومان';

  String _statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'در انتظار پرداخت';
      case 'paid':
        return 'پرداخت شده';
      case 'processing':
        return 'در حال پردازش';
      case 'shipped':
        return 'ارسال شده';
      case 'delivered':
        return 'تحویل داده شده';
      case 'cancelled':
        return 'لغو شده';
      default:
        return status;
    }
  }

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
            onRefresh: () => ref.read(ordersProvider.notifier).refreshOrders(),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _OrderCard(
                order: items[index],
                money: _money,
                statusLabel: _statusLabel(items[index].status),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OrderCard extends ConsumerStatefulWidget {
  const _OrderCard({
    required this.order,
    required this.money,
    required this.statusLabel,
  });

  final OrderModel order;
  final String Function(double) money;
  final String statusLabel;

  @override
  ConsumerState<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends ConsumerState<_OrderCard> {
  bool _paying = false;

  Future<void> _pay() async {
    setState(() => _paying = true);
    try {
      await ref.read(ordersProvider.notifier).pay(widget.order.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('پرداخت با موفقیت انجام شد.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final canPay = order.status == 'pending';

    return Card(
      child: ExpansionTile(
        title: Text('سفارش #${order.id}'),
        subtitle: Text('${widget.statusLabel} • ${widget.money(order.total)}'),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          ...order.items.map(
            (item) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(item.productName),
              subtitle: Text('${item.quantity} عدد × ${widget.money(item.unitPrice)}'),
              trailing: Text(widget.money(item.totalPrice)),
            ),
          ),
          const Divider(),
          _Row(label: 'مبلغ کالاها', value: widget.money(order.subtotal)),
          _Row(label: 'هزینه ارسال', value: widget.money(order.shippingPrice)),
          _Row(label: 'تخفیف', value: widget.money(order.discountAmount)),
          _Row(label: 'مبلغ نهایی', value: widget.money(order.total)),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${order.province}، ${order.city}\n${order.address}',
              textAlign: TextAlign.right,
            ),
          ),
          if (canPay) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _paying ? null : _pay,
                icon: _paying
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.payment),
                label: Text(_paying ? 'در حال پرداخت...' : 'پرداخت سفارش'),
              ),
            ),
          ],
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
