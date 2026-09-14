import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/address_repository.dart';
import '../models/address_model.dart';
import 'api_provider.dart';

final addressRepositoryProvider = Provider<AddressRepository>(
  (ref) => AddressRepository(ref.watch(apiClientProvider)),
);

final addressesProvider = AsyncNotifierProvider<AddressNotifier, List<AddressModel>>(
  AddressNotifier.new,
);

class AddressNotifier extends AsyncNotifier<List<AddressModel>> {
  AddressRepository get _repository => ref.read(addressRepositoryProvider);

  @override
  Future<List<AddressModel>> build() => _repository.getAddresses();

  Future<void> create({
    String? title,
    required String recipientName,
    required String phone,
    required String province,
    required String city,
    required String address,
    required String postalCode,
    double? latitude,
    double? longitude,
    bool isDefault = false,
  }) async {
    await _run(() => _repository.create(
          title: title,
          recipientName: recipientName,
          phone: phone,
          province: province,
          city: city,
          address: address,
          postalCode: postalCode,
          latitude: latitude,
          longitude: longitude,
          isDefault: isDefault,
        ));
  }

  Future<void> saveAddress({
    required int id,
    String? title,
    required String recipientName,
    required String phone,
    required String province,
    required String city,
    required String address,
    required String postalCode,
    double? latitude,
    double? longitude,
    bool isDefault = false,
  }) async {
    await _run(() => _repository.update(
          id: id,
          title: title,
          recipientName: recipientName,
          phone: phone,
          province: province,
          city: city,
          address: address,
          postalCode: postalCode,
          latitude: latitude,
          longitude: longitude,
          isDefault: isDefault,
        ));
  }

  Future<void> delete(int id) async {
    await _run(() => _repository.delete(id));
  }

  Future<void> refreshAddresses() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.getAddresses);
  }

  Future<void> _run(Future<void> Function() operation) async {
    state = const AsyncLoading();
    try {
      await operation();
      state = await AsyncValue.guard(_repository.getAddresses);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}
