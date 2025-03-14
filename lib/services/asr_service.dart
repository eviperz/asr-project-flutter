import 'dart:developer';
import 'dart:io';
import 'package:asr_project/config.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;

class AsrService {
  final String diaryId = "test";
  final String baseUrl = "${AppConfig.baseUrl}/minio";
  final Map<String, String> headers = {
    'Authorization': AppConfig.basicAuth,
    'Content-Type': 'application/json',
  };

  Future<String> uploadFile(File file) async {
    try {
      String fileExtension = path.extension(file.path).toLowerCase();

      String mimeType;
      switch (fileExtension) {
        case '.wav':
          mimeType = 'audio/wav';
          break;
        case '.mp3':
          mimeType = 'audio/mpeg';
          break;
        case '.m4a':
          mimeType = 'audio/mp4';
          break;
        default:
          throw Exception("Unsupported file format: $fileExtension");
      }
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("$baseUrl/upload"),
      );
      request.headers.addAll(headers);

      var fileStream = http.ByteStream(file.openRead());
      var fileLength = await file.length();
      var multipartFile = http.MultipartFile(
        'audioFile',
        fileStream,
        fileLength,
        filename: file.uri.pathSegments.last,
        contentType: MediaType('audio', mimeType.split('/').last),
      );

      request.files.add(multipartFile);

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseBody = await response.stream.bytesToString();

        return responseBody;
      } else {
        throw Exception("Failed to upload audio file: ${response.statusCode}");
      }
    } catch (e) {
      log("Error creating audio file: $e");
      return "";
    }
  }

  Future<String> getFileUrl(String fileName) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/download/$fileName"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return response.body;
      }
      throw Exception("Fail to fetch audio file: ${response.statusCode}");
    } catch (e) {
      log("Error fetching audio file: $e");
      return "";
    }
  }
}
