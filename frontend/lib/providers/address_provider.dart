import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/address_repository.dart';
import '../models/address_model.dart';
import 'product_provider.dart';

final addressRepositoryProvider = Provider<AddressRepository>(
  (ref) => AddressRepository(ref.watch(apiClientProvider)),
);

final addressesProvider = FutureProvider<List<AddressModel>>((ref) {
  return ref.watch(addressRepositoryProvider).getAddresses();
});
