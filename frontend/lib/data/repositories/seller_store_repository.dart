import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../../models/product_model.dart';
import '../../models/seller_store_model.dart';

class SellerStoreRepository {
  SellerStoreRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<SellerStoreData> getStore(String slug) async {
    final response = await _apiClient.get('/sellers/$slug');
    final data = ApiResponse.dataMap(response);
    final seller = SellerStore.fromJson(
      Map<String, dynamic>.from(data['seller'] as Map),
    );
    final rawProducts = data['products'];
    final products = rawProducts is Map<String, dynamic>
        ? (rawProducts['data'] as List? ?? const [])
              .whereType<Map<String, dynamic>>()
              .map(Product.fromJson)
              .toList()
        : (rawProducts as List? ?? const [])
              .whereType<Map<String, dynamic>>()
              .map(Product.fromJson)
              .toList();

    return SellerStoreData(seller: seller, products: products);
  }
}
