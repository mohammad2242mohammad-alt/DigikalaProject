import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/product_model.dart';

class ProductService {

  final String baseUrl = 'http://127.0.0.1:8000/api';


  Future<List<Product>> getProducts() async {

    final response = await http.get(
      Uri.parse('$baseUrl/products'),
    );


    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      List products = data['products'];

      return products
          .map((product) => Product.fromJson(product))
          .toList();

    } else {

      throw Exception('Failed to load products');

    }
  }
}