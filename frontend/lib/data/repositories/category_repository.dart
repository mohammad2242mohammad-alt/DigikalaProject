import '../../core/network/api_client.dart';
import '../../models/category_model.dart';

class CategoryRepository {
  CategoryRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<CategoryModel>> getCategories() async {
    final response = await _apiClient.get('/categories');
    if (response is! Map<String, dynamic> || response['data'] is! List) {
      throw const FormatException('Invalid categories response');
    }
    return (response['data'] as List)
        .whereType<Map<String, dynamic>>()
        .map(CategoryModel.fromJson)
        .toList();
  }
}
