import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ObjectDetectionScreen extends StatefulWidget {
  final String imagePath;
  const ObjectDetectionScreen({Key? key, required this.imagePath})
      : super(key: key);

  @override
  _ObjectDetectionScreenState createState() => _ObjectDetectionScreenState();
}

class _ObjectDetectionScreenState extends State<ObjectDetectionScreen> {
  bool _isProcessing = true;
  String? _segmentedImagePath;

  @override
  void initState() {
    super.initState();
    _sendImageToYolo();
    // testAPIConnection();
  }

  Future<void> _sendImageToYolo() async {
    var baseUrl = dotenv.env['API_BASE_URL'] ?? "http://localhost:8000";
    var uri = Uri.parse("$baseUrl/segment");

    try {
      print("Sending POST request to: $uri");

      var request = http.MultipartRequest("POST", uri);
      var stream = http.ByteStream(File(widget.imagePath).openRead());
      var length = await File(widget.imagePath).length();
      var multipartFile = http.MultipartFile('file', stream, length,
          filename: basename(widget.imagePath));
      request.files.add(multipartFile);

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print("Raw API Response: $responseBody");
      print("Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = json.decode(responseBody);
        // print("Parsed JSON: $data");

        if (data.containsKey('cropped_image_path') &&
            data['cropped_image_path'] != null) {
          String apiImagePath =
              data['cropped_image_path']; // Direct API image URL
          print("Image URL received: $apiImagePath");

          // Set the image path to API URL
          setState(() {
            _segmentedImagePath =
                "$apiImagePath?t=${DateTime.now().millisecondsSinceEpoch}";
            _isProcessing = false;
          });
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("YOLO Object Detection")),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Text("Original Image",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Center(
                child: Image.file(File(widget.imagePath), width: 300),
              ),
              SizedBox(height: 20),
              _isProcessing
                  ? CircularProgressIndicator()
                  : _segmentedImagePath != null
                      ? Column(
                          children: [
                            Text("Segmented Image",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Center(
                              child: Image.network(
                                _segmentedImagePath!,
                                key: ValueKey(_segmentedImagePath),
                                width: 300,
                                errorBuilder: (context, error, stackTrace) {
                                  return Text("Failed to load image");
                                },
                              ),
                            ),
                          ],
                        )
                      : Text("No segmented image available."),
            ],
          ),
        ),
      ),
    );
  }
}


  // Future<void> testAPIConnection() async {
  //   var url = "http://0.0.0.0:8000/docs";
  //   try {
  //     print("Testing API connection to: $url");
  //     final response =
  //         await http.get(Uri.parse(url)).timeout(Duration(seconds: 10));
 
  //     print("API Connection Status Code: ${response.statusCode}");
  //     print("API Response: ${response.body}");
  //   } catch (e, stackTrace) {
  //     print("Error connecting to API: $e");
  //     print(stackTrace);
  //   }
  // }