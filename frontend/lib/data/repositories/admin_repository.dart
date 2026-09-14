import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../../models/category_model.dart';
import '../../models/order_model.dart';
import '../../models/product_model.dart';

class AdminRepository {
  AdminRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Product>> getProducts() async {
    final response = await _apiClient.get('/admin/products');
    return ApiResponse.dataList(response).map(Product.fromJson).toList();
  }

  Future<Product> createProduct(Map<String, dynamic> data) async {
    final response = await _apiClient.post('/products', body: data);
    return Product.fromJson(ApiResponse.dataMap(response));
  }

  Future<Product> updateProduct(int id, Map<String, dynamic> data) async {
    final response = await _apiClient.patch('/products/$id', body: data);
    return Product.fromJson(ApiResponse.dataMap(response));
  }

  Future<void> deleteProduct(int id) async {
    await _apiClient.delete('/products/$id');
  }

  Future<List<CategoryModel>> getCategories() async {
    final response = await _apiClient.get('/admin/categories');
    return ApiResponse.dataList(response)
        .map(CategoryModel.fromJson)
        .toList();
  }

  Future<CategoryModel> createCategory(Map<String, dynamic> data) async {
    final response = await _apiClient.post('/categories', body: data);
    return CategoryModel.fromJson(ApiResponse.dataMap(response));
  }

  Future<CategoryModel> updateCategory(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiClient.patch('/categories/$id', body: data);
    return CategoryModel.fromJson(ApiResponse.dataMap(response));
  }

  Future<void> deleteCategory(int id) async {
    await _apiClient.delete('/categories/$id');
  }

  Future<List<OrderModel>> getOrders() async {
    final response = await _apiClient.get('/admin/orders');
    return ApiResponse.dataList(response).map(OrderModel.fromJson).toList();
  }

  Future<OrderModel> updateOrderStatus(int id, String status) async {
    final response = await _apiClient.patch(
      '/admin/orders/$id/status',
      body: {'status': status},
    );
    return OrderModel.fromJson(ApiResponse.dataMap(response));
  }
}
