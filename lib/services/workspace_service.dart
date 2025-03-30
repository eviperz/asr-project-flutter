import 'dart:convert';
import 'dart:developer';
import 'package:asr_project/config.dart';
import 'package:asr_project/models/workspace.dart';
import 'package:asr_project/models/workspace_member.dart';
import 'package:http/http.dart' as http;

class WorkspaceService {
  String? _userId;
  final String baseUrl = "${AppConfig.baseUrl}/workspaces";
  Future<Map<String, String>> _getHeaders() async {
    String? token = await AppConfig.getToken();

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept-Charset': 'utf-8',
    };
  }

  WorkspaceService() {
    _initializeUserId();
  }

  Future<void> _initializeUserId() async {
    _userId = await AppConfig.getUserId();
    log("User ID Loaded WorkspaceService: $_userId");
  }

  Future<List<Workspace>> getAllWorkspaces() async {
    try {
      final headers = await _getHeaders();
      final String? userId = await AppConfig.getUserId();

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
      final headers = await _getHeaders();
      final String? userId = await AppConfig.getUserId();
      final response = await http.post(
        Uri.parse("$baseUrl/user/$userId"),
        headers: headers,
        body: jsonEncode(
          workspaceDetail.toJson(),
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
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
      final headers = await _getHeaders();

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
      final headers = await _getHeaders();

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

  Future<Workspace?> inviteMembers(
      String id, List<WorkspaceMemberInviting> workspaceMemberInvitings) async {
    try {
      final headers = await _getHeaders();

      final response = await http.post(
        Uri.parse("$baseUrl/$id/invite"),
        headers: headers,
        body: jsonEncode(
            workspaceMemberInvitings.map((e) => e.toJson()).toList()),
      );

      if (response.statusCode == 200) {
        return Workspace.fromJson(jsonDecode(response.body));
      }
      throw Exception("Fail to invite member: ${response.statusCode}");
    } catch (e) {
      log("Error invite member: $e");
    }
    return null;
  }

  Future<bool> removeMember(String workspaceMemberId) async {
    try {
      final headers = await _getHeaders();

      final response = await http.delete(
        Uri.parse("$baseUrl/members/$workspaceMemberId"),
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
