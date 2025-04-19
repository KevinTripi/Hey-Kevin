import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hey_kevin/screens/display_screen.dart';
import 'package:hey_kevin/widgets/full_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io' show Platform;

import 'widgets/camera_crosshair.dart';

Color iconColor = Colors.white, buttonBgColor = Colors.orangeAccent;

// Base project from https://docs.flutter.dev/cookbook/plugins/picture-using-camera#complete-example
Future<void> main() async {
  await dotenv.load(fileName: ".env");
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  // The emulator only has a working cameras.last. If you even try to use cameras.first, emulator crashes.
  // final chosenCamera = cameras.last;

  print("CAMMMMERRRRRRRRRRRRAAAAAAAAA\n");
  cameras.forEach(print);

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: TakePictureScreen(
          // Pass the appropriate camera to the TakePictureScreen widget.
          cameras: cameras),
    ),
  );
}

// A screen that allows users to take a picture using a given camera.
class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({super.key, required this.cameras});

  final List<CameraDescription> cameras;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  int whichCamera = 0;
  int displayRotations = 0;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  void initCamera() {
    // try {
    //   _controller.dispose();
    // } catch (e) {
    //   print("Tried to dispose _controller:\n$e");
    // }

    setState(() {
      // To display the current output from the Camera,
      // create a CameraController.
      _controller = CameraController(
        // Get a specific camera from the list of available cameras.
        widget.cameras[whichCamera %
            widget.cameras.length], // using modulus ensure that index < length.
        // Define the resolution to use.
        ResolutionPreset.ultraHigh,
      );

      // Next, initialize the controller. This returns a Future.
      _initializeControllerFuture = _controller.initialize();
    });
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
      body: FullScreen(
        child: Stack(clipBehavior: Clip.antiAlias, children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                print(
                    "previewSize: ${_controller.value.previewSize?.toString()}  ${_controller.value.aspectRatio}");
                return Stack(children: [
                  UnconstrainedBox(
                    clipBehavior: Clip.antiAlias,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.height /
                          _controller.value.aspectRatio,
                      height: MediaQuery.of(context).size.height,
                      child: RotatedBox(
                        quarterTurns:
                            (displayRotations) // From: https://pub.dev/documentation/flutter_better_camera/latest/camera/CameraDescription-class.html
                                .round(), // From: https://stackoverflow.com/a/20788335
                        child: CameraPreview(_controller),
                      ),
                    ),
                  ),
                  Center(
                    child: SizedBox.square(
                        dimension: 300,
                        child: CameraCrosshair(borderColor: Colors.white)),
                  ),
                ]);
              } else {
                // Otherwise, display a loading indicator.
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    // image: DecorationImage(
                    //     fit: BoxFit.fitWidth,
                    //     image: AssetImage(
                    //         "lib/res/pexels-fwstudio-33348-164005.jpg")),
                    // border: Border.all(color: Colors.blue, width: 5)
                    ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FloatingActionButton(
                        backgroundColor: buttonBgColor,
                        onPressed: () {
                          whichCamera++;
                          print("whichCamera: $whichCamera");
                          initCamera();
                        },
                        heroTag: null,
                        child: Icon(
                          Icons.flip_camera_ios_sharp,
                          color: iconColor,
                          size: 40,
                        )),
                    FloatingActionButton.large(
                      shape: CircleBorder(),
                      backgroundColor: buttonBgColor,
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
                      child: Icon(
                        size: 90,
                        Icons.circle_outlined,
                        color: iconColor,
                      ),
                    ),
                    GestureDetector(
                      onLongPress: () {
                        // Long pressing returns the screen rotation to default.
                        displayRotations = 0;
                        initCamera();
                      },
                      onTap: () {
                        // Tapping rotates screen 90 degress clockwise.
                        displayRotations = (displayRotations + 1) % 4;
                        initCamera();
                      },
                      child: FloatingActionButton(
                        backgroundColor: buttonBgColor,
                        onPressed: null,
                        heroTag: null,
                        child: Icon(
                          Icons.rotate_90_degrees_cw,
                          color: iconColor,
                          size: 40,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
