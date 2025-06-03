import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  String? accessToken;
  String? refreshToken;

  // Load tokens from persistent storage when app starts
  Future<void> loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('access_token');
    refreshToken = prefs.getString('refresh_token');
  }

  Future<void> setTokens(String? access, String? refresh) async {
    accessToken = access;
    refreshToken = refresh;

    final prefs = await SharedPreferences.getInstance();
    if (access != null) {
      await prefs.setString('access_token', access);
    }
    if (refresh != null) {
      await prefs.setString('refresh_token', refresh);
    }
  }

  Future<void> clearTokens() async {
    accessToken = null;
    refreshToken = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  String? getAccessToken() => accessToken;
  String? getRefreshToken() => refreshToken;
}
