import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

class ObjectDetectionScreen extends StatefulWidget {
  final String imagePath;
  const ObjectDetectionScreen({Key? key, required this.imagePath})
      : super(key: key);

  @override
  _ObjectDetectionScreenState createState() => _ObjectDetectionScreenState();
}

class _ObjectDetectionScreenState extends State<ObjectDetectionScreen> {
  bool _isProcessing = true;
  // Map<String, dynamic>? _detectionResult;
  String? _segmentedImagePath = "lib/assets/segment/cropped_segmented.jpg";

  @override
  void initState() {
    super.initState();
    _sendImageToYolo();
    testAPIConnection();
  }

  Future<void> _sendImageToYolo() async {
    var uri = Uri.parse("http://192.168.1.164:8000/segment");

    print("📤 Sending POST request to: $uri");

    var request = http.MultipartRequest("POST", uri);
    var stream = http.ByteStream(File(widget.imagePath).openRead());
    var length = await File(widget.imagePath).length();
    var multipartFile = http.MultipartFile('file', stream, length,
        filename: basename(widget.imagePath));
    request.files.add(multipartFile);

    try {
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print("📥 Raw API Response: $responseBody");
      print("📡 Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        print("📝 Parsed JSON: $data");

        if (data.containsKey('cropped_image_path') &&
            data['cropped_image_path'] != null) {
          String apiImagePath = data['cropped_image_path'];

          // ✅ Save the image locally in `lib/assets/`
          await _saveImageFromAPI("http://192.168.1.164:8000$apiImagePath");
        } else {
          print("⚠️ No 'cropped_image_path' in API response!");
        }
      } else {
        print("❌ Request failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("🚨 Error sending request: $e");
    }
  }

  /// ✅ Save the image inside `lib/assets/` on local computer
  Future<void> _saveImageFromAPI(String imageUrl) async {
    try {
      var response = await http.get(Uri.parse(imageUrl));

      if (response.statusCode == 200) {
        // ✅ Define the local project folder path
        String localPath = "lib/assets/cropped_segmented.jpg";

        // ✅ Save image to `assets/` directory in project folder
        File file = File(localPath);
        await file.writeAsBytes(response.bodyBytes);

        print("✅ Image saved in project folder at: $localPath");
      } else {
        print("❌ Failed to get image. Status: ${response.statusCode}");
      }
    } catch (e) {
      print("🚨 Error saving image: $e");
    }
  }

  Future<void> testAPIConnection() async {
    var url = "http://0.0.0.0:8000/docs"; // Testing connection
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: 10));
      print("📡 API Connection Status Code: ${response.statusCode}");
      print("📥 API Response: ${response.body}");
    } catch (e) {
      print("🚨 Error connecting to API: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("YOLO Object Detection")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Display original image
            Text("📸 Original Image",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Image.file(File(widget.imagePath), width: 300),

            const SizedBox(height: 20),

            // Show processing indicator or display segmented image
            _isProcessing
                ? const CircularProgressIndicator()
                : _segmentedImagePath != null
                    ? Column(
                        children: [
                          Text("🖼️ Segmented Image",
                              style: TextStyle(fontWeight: FontWeight.bold)),

                          // ✅ Use Image.file() for local images
                          Image.file(File(_segmentedImagePath!).absolute,
                              width: 300),
                        ],
                      )
                    : const Text("No segmented image available."),
          ],
        ),
      ),
    );
  }
}
