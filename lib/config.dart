import 'dart:convert';

class AppConfig {
  static const String baseUrl = "http://localhost:8080";

  static const String username = "admin";
  static const String password = "password";

  static final String basicAuth =
      'Basic ${base64Encode(utf8.encode('$username:$password'))}';

  static const String userId = "67cc2cdf2f48ca6783912ead";
}
