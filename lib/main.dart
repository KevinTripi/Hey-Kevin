import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hey_kevin/screens/display_screen.dart';
import 'package:hey_kevin/widgets/full_screen.dart';

// Base project from https://docs.flutter.dev/cookbook/plugins/picture-using-camera#complete-example
Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  // The emulator only has a working cameras.last. If you even try to use cameras.first, emulator crashes.
  final firstCamera = cameras.last;

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: TakePictureScreen(
        // Pass the appropriate camera to the TakePictureScreen widget.
        camera: firstCamera,
      ),
    ),
  );
}

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
  });

  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.high,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: Stack(children: [
        FullScreen(
          child: FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return RotatedBox(
                  quarterTurns: 1,
                  child: CameraPreview(_controller),
                );
              } else {
                // Otherwise, display a loading indicator.
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
        Positioned(
          bottom: 50,
          left: 0,
          right: 0,
          child: Container(
            margin: EdgeInsets.all(1),
            padding: EdgeInsets.all(5),
            decoration:
                BoxDecoration(border: Border.all(color: Colors.blue, width: 5)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                    onPressed: null,
                    heroTag: null,
                    child: Icon(
                      Icons.image,
                      size: 40,
                    )),
                IconButton(
                  onPressed: () async {
                    // Take the Picture in a try / catch block. If anything goes wrong,
                    // catch the error.
                    try {
                      // Ensure that the camera is initialized.
                      await _initializeControllerFuture;

                      // Attempt to take a picture and get the file `image`
                      // where it was saved.
                      final image = await _controller.takePicture();

                      if (!context.mounted) return;

                      // If the picture was taken, display it on a new screen.
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => DisplayPictureScreen(
                            // Pass the automatically generated path to
                            // the DisplayPictureScreen widget.
                            imagePath: image.path,
                          ),
                        ),
                      );
                    } catch (e) {
                      // If an error occurs, log the error to the console.
                      print(e);
                    }
                  },
                  iconSize: 100,
                  icon: Icon(
                    Icons.camera,
                    color: Colors.red,
                  ),
                ),
                FloatingActionButton(
                  onPressed: null,
                  heroTag: null,
                  child: Icon(
                    Icons.multitrack_audio,
                    size: 40,
                  ),
                ),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
