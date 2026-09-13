import '../../core/network/api_client.dart';
import '../../models/order_model.dart';

class OrderRepository {
  OrderRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<OrderModel>> getOrders() async {
    final response = await _apiClient.get('/orders');
    final data = response['data'];
    final list = data is Map<String, dynamic> ? data['data'] : data;
    if (list is! List) throw const FormatException('Invalid orders response');
    return list
        .whereType<Map<String, dynamic>>()
        .map(OrderModel.fromJson)
        .toList();
  }

  Future<OrderModel> getOrder(int id) async {
    final response = await _apiClient.get('/orders/$id');
    return OrderModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<OrderModel> checkout({required int addressId}) async {
    final response = await _apiClient.post('/orders/checkout', body: {
      'address_id': addressId,
    });
    return OrderModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<PaymentModel> pay(int orderId) async {
    final response = await _apiClient.post('/orders/$orderId/pay');
    return PaymentModel.fromJson(response['data'] as Map<String, dynamic>);
  }
}
