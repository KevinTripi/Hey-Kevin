import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hey_kevin/utils/yolo_service.dart'; // Import API service

class ObjectDetectionScreen extends StatefulWidget {
  final String imagePath;
  const ObjectDetectionScreen({Key? key, required this.imagePath}) : super(key: key);

  @override
  _ObjectDetectionScreenState createState() => _ObjectDetectionScreenState();
}

class _ObjectDetectionScreenState extends State<ObjectDetectionScreen> {
  final YoloService _yoloService = YoloService(); // Create an instance of YoloService
  bool _isProcessing = true;
  String? _segmentedImagePath;

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  Future<void> _processImage() async {
    String? segmentedImage = await _yoloService.sendImageToYolo(widget.imagePath);
    if (segmentedImage != null) {
      setState(() {
        _segmentedImagePath = segmentedImage;
        _isProcessing = false;
      });
    } else {
      setState(() {
        _isProcessing = false;
      });
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
              Text("Original Image", style: TextStyle(fontWeight: FontWeight.bold)),
              Center(child: Image.file(File(widget.imagePath), width: 300)),
              SizedBox(height: 20),
              _isProcessing
                  ? CircularProgressIndicator()
                  : _segmentedImagePath != null
                      ? Column(
                          children: [
                            Text("Segmented Image", style: TextStyle(fontWeight: FontWeight.bold)),
                            Center(
                              child: Image.network(
                                _segmentedImagePath!,
                                key: ValueKey(_segmentedImagePath), // Force refresh
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
