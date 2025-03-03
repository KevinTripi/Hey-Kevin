import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class YoloService {
  final String baseUrl;

  YoloService() : baseUrl = dotenv.env['API_BASE_URL'] ?? "http://localhost:8000";

  Future<String?> sendImageToYolo(String imagePath) async {
    var uri = Uri.parse("$baseUrl/segment");

    try {
      print("Sending POST request to: $uri");

      var request = http.MultipartRequest("POST", uri);
      var stream = http.ByteStream(File(imagePath).openRead());
      var length = await File(imagePath).length();
      var multipartFile = http.MultipartFile('file', stream, length, filename: basename(imagePath));
      request.files.add(multipartFile);

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print("Raw API Response: $responseBody");
      print("Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        
        if (data.containsKey('cropped_image_path') && data['cropped_image_path'] != null) {
          String apiImagePath = data['cropped_image_path'];
          print("Image URL received: $apiImagePath");

          // Return image URL with timestamp to prevent caching
          return "$apiImagePath?t=${DateTime.now().millisecondsSinceEpoch}";
        } else {
          print("No 'cropped_image_path' in API response.");
        }
      } else {
        print("Request failed with status: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      print("Error sending request: $e");
      print(stackTrace);
    }
    return null;
  }
}
