import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/cart_repository.dart';
import '../models/cart_model.dart';
import 'product_provider.dart';

final cartRepositoryProvider = Provider<CartRepository>(
  (ref) => CartRepository(ref.watch(apiClientProvider)),
);

final cartProvider = AsyncNotifierProvider<CartNotifier, CartModel>(
  CartNotifier.new,
);

class CartNotifier extends AsyncNotifier<CartModel> {
  CartRepository get _repository => ref.read(cartRepositoryProvider);

  @override
  Future<CartModel> build() => _repository.getCart();

  Future<void> addItem({required int productId, int quantity = 1}) async {
    await _run(() => _repository.addItem(productId: productId, quantity: quantity));
  }

  Future<void> updateItem({required int itemId, required int quantity}) async {
    await _run(() => _repository.updateItem(itemId: itemId, quantity: quantity));
  }

  Future<void> removeItem(int itemId) async {
    await _run(() => _repository.removeItem(itemId));
  }

  Future<void> clear() async {
    await _run(_repository.clear);
  }

  Future<void> refreshCart() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.getCart);
  }

  Future<void> _run(Future<CartModel> Function() operation) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(operation);
  }
}
