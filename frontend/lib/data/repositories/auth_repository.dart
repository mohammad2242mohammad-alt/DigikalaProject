import '../../core/network/api_client.dart';
import '../../models/user_model.dart';

class AuthSession {
  final UserModel user;
  final String token;

  const AuthSession({required this.user, required this.token});
}

class AuthRepository {
  AuthRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<AuthSession> login({required String email, required String password}) async {
    final response = await _apiClient.post('/auth/login', body: {
      'email': email,
      'password': password,
    });
    final data = response['data'] as Map<String, dynamic>;
    final session = AuthSession(
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      token: data['token'].toString(),
    );
    _apiClient.token = session.token;
    return session;
  }

  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final response = await _apiClient.post('/auth/register', body: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
    final data = response['data'] as Map<String, dynamic>;
    final session = AuthSession(
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      token: data['token'].toString(),
    );
    _apiClient.token = session.token;
    return session;
  }

  Future<UserModel> me() async {
    final response = await _apiClient.get('/auth/me');
    return UserModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await _apiClient.post('/auth/logout');
    _apiClient.token = null;
  }
}
