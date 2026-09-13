import '../../core/network/api_client.dart';
import '../../models/category_model.dart';
import '../../models/order_model.dart';
import '../../models/product_model.dart';

class AdminRepository {
  AdminRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Product>> getProducts() async {
    final decoded = await _apiClient.get('/admin/products');
    return _dataList(decoded).map(Product.fromJson).toList();
  }

  Future<Product> createProduct(Map<String, dynamic> data) async {
    final decoded = await _apiClient.post('/products', body: data);
    return Product.fromJson(_dataMap(decoded));
  }

  Future<Product> updateProduct(int id, Map<String, dynamic> data) async {
    final decoded = await _apiClient.patch('/products/$id', body: data);
    return Product.fromJson(_dataMap(decoded));
  }

  Future<void> deleteProduct(int id) async {
    await _apiClient.delete('/products/$id');
  }

  Future<List<CategoryModel>> getCategories() async {
    final decoded = await _apiClient.get('/admin/categories');
    return _dataList(decoded).map(CategoryModel.fromJson).toList();
  }

  Future<CategoryModel> createCategory(Map<String, dynamic> data) async {
    final decoded = await _apiClient.post('/categories', body: data);
    return CategoryModel.fromJson(_dataMap(decoded));
  }

  Future<CategoryModel> updateCategory(int id, Map<String, dynamic> data) async {
    final decoded = await _apiClient.patch('/categories/$id', body: data);
    return CategoryModel.fromJson(_dataMap(decoded));
  }

  Future<void> deleteCategory(int id) async {
    await _apiClient.delete('/categories/$id');
  }

  Future<List<OrderModel>> getOrders() async {
    final decoded = await _apiClient.get('/admin/orders');
    return _dataList(decoded).map(OrderModel.fromJson).toList();
  }

  Future<OrderModel> updateOrderStatus(int id, String status) async {
    final decoded = await _apiClient.patch(
      '/admin/orders/$id/status',
      body: {'status': status},
    );
    return OrderModel.fromJson(_dataMap(decoded));
  }

  Map<String, dynamic> _dataMap(dynamic decoded) {
    if (decoded is Map<String, dynamic> && decoded['data'] is Map<String, dynamic>) {
      return decoded['data'] as Map<String, dynamic>;
    }
    throw const FormatException('Invalid admin response');
  }

  List<Map<String, dynamic>> _dataList(dynamic decoded) {
    if (decoded is! Map<String, dynamic> || decoded['data'] == null) {
      throw const FormatException('Invalid admin list response');
    }

    final raw = decoded['data'];
    final list = raw is Map<String, dynamic> ? raw['data'] : raw;
    if (list is! List) throw const FormatException('Invalid admin list response');

    return list.whereType<Map<String, dynamic>>().toList();
  }
}
