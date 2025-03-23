import 'dart:convert';
import 'dart:developer';

import 'package:asr_project/config.dart';
import 'package:asr_project/models/enum/workspace_permission.dart';
import 'package:http/http.dart' as http;

class WorkspaceMemberService {
  String? _userId;
  final String baseUrl = "${AppConfig.baseUrl}/workspace_members";

  Future<Map<String, String>> _getHeaders() async {
    String? token = await AppConfig.getToken();

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept-Charset': 'utf-8',
    };
  }

  WorkspaceMemberService() {
    _initializeUserId();
  }

  Future<void> _initializeUserId() async {
    _userId = await AppConfig.getUserId();
    log("User ID Loaded WorkspaceMemberService: $_userId");
  }

  Future<bool> updatePermission(
      String id, WorkspacePermission permission) async {
    try {
      final headers = await _getHeaders();

      final response = await http.patch(
          Uri.parse("$baseUrl/$id/update_permission"),
          headers: headers,
          body: jsonEncode({
            "permission":
                WorkspacePermission.toStringWorkspacePermission(permission)
          }));

      if (response.statusCode == 200) {
        return true;
      }
      throw Exception("Fail to update permission: ${response.statusCode}");
    } catch (e) {
      log("Error update permission: $e");
    }
    return false;
  }

  Future<bool> accept(String id) async {
    try {
      final headers = await _getHeaders();

      final response = await http.patch(
        Uri.parse("$baseUrl/$id/accept"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return true;
      }
      throw Exception("Fail to accept member: ${response.statusCode}");
    } catch (e) {
      log("Error accept member: $e");
    }
    return false;
  }

  Future<bool> reject(String id) async {
    try {
      final headers = await _getHeaders();

      final response = await http.delete(
        Uri.parse("$baseUrl/$id/reject"),
        headers: headers,
      );

      if (response.statusCode == 204 || response.statusCode == 200) {
        return true;
      }
      throw Exception("Fail to remove member: ${response.statusCode}");
    } catch (e) {
      log("Error remove member: $e");
    }
    return false;
  }
}
