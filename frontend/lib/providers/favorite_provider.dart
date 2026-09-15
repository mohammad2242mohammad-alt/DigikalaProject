import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/favorite_repository.dart';
import '../models/product_model.dart';
import 'api_provider.dart';

final favoriteRepositoryProvider = Provider<FavoriteRepository>(
  (ref) => FavoriteRepository(ref.watch(apiClientProvider)),
);

final favoritesProvider = AsyncNotifierProvider<FavoriteNotifier, List<Product>>(
  FavoriteNotifier.new,
);

class FavoriteNotifier extends AsyncNotifier<List<Product>> {
  FavoriteRepository get _repository => ref.read(favoriteRepositoryProvider);

  @override
  Future<List<Product>> build() => _repository.getFavorites();

  Future<void> add(int productId) async {
    await _repository.add(productId);
    ref.invalidateSelf();
  }

  Future<void> remove(int productId) async {
    await _repository.remove(productId);
    ref.invalidateSelf();
  }
}
