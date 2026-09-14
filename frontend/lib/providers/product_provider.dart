import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/product_repository.dart';
import '../models/product_model.dart';
import 'api_provider.dart';

export 'api_provider.dart';

final productRepositoryProvider = Provider<ProductRepository>(
  (ref) => ProductRepository(ref.watch(apiClientProvider)),
);

final productsProvider = FutureProvider<List<Product>>((ref) {
  return ref.watch(productRepositoryProvider).getProducts();
});

final productDetailProvider = FutureProvider.family<Product, int>((ref, id) {
  return ref.watch(productRepositoryProvider).getProduct(id);
});

class ProductSearchQuery {
  const ProductSearchQuery({
    this.search = '',
    this.categoryId,
    this.minPrice,
    this.maxPrice,
    this.sort = 'latest',
    this.perPage = 50,
  });

  final String search;
  final int? categoryId;
  final double? minPrice;
  final double? maxPrice;
  final String sort;
  final int perPage;

  @override
  bool operator ==(Object other) {
    return other is ProductSearchQuery &&
        other.search == search &&
        other.categoryId == categoryId &&
        other.minPrice == minPrice &&
        other.maxPrice == maxPrice &&
        other.sort == sort &&
        other.perPage == perPage;
  }

  @override
  int get hashCode => Object.hash(
        search,
        categoryId,
        minPrice,
        maxPrice,
        sort,
        perPage,
      );
}

final productSearchProvider = FutureProvider.family<List<Product>, ProductSearchQuery>(
  (ref, query) {
    return ref.watch(productRepositoryProvider).getProducts(
          search: query.search,
          categoryId: query.categoryId,
          minPrice: query.minPrice,
          maxPrice: query.maxPrice,
          sort: query.sort,
          perPage: query.perPage,
        );
  },
);
