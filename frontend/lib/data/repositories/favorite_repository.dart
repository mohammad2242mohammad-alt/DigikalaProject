import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../../models/product_model.dart';

class FavoriteRepository {
  FavoriteRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Product>> getFavorites() async {
    final response = await _apiClient.get('/favorites');
    return ApiResponse.dataList(response)
        .map((item) => Product.fromJson(Map<String, dynamic>.from(item['product'] as Map)))
        .toList();
  }

  Future<void> add(int productId) async {
    await _apiClient.post('/favorites/$productId');
  }

  Future<void> remove(int productId) async {
    await _apiClient.delete('/favorites/$productId');
  }
}
