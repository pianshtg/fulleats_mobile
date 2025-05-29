class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  String? accessToken;
  String? refreshToken;

  void setTokens(String? access, String? refresh) {
    accessToken = access;
    refreshToken = refresh;
  }

  String? getAccessToken() => accessToken;
  String? getRefreshToken() => refreshToken;

  Future<void> clearTokens() async {
    accessToken = null;
    refreshToken = null;
  }
}
