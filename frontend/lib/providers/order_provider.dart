import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/order_repository.dart';
import '../models/order_model.dart';
import 'api_provider.dart';

final orderRepositoryProvider = Provider<OrderRepository>(
  (ref) => OrderRepository(ref.watch(apiClientProvider)),
);

final ordersProvider = AsyncNotifierProvider<OrderNotifier, List<OrderModel>>(
  OrderNotifier.new,
);

class OrderNotifier extends AsyncNotifier<List<OrderModel>> {
  OrderRepository get _repository => ref.read(orderRepositoryProvider);

  @override
  Future<List<OrderModel>> build() => _repository.getOrders();

  Future<OrderModel> checkout({required int addressId}) async {
    return _run(() async {
      final order = await _repository.checkout(addressId: addressId);
      await _reload();
      return order;
    });
  }

  Future<PaymentModel> pay(int orderId) async {
    return _run(() async {
      final payment = await _repository.pay(orderId);
      await _reload();
      return payment;
    });
  }

  Future<void> refreshOrders() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.getOrders);
  }

  Future<T> _run<T>(Future<T> Function() operation) async {
    final previous = state.valueOrNull;
    state = const AsyncLoading();
    try {
      final result = await operation();
      return result;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    } finally {
      if (previous != null && state.hasError) {
        // Keep the error state so the UI can show the real operation failure.
      }
    }
  }

  Future<void> _reload() async {
    state = await AsyncValue.guard(_repository.getOrders);
  }
}
