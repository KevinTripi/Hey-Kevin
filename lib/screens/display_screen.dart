import 'dart:ffi';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hey_kevin/widgets/kev_info_card.dart';
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

    final testJson = jsonEncode({
      "name": "Rubik's Cube",
      "description":
          "A multicolored 3D puzzle where players must align all six faces by rotating different sections.",
      "gpt_color": "Rubik's Cube—six colors, infinite regret.",
      "gpt_review":
          "Twist, turn, repeat!—because nothing screams fun like scrambling a puzzle you already couldn't solve.",
      "gpt_free":
          "A cube designed to make you question both your intelligence and your eyesight as you swear that yellow and white are the same color."
    });

    final gptJson = jsonDecode(testJson);

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
              // Title Tile
              KevInfoCard(title: gptJson['name'], body: gptJson['description']),
              // Fact #1 Tile
              KevInfoCard(
                  title: 'Colorful Insult:', body: gptJson['gpt_color']),
              // Fact #2 Tile
              KevInfoCard(title: 'Real Review:', body: gptJson['gpt_review']),
              // Fact #3 Tile
              KevInfoCard(title: 'Miscellaneous:', body: gptJson['gpt_free']),
            ],
          ),

          body: FullScreen(
              child: Column(
            children: [
              Image.file(File(imagePath)),
              FractionallySizedBox(
                widthFactor: .7,
                child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(width: 3, color: Colors.orange)),
                    child: Transform.scale(
                      scaleX: 4,
                      child: Icon(
                        Icons.keyboard_arrow_up,
                      ),
                    )),
              ),
            ],
          )),
        ));
  }
}
