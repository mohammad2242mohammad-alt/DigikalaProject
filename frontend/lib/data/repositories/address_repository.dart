import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
import '../../models/address_model.dart';

class AddressRepository {
  AddressRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<AddressModel>> getAddresses() async {
    final response = await _apiClient.get('/addresses');
    return ApiResponse.dataList(response)
        .map(AddressModel.fromJson)
        .toList();
  }

  Future<AddressModel> create({
    String? title,
    required String recipientName,
    required String phone,
    required String province,
    required String city,
    required String address,
    required String postalCode,
    bool isDefault = false,
  }) async {
    final response = await _apiClient.post('/addresses', body: {
      if (title != null) 'title': title,
      'recipient_name': recipientName,
      'phone': phone,
      'province': province,
      'city': city,
      'address': address,
      'postal_code': postalCode,
      'is_default': isDefault,
    });
    return AddressModel.fromJson(ApiResponse.dataMap(response));
  }

  Future<AddressModel> update({
    required int id,
    String? title,
    required String recipientName,
    required String phone,
    required String province,
    required String city,
    required String address,
    required String postalCode,
    bool isDefault = false,
  }) async {
    final response = await _apiClient.patch('/addresses/$id', body: {
      if (title != null) 'title': title,
      'recipient_name': recipientName,
      'phone': phone,
      'province': province,
      'city': city,
      'address': address,
      'postal_code': postalCode,
      'is_default': isDefault,
    });
    return AddressModel.fromJson(ApiResponse.dataMap(response));
  }

  Future<void> delete(int id) async {
    await _apiClient.delete('/addresses/$id');
  }
}
