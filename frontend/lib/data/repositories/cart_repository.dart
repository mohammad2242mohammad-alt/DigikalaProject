import '../../core/network/api_client.dart';
import '../../models/cart_model.dart';

class CartRepository {
  CartRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<CartModel> getCart() async => _parse(await _apiClient.get('/cart'));

  Future<CartModel> addItem({required int productId, int quantity = 1}) async =>
      _parse(await _apiClient.post('/cart/items', body: {
        'product_id': productId,
        'quantity': quantity,
      }));

  Future<CartModel> clear() async => _parse(await _apiClient.post('/cart/clear'));

  CartModel _parse(dynamic response) {
    if (response is! Map<String, dynamic> || response['data'] is! Map<String, dynamic>) {
      throw const FormatException('Invalid cart response');
    }
    return CartModel.fromJson(response['data'] as Map<String, dynamic>);
  }
}
