import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

class ApiClient {
  ApiClient({String? baseUrl}) : baseUrl = baseUrl ?? 'http://127.0.0.1:8000/api';

  final String baseUrl;
  String? token;

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Future<dynamic> get(String path, {Map<String, String>? queryParameters}) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: queryParameters);
    return _send(() => http.get(uri, headers: _headers));
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    return _send(() => http.post(
          Uri.parse('$baseUrl$path'),
          headers: _headers,
          body: jsonEncode(body ?? {}),
        ));
  }

  Future<dynamic> _send(Future<http.Response> Function() request) async {
    try {
      final response = await request();
      dynamic decoded;
      if (response.body.isNotEmpty) decoded = jsonDecode(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = decoded is Map<String, dynamic>
            ? decoded['message']?.toString() ?? 'خطا در ارتباط با سرور'
            : 'خطا در ارتباط با سرور';
        throw ApiException(message, statusCode: response.statusCode);
      }
      return decoded;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('ارتباط با سرور برقرار نشد.');
    }
  }
}
