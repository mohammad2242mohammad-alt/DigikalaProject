import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/seller_store_repository.dart';
import 'api_provider.dart';

final sellerStoreRepositoryProvider = Provider<SellerStoreRepository>(
  (ref) => SellerStoreRepository(ref.watch(apiClientProvider)),
);

final sellerStoreProvider = FutureProvider.family<SellerStoreData, String>(
  (ref, slug) => ref.watch(sellerStoreRepositoryProvider).getStore(slug),
);
