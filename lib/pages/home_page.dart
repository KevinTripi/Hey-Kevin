import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';

class HOmePage extends StatefulWidget {
  const HOmePage({super.key});

  @override
  State<HOmePage> createState() => _HOmePageState();
}

class _HOmePageState extends State<HOmePage> {
  List<CameraDescription> cameras = [];
  CameraController? cameraController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setupCameraController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    if (cameraController == null ||
        cameraController?.value.isInitialized == false) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SafeArea(
      child: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.30,
              width: MediaQuery.sizeOf(context).width * 0.80,
              child: CameraPreview(
                cameraController!,
              ),
            ),
            IconButton(
              onPressed: () async {
                XFile picture = await cameraController!.takePicture();
                Gal.putImage(picture.path);
              },
              iconSize: 100,
              icon: Icon(
                Icons.camera,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setupCameraController() async {
    List<CameraDescription> _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      setState(() {
        cameras = _cameras;
        cameraController = CameraController(
          _cameras.last,
          ResolutionPreset.high,
        );
      });
      cameraController?.initialize().then((_) {
        setState(() {});
      });
    }
  }
}
