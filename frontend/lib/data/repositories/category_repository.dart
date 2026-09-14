import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../../models/category_model.dart';

class CategoryRepository {
  CategoryRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<CategoryModel>> getCategories() async {
    final response = await _apiClient.get('/categories');
    return ApiResponse.dataList(response).map(CategoryModel.fromJson).toList();
  }
}
