import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/product_repository.dart';
import '../models/product_model.dart';
import 'api_provider.dart';

final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => ProductRepository(ref.watch(apiClientProvider)),
);

final productsProvider = FutureProvider<List<Product>>((ref) {
  return ref.watch(productRepositoryProvider).getProducts();
});
