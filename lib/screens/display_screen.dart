import 'dart:ffi';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hey_kevin/widgets/kev_info_card.dart';
import 'package:hey_kevin/widgets/full_screen.dart';
import 'package:sliding_drawer/sliding_drawer.dart';
import 'dart:ui' as ui;

import '../widgets/textbox_pointer.dart';
import '../util/bill_api_call.dart';

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  State<DisplayPictureScreen> createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  late var maskJson;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    // Unwrap Future<>: https://stackoverflow.com/a/60438653
    // Make nonnullable: https://stackoverflow.com/a/67968917
    maskJson = jsonDecode(await sendImageToSegment(widget.imagePath) ?? "");
    print("maskData: ${maskJson}");

    // Ensures all async calls are finished before trying to display the data.
    setState(() {
      isLoading = false;
    });
  }

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
          body: Center(
            child: Container(
              color: Colors.red,
              // Reason I'm not using a FutureBuilder is to use the constraints argument from LayoutBuilder.
              // Otherwise I'm using it similarly. Works since setState rebuilds widgets.
              child: LayoutBuilder(builder: (context, constraints) {
                if (isLoading) {
                  return Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.cover,
                  );
                } else {
                  // Bill returns the picture with the mask.

                  // From: https://flutterfixes.com/flutter-get-widget-size-image-file/
                  print(
                      "Constraints: ${constraints.maxWidth}, ${constraints.maxHeight}");
                  List<int> p1 = [],
                      p2 = [],
                      p3 = [],
                      pMaskStart = [],
                      pMaskEnd = [],
                      center = [
                        (constraints.maxWidth / 2).round(),
                        (constraints.maxHeight / 2).round()
                      ];

                  List<dynamic> maskArr =
                      jsonDecode(maskJson['mask'])['nums'][0];

                  print("maskArr.length: ${maskArr.length}");
                  print("maskArr[0].length: ${maskArr[0].length}");

                  // TODO: The mask size (1920 x 1080 in my case) doesn't match the actual display size (411.4 x 731.4)
                  for (var i = 0; i < constraints.maxHeight; i++) {
                    for (var j = 0; j < constraints.maxWidth; j++) {
                      if (maskArr[i][j]) {}
                    }
                  }

                  // while (p1.isEmpty && p2.isEmpty && p3.isEmpty) {
                  //   List<int> tryPoint = [Random().nextInt(), ];
                  //   if ()
                  // }

                  // Simplified from: https://medium.com/flutter-community/a-deep-dive-into-custompaint-in-flutter-47ab44e3f216
                  // Error prevented by ensuring image is loaded (by isLoading) before calling CustomPaint.
                  return CustomPaint(
                    foregroundPainter: TextboxPointer([
                      [
                        [200, 400],
                        [200, 200],
                        "Testing"
                      ],
                      [
                        [150, 450],
                        [100, 600],
                        "Testing2"
                      ],
                    ]),
                    child: Image.file(
                      File(widget.imagePath),
                      fit: BoxFit.cover,
                    ),
                  );
                }
              }),
            ),
          ),
        ));
  }
}
