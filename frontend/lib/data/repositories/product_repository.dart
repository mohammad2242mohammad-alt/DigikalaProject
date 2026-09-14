import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../../models/product_model.dart';

class ProductRepository {
  ProductRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Product>> getProducts({
    String? search,
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    String sort = 'latest',
    int perPage = 20,
  }) async {
    final query = <String, String>{
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      if (categoryId != null) 'category_id': '$categoryId',
      if (minPrice != null) 'min_price': '$minPrice',
      if (maxPrice != null) 'max_price': '$maxPrice',
      'sort': sort,
      'per_page': '$perPage',
    };

    final decoded = await _apiClient.get('/products', queryParameters: query);
    return ApiResponse.dataList(decoded).map(Product.fromJson).toList();
  }
}
