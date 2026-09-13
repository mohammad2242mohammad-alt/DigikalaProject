import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/cart_repository.dart';
import '../models/cart_model.dart';
import 'product_provider.dart';

final cartRepositoryProvider = Provider<CartRepository>(
  (ref) => CartRepository(ref.watch(apiClientProvider)),
);

final cartProvider = FutureProvider<CartModel>((ref) {
  return ref.watch(cartRepositoryProvider).getCart();
});
