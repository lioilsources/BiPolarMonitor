import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../domain/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository(ref));

class AuthRepository {
  final Ref _ref;

  AuthRepository(this._ref);

  ApiClient get _api => _ref.read(apiClientProvider);
  SecureStorageService get _storage => _ref.read(secureStorageProvider);

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final resp = await _api.post('/auth/register', {
      'email': email,
      'password': password,
      'display_name': displayName,
    });
    await _storage.saveTokens(
      access: resp['access_token'] as String,
      refresh: resp['refresh_token'] as String,
    );
  }

  Future<void> login({required String email, required String password}) async {
    final resp = await _api.post('/auth/login', {
      'email': email,
      'password': password,
    });
    await _storage.saveTokens(
      access: resp['access_token'] as String,
      refresh: resp['refresh_token'] as String,
    );
  }

  Future<void> logout() => _storage.clearTokens();

  Future<bool> isLoggedIn() async {
    final token = await _storage.getAccessToken();
    return token != null;
  }

  Future<UserModel> getProfile() async {
    final resp = await _api.get('/user/profile');
    return UserModel.fromJson(resp);
  }
}
