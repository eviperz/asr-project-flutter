import 'dart:convert';

class AppConfig {
  static const String baseUrl = "http://192.168.1.37:8080";

  static const String username = "admin";
  static const String password = "password";

  static final String basicAuth =
      'Basic ${base64Encode(utf8.encode('$username:$password'))}';

  static const String userId = "67d450a063094576e4149aed";
}
