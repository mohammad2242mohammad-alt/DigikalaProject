import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/admin_repository.dart';
import 'api_provider.dart';

final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => AdminRepository(ref.watch(apiClientProvider)),
);
