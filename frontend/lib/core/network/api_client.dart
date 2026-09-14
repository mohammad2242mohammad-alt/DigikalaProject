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

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async =>
      _send(() => http.post(Uri.parse('$baseUrl$path'), headers: _headers, body: jsonEncode(body ?? {})));

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) async =>
      _send(() => http.put(Uri.parse('$baseUrl$path'), headers: _headers, body: jsonEncode(body ?? {})));

  Future<dynamic> patch(String path, {Map<String, dynamic>? body}) async =>
      _send(() => http.patch(Uri.parse('$baseUrl$path'), headers: _headers, body: jsonEncode(body ?? {})));

  Future<dynamic> delete(String path) async =>
      _send(() => http.delete(Uri.parse('$baseUrl$path'), headers: _headers));

  Future<dynamic> _send(Future<http.Response> Function() request) async {
    try {
      final response = await request();
      dynamic decoded;
      if (response.body.isNotEmpty) decoded = jsonDecode(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final payload = decoded is Map<String, dynamic> ? decoded : null;
        final message = payload?['message']?.toString() ?? 'خطا در ارتباط با سرور';
        final rawErrors = payload?['errors'];
        final errors = rawErrors is Map
            ? Map<String, dynamic>.from(rawErrors)
            : null;

        throw ApiException(
          message,
          statusCode: response.statusCode,
          errors: errors,
        );
      }
      return decoded;
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('ارتباط با سرور برقرار نشد.');
    }
  }
}
