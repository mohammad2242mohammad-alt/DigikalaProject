class ApiResponse {
  const ApiResponse._();

  static Map<String, dynamic> dataMap(dynamic response) {
    final data = response is Map<String, dynamic> ? response['data'] : null;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid API object response');
    }
    return data;
  }

  static List<Map<String, dynamic>> dataList(dynamic response) {
    final data = response is Map<String, dynamic> ? response['data'] : null;
    if (data is! List) {
      throw const FormatException('Invalid API list response');
    }
    return data.whereType<Map<String, dynamic>>().toList();
  }
}
