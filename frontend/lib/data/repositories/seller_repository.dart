import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../../models/product_model.dart';

class SellerRepository {
  SellerRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _apiClient.get('/seller/profile');
    return ApiResponse.dataMap(response);
  }

  Future<List<Product>> getProducts() async {
    final response = await _apiClient.get('/seller/products');
    return ApiResponse.dataList(response).map(Product.fromJson).toList();
  }

  Future<Map<String, dynamic>> apply({
    required String storeName,
    String? description,
  }) async {
    final response = await _apiClient.post(
      '/seller/apply',
      body: {
        'store_name': storeName.trim(),
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
      },
    );
    return ApiResponse.dataMap(response);
  }

  Future<Product> createProduct({
    required String name,
    required String description,
    required double price,
    double? discountPrice,
    required int stock,
    int? categoryId,
    String? image,
  }) async {
    final response = await _apiClient.post(
      '/seller/products',
      body: {
        'name': name.trim(),
        'description': description.trim(),
        'price': price,
        if (discountPrice != null) 'discount_price': discountPrice,
        'stock': stock,
        if (categoryId != null) 'category_id': categoryId,
        if (image != null && image.trim().isNotEmpty) 'image': image.trim(),
      },
    );
    return Product.fromJson(ApiResponse.dataMap(response));
  }
}
