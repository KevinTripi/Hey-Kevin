import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// This function sends API request and returns JSON object that contains the comments
Future<String?> fetchGptResponse(String sessionId) async {
  var baseUrl = dotenv.env['API_BASE_URL'] ?? "http://localhost:8000";
  var uri = Uri.parse("$baseUrl/status/$sessionId");
  String apiKey = dotenv.env['x-api-key'] ?? '';

  final headers = {
    "x-api-key": apiKey,
    "Content-Type": "application/json",
  };

  print("Sending GET request to ${uri.toString()}");
  // Get response
  final response = await http.get(uri, headers: headers);
  print("return statusCode: ${response.statusCode}");

  if (response.statusCode == 200) {
    // Since the server doesn't specify utf-8, gpt returns bad encoding for back ticks.
    // More info: https://stackoverflow.com/questions/2477452/%C3%A2%E2%82%AC-showing-on-page-instead-of
    return utf8.decode(response.bodyBytes);
  } else {
    return null;
  }
}
