import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/admin_repository.dart';
import '../models/category_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import 'api_provider.dart';

final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => AdminRepository(ref.watch(apiClientProvider)),
);

final adminProductsProvider =
    AsyncNotifierProvider<AdminProductsNotifier, List<Product>>(
  AdminProductsNotifier.new,
);

class AdminProductsNotifier extends AsyncNotifier<List<Product>> {
  AdminRepository get _repository => ref.read(adminRepositoryProvider);

  @override
  Future<List<Product>> build() => _repository.getProducts();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.getProducts);
  }

  Future<void> create(Map<String, dynamic> data) async {
    await _run(() => _repository.createProduct(data));
  }

  Future<void> saveProduct(int id, Map<String, dynamic> data) async {
    await _run(() => _repository.updateProduct(id, data));
  }

  Future<void> delete(int id) async {
    await _run(() => _repository.deleteProduct(id));
  }

  Future<void> _run(Future<dynamic> Function() operation) async {
    state = const AsyncLoading();
    try {
      await operation();
      state = await AsyncValue.guard(_repository.getProducts);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final adminCategoriesProvider =
    AsyncNotifierProvider<AdminCategoriesNotifier, List<CategoryModel>>(
  AdminCategoriesNotifier.new,
);

class AdminCategoriesNotifier extends AsyncNotifier<List<CategoryModel>> {
  AdminRepository get _repository => ref.read(adminRepositoryProvider);

  @override
  Future<List<CategoryModel>> build() => _repository.getCategories();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.getCategories);
  }

  Future<void> create(Map<String, dynamic> data) async {
    await _run(() => _repository.createCategory(data));
  }

  Future<void> saveCategory(int id, Map<String, dynamic> data) async {
    await _run(() => _repository.updateCategory(id, data));
  }

  Future<void> delete(int id) async {
    await _run(() => _repository.deleteCategory(id));
  }

  Future<void> _run(Future<dynamic> Function() operation) async {
    state = const AsyncLoading();
    try {
      await operation();
      state = await AsyncValue.guard(_repository.getCategories);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final adminOrdersProvider =
    AsyncNotifierProvider<AdminOrdersNotifier, List<OrderModel>>(
  AdminOrdersNotifier.new,
);

class AdminOrdersNotifier extends AsyncNotifier<List<OrderModel>> {
  AdminRepository get _repository => ref.read(adminRepositoryProvider);

  @override
  Future<List<OrderModel>> build() => _repository.getOrders();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.getOrders);
  }

  Future<void> updateStatus(int id, String status) async {
    state = const AsyncLoading();
    try {
      await _repository.updateOrderStatus(id, status);
      state = await AsyncValue.guard(_repository.getOrders);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}
