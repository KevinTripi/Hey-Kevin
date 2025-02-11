import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hey_kevin/widgets/full_screen.dart';
import 'package:sliding_drawer/sliding_drawer.dart';

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    // Create a drawer controller.
    // Also you can set up the drawer width and
    // the initial state here (optional).
    final SlidingDrawerController _drawerController = SlidingDrawerController(
      isOpenOnInitial: false,
      drawerFraction: 1,
    );

    return Scaffold(
        appBar: AppBar(title: const Text('Display the Picture')),
        // The image is stored as a file on the device. Use the `Image.file`
        // constructor with the given path to display the image.

        body: SlidingDrawer(
          // From https://pub.dev/packages/sliding_drawer
          controller: _drawerController,
          axisDirection: AxisDirection.up,

          // The drawer holds the ListView where our results will sit.
          drawer: ListView(
            physics:
                NeverScrollableScrollPhysics(), // From https://stackoverflow.com/a/51367188
            shrinkWrap:
                true, // From https://www.flutterbeads.com/listview-inside-column-in-flutter/
            children: [
              // https://api.flutter.dev/flutter/material/ListTile/selected.html

              // Title Tile
              ListTile(
                title: Text(textAlign: TextAlign.center, "Brownies"),
                subtitle: Text('I hurt myself thank you'),
                // onTap: () {},
              ),
              // Fact #1 Tile
              ListTile(
                title: Text(textAlign: TextAlign.center, "Fact 1"),
                subtitle: Text('Something about the object\'s color.'),
              ),
              // Fact #2 Tile
              ListTile(
                title: Text(textAlign: TextAlign.center, "Fact 2"),
                subtitle: Text('Fake Review'),
              ),
              // Fact #3 Tile
              ListTile(
                title: Text(textAlign: TextAlign.center, "Fact 3"),
                subtitle: Text(
                    'Whoop, whoop, whoop, whoopum gundam style (AI freestyle)'),
              ),
            ],
          ),

          body: FullScreen(child: Image.file(File(imagePath))),
        ));
  }
}
