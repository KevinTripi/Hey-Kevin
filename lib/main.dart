import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import 'package:camera/camera.dart';
import 'package:gal/gal.dart';

/*
UNRELATED:
https://docs.flutter.dev/cookbook/plugins/picture-using-camera#6-display-the-picture-with-an-image-widget
Takes a picture but doesn't save it to photos, a possible direction if we want.
*/
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(title: 'My first flutter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<CameraDescription> cameras = [];
  CameraController? cameraController;

  double _bottomVal = 0;
  bool _isListHidden = true;
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _setupCameraController();
    // _toggleList(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   title: Text(widget.title),
      // ),
      body: Container(
        color: Colors.orangeAccent,
        // Stack from https://stackoverflow.com/a/49839188
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.all(1),
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 9),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 5)),
              child: Center(child: _buildCamera()),
            ),

            // Shutter button, gallery button, etc.
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Container(
                margin: EdgeInsets.all(1),
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 5)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FloatingActionButton(
                        onPressed: null,
                        child: Icon(
                          Icons.image,
                          size: 40,
                        )),
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
                    FloatingActionButton(
                        onPressed: null,
                        child: Icon(
                          Icons.multitrack_audio,
                          size: 40,
                        )),
                  ],
                ),
              ),
            ),

            Positioned(
              top: _bottomVal,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                child: GestureDetector(
                  // From https://stackoverflow.com/a/72678355
                  // Enables onClickListening of entire ListView, rather than using the onTap in ListView.builder, which would activate per item.
                  onTap: () {
                    setState(() {
                      // print(MediaQuery.of(context).size.height);
                      _toggleList(context);
                    });
                  },
                  child: ListView.builder(
                    itemCount: 5,
                    shrinkWrap:
                        true, // From https://www.flutterbeads.com/listview-inside-column-in-flutter/
                    itemBuilder: (context, index) {
                      return ListTile(
                        title:
                            Text(textAlign: TextAlign.center, "Text ${index}"),
                        // https://api.flutter.dev/flutter/material/ListTile/selected.html
                        // onTap: () {
                        //   setState(() {
                        //     // print(MediaQuery.of(context).size.height);
                        //     _toggleList(context);
                        //   });
                        //   // print('object');
                        // },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleList(BuildContext context) {
    setState(() {
      if (_isListHidden) {
        // From: https://medium.com/flutter-community/a-guide-to-using-screensize-in-flutter-a-more-readable-approach-901e82556195
        // NOTE THAT THIS .size.height DOESN'T ACCOUNT FOR scaffold.appBar; i.e., if using with appBar, need to add appBar's height into equation.
        _bottomVal = MediaQuery.of(context).size.height * (19 / 20);
      } else {
        _bottomVal = 0;
      }
      _isListHidden = !_isListHidden;
      // print('_isListHidden: $_isListHidden -- _bottomVal: $_bottomVal');
    });
  }

  Widget _buildCamera() {
    if (cameraController == null ||
        cameraController?.value.isInitialized == false) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SafeArea(
      child: SizedBox(
          height: MediaQuery.sizeOf(context).height,
          width: MediaQuery.sizeOf(context).width,
          child: RotatedBox(
              quarterTurns: 1, child: CameraPreview(cameraController!))),
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
