import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<String?> sendImageToSegment(String imagePath) async {
  var baseUrl = dotenv.env['API_BASE_URL'] ?? "http://localhost:8000";
  var uri = Uri.parse("$baseUrl/segment");
  String apiKey = dotenv.env['x-api-key'] ?? '';

  try {
    print("Sending POST request to: $uri");

    var request = http.MultipartRequest("POST", uri);

    // Add API key in the headers
    if (apiKey.isNotEmpty) {
      request.headers['x-api-key'] = apiKey;
    }

    var stream = http.ByteStream(File(imagePath).openRead());
    var length = await File(imagePath).length();
    var multipartFile = http.MultipartFile('file', stream, length,
        filename: basename(imagePath));
    request.files.add(multipartFile);

    // print("Request toString: ${request.toString()}");
    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    // print("Raw API Response: $responseBody");
    print("Status Code: ${response.statusCode}");

    if (response.statusCode == 200) {
      return responseBody;
    } else {
      print("Request failed with status: ${response.statusCode}");
    }
  } catch (e, stackTrace) {
    print("Error sending request: $e");
    print(stackTrace);
  }
  return null;
}
