import 'dart:convert';
import 'dart:developer';

import 'package:asr_project/config.dart';
import 'package:asr_project/models/enum/workspace_permission.dart';
import 'package:http/http.dart' as http;

class WorkspaceMemberService {
  final String userId = AppConfig.userId;
  final String baseUrl = "${AppConfig.baseUrl}/workspace_members";
  final Map<String, String> headers = {
    'Authorization': AppConfig.basicAuth,
    'Content-Type': 'application/json',
  };

  Future<bool> updatePermission(
      String id, WorkspacePermission permission) async {
    try {
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

  Future<bool> reject(String id) async {
    try {
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
