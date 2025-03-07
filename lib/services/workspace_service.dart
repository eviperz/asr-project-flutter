import 'dart:convert';
import 'dart:developer';
import 'package:asr_project/config.dart';
import 'package:asr_project/models/workspace.dart';
import 'package:http/http.dart' as http;

class WorkspaceService {
  final String userId = AppConfig.userId;
  final String baseUrl = "${AppConfig.baseUrl}/workspace";
  final Map<String, String> headers = {
    'Authorization': AppConfig.basicAuth,
    'Content-Type': 'application/json',
  };

  Future<List<Workspace>> getAllWorkspaces() async {
    try {
      final response =
          await http.get(Uri.parse("$baseUrl/user/$userId"), headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((data) => Workspace.fromJson(data)).toList();
      }
      throw Exception("Fail to fetch workspaces: ${response.statusCode}");
    } catch (e) {
      log("Error fetching workspaces: $e");
      return [];
    }
  }

  Future<Workspace?> createWorkspace(WorkspaceDetail workspaceDetail) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/user/$userId"),
        headers: headers,
        body: jsonEncode(
          workspaceDetail.toJson(),
        ),
      );

      if (response.statusCode == 200) {
        return Workspace.fromJson(jsonDecode(response.body));
      }
      throw Exception("Fail to create workspace: ${response.statusCode}");
    } catch (e) {
      log("Error create workspace: $e");
    }
    return null;
  }

  Future<Workspace?> updateWorkspace(
      String id, WorkspaceDetail workspaceDetail) async {
    try {
      final response = await http.patch(
        Uri.parse("$baseUrl/$id"),
        headers: headers,
        body: jsonEncode(
          workspaceDetail.toJson(),
        ),
      );

      if (response.statusCode == 200) {
        return Workspace.fromJson(jsonDecode(response.body));
      }
      throw Exception("Fail to update workspace: ${response.statusCode}");
    } catch (e) {
      log("Error update workspace: $e");
    }
    return null;
  }

  Future<bool> deleteWorkspace(String id) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/$id"),
        headers: headers,
      );

      if (response.statusCode == 204) {
        return true;
      }
      throw Exception("Fail to delete workspace: ${response.statusCode}");
    } catch (e) {
      log("Error delete workspace: $e");
    }
    return false;
  }
}
