import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../models/product_model.dart';

const productApiBaseUrl = 'http://127.0.0.1:8000/api';

class ProductSearchQuery {
  const ProductSearchQuery({
    this.search = '',
    this.categoryId,
    this.minPrice,
    this.maxPrice,
    this.sort = 'latest',
    this.perPage = 50,
  });

  final String search;
  final int? categoryId;
  final double? minPrice;
  final double? maxPrice;
  final String sort;
  final int perPage;

  @override
  bool operator ==(Object other) =>
      other is ProductSearchQuery &&
      other.search == search &&
      other.categoryId == categoryId &&
      other.minPrice == minPrice &&
      other.maxPrice == maxPrice &&
      other.sort == sort &&
      other.perPage == perPage;

  @override
  int get hashCode => Object.hash(search, categoryId, minPrice, maxPrice, sort, perPage);
}

final productSearchProvider = FutureProvider.family<List<Product>, ProductSearchQuery>((ref, query) async {
  final uri = Uri.parse('$productApiBaseUrl/products').replace(
    queryParameters: {
      if (query.search.isNotEmpty) 'search': query.search,
      if (query.categoryId != null) 'category_id': query.categoryId.toString(),
      if (query.minPrice != null) 'min_price': query.minPrice!.toString(),
      if (query.maxPrice != null) 'max_price': query.maxPrice!.toString(),
      'sort': query.sort,
      'per_page': query.perPage.toString(),
    },
  );

  final response = await http.get(uri, headers: {'Accept': 'application/json'});
  if (response.statusCode != 200) {
    throw Exception('HTTP ${response.statusCode}: ${response.body}');
  }

  final decoded = jsonDecode(response.body);
  final rawProducts = decoded is Map<String, dynamic> ? decoded['products'] : null;
  if (rawProducts is! List) {
    throw const FormatException('پاسخ API محصولات نامعتبر است.');
  }

  return rawProducts
      .map((item) => Product.fromJson(Map<String, dynamic>.from(item as Map)))
      .toList();
});

final productsProvider = FutureProvider<List<Product>>((ref) {
  return ref.watch(productSearchProvider(const ProductSearchQuery()).future);
});
