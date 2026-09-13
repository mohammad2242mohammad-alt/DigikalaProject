import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/order_repository.dart';
import '../models/order_model.dart';
import 'product_provider.dart';

final orderRepositoryProvider = Provider<OrderRepository>(
  (ref) => OrderRepository(ref.watch(apiClientProvider)),
);

final ordersProvider = FutureProvider<List<OrderModel>>((ref) {
  return ref.watch(orderRepositoryProvider).getOrders();
});
