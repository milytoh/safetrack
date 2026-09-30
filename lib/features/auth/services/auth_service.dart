import '../../../core/api/api_client.dart';
import '../../../core/storage/token_storage.dart';

class AuthService {
  /// Login with phone + password
  static Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    final res = await ApiClient.request(
      '/auth/login',
      method: 'POST',
      body: {'phone': phone, 'password': password},
    );

    if (res['token'] != null) {
      await TokenStorage.save(res['token']);
    }

    return res;
  }

  /// Register new user
  static Future<Map<String, dynamic>> register({
    required Map<String, String> profile,
    required List<Map<String, String>> contacts,
  }) async {
    final res = await ApiClient.request(
      '/auth/register',
      method: 'POST',
      body: {...profile, 'contacts': contacts},
    );

    // Note: According to React code, register does NOT return a token.
    // User must verify OTP first.
    return res;
  }

  /// Get current logged-in user
  static Future<Map<String, dynamic>> me() async {
    return await ApiClient.request('/auth/me');
  }

  /// Logout
  static Future<void> logout() async {
    await TokenStorage.clear();
  }
}
