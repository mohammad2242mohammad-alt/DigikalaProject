import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product_model.dart';

class ProductService {
  final String baseUrl = 'http://127.0.0.1:8000/api';

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
      if (categoryId != null) 'category_id': categoryId.toString(),
      if (minPrice != null) 'min_price': minPrice.toString(),
      if (maxPrice != null) 'max_price': maxPrice.toString(),
      'sort': sort,
      'per_page': perPage.toString(),
    };

    final uri = Uri.parse('$baseUrl/products').replace(queryParameters: query);
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load products (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic> || decoded['data'] is! List) {
      throw Exception('Invalid products response');
    }

    final products = decoded['data'] as List;
    return products
        .whereType<Map<String, dynamic>>()
        .map(Product.fromJson)
        .toList();
  }
}
