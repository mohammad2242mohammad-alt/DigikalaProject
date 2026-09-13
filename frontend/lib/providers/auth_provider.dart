import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/repositories/auth_repository.dart';
import '../models/user_model.dart';
import 'product_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(apiClientProvider)),
);

class AuthNotifier extends AsyncNotifier<UserModel?> {
  static const _tokenKey = 'auth_token';

  @override
  Future<UserModel?> build() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null || token.isEmpty) {
      return null;
    }

    final apiClient = ref.read(apiClientProvider);
    apiClient.token = token;

    try {
      return await ref.read(authRepositoryProvider).me();
    } catch (_) {
      apiClient.token = null;
      await prefs.remove(_tokenKey);
      return null;
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = await ref.read(authRepositoryProvider).login(
            email: email,
            password: password,
          );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, session.token);
      return session.user;
    });
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = await ref.read(authRepositoryProvider).register(
            name: name,
            email: email,
            password: password,
            passwordConfirmation: passwordConfirmation,
          );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, session.token);
      return session.user;
    });
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      try {
        await ref.read(authRepositoryProvider).logout();
      } finally {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_tokenKey);
        ref.read(apiClientProvider).token = null;
      }
      return null;
    });
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, UserModel?>(
  AuthNotifier.new,
);
