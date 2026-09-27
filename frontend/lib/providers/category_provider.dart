import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';

const categoryApiBaseUrl = 'http://127.0.0.1:8000/api';

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final response = await http.get(Uri.parse('$categoryApiBaseUrl/categories'), headers: {'Accept': 'application/json'});
  if (response.statusCode != 200) throw Exception('HTTP ${response.statusCode}: ${response.body}');
  final decoded = jsonDecode(response.body);
  final rawCategories = decoded is Map<String, dynamic> ? decoded['categories'] : null;
  if (rawCategories is! List) throw const FormatException('پاسخ API دسته‌بندی‌ها نامعتبر است.');
  return rawCategories.map((item) => CategoryModel.fromJson(Map<String, dynamic>.from(item as Map))).toList();
});
