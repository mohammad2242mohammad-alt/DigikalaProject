import '../../core/network/api_client.dart';
import '../../core/network/api_response.dart';
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
    return _parseSession(response);
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
    return _parseSession(response);
  }

  Future<UserModel> me() async {
    final response = await _apiClient.get('/auth/me');
    return UserModel.fromJson(ApiResponse.dataMap(response));
  }

  Future<void> logout() async {
    await _apiClient.post('/auth/logout');
    _apiClient.token = null;
  }

  AuthSession _parseSession(dynamic response) {
    final data = ApiResponse.dataMap(response);
    final user = data['user'];
    final token = data['token'];

    if (user is! Map<String, dynamic> || token is! String || token.isEmpty) {
      throw const FormatException('Invalid auth response');
    }

    final session = AuthSession(
      user: UserModel.fromJson(user),
      token: token,
    );
    _apiClient.token = session.token;
    return session;
  }
}
