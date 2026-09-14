import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../../models/order_model.dart';

class OrderRepository {
  OrderRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<OrderModel>> getOrders() async {
    final response = await _apiClient.get('/orders');
    return ApiResponse.dataList(response).map(OrderModel.fromJson).toList();
  }

  Future<OrderModel> getOrder(int id) async {
    final response = await _apiClient.get('/orders/$id');
    return OrderModel.fromJson(ApiResponse.dataMap(response));
  }

  Future<OrderModel> checkout({required int addressId}) async {
    final response = await _apiClient.post('/orders/checkout', body: {
      'address_id': addressId,
    });
    return OrderModel.fromJson(ApiResponse.dataMap(response));
  }

  Future<PaymentModel> pay(int orderId) async {
    final response = await _apiClient.post('/orders/$orderId/pay');
    return PaymentModel.fromJson(ApiResponse.dataMap(response));
  }
}
