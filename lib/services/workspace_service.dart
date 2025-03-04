// import 'dart:convert';
// import 'dart:developer';
// import 'package:asr_project/config.dart';
// import 'package:asr_project/models/workspace.dart';
// import 'package:http/http.dart' as http;

// class WorkspaceService {
//   final String baseUrl = "${AppConfig.baseUrl}/workspaces";
//   final Map<String, String> headers = {
//     'Authorization': AppConfig.basicAuth,
//     'Content-Type': 'application/json',
//   };

//   Future<List<Workspace>> fetchWorkspaces() async {
//     try {
//       final response = await http.get(Uri.parse(baseUrl), headers: headers);
//       if (response.statusCode == 200) {
//         final List<dynamic> jsonData = jsonDecode(response.body);
//         return jsonData.map((data) => Workspace.fromMap(data)).toList();
//       }
//       throw Exception("Fail to fetch workspaces: ${response.statusCode}");
//     } catch (e) {
//       log("Error fetching tags: $e");
//       return [];
//     }
//   }
// }
