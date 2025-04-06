import 'dart:ffi';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sliding_drawer/sliding_drawer.dart';
import 'dart:ui' as ui;

import 'package:hey_kevin/widgets/kev_info_card.dart';
import 'package:hey_kevin/widgets/full_screen.dart';
import '../widgets/textbox_pointer.dart';
import '../util/bill_api_call.dart';
import '../util/ammar_api_call.dart';

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  State<DisplayPictureScreen> createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  late var kevGooseJson;
  late var gptJson;
  late var commentJson;
  bool isSegmentLoading = true;
  bool isChatGptLoading = true;
  int intervalTime = 5;
  String segImgPath = "";

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    // Unwrap Future<>: https://stackoverflow.com/a/60438653
    // Make nonnullable: https://stackoverflow.com/a/67968917
    kevGooseJson = jsonDecode(await sendImageToSegment(widget.imagePath) ?? "");
    // print("maskData: ${kevGooseJson}");

    // from https://stackoverflow.com/a/68390020
    kevGooseJson.forEach((key, value) {
      print("kevGooseJson[$key]: $value");
    });

    setState(() {
      isSegmentLoading = false;
    });

    //
    //

    segImgPath =
        "https://www.kevinthegoose.com/images/${kevGooseJson['session_id']!}.jpg";

    //
    //

    gptJson = await fetchGptResponse(kevGooseJson['session_id']);
    // print("Commentjson original return: ${commentJson!}");
    var startTime = DateTime.now();

    while (gptJson == null) {
      print("gptJson didn't return. Trying again in $intervalTime sec.");
      sleep(Duration(seconds: intervalTime));
      gptJson = await fetchGptResponse(kevGooseJson['session_id']);
      if (DateTime.now().difference(startTime).inMilliseconds / 1000 > 30) {
        print("gpjJson took too long. Returning.");
        return;
      }
    }

    print("gptJson returned 200.\ngptJson: $gptJson");
    gptJson =
        jsonDecode(await fetchGptResponse(kevGooseJson['session_id']) ?? "");

    commentJson = gptJson['comments'];

    setState(() {
      isChatGptLoading = false;
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

    return Scaffold(
        appBar: AppBar(title: const Text('Display the Picture')),
        // The image is stored as a file on the device. Use the `Image.file`
        // constructor with the given path to display the image.

        body: SlidingDrawer(
          // From https://pub.dev/packages/sliding_drawer
          controller: _drawerController,
          axisDirection: AxisDirection.up,

          // The drawer holds the ListView where our results will sit.
          drawer: isChatGptLoading
              ? Center(
                  child: Center(child: Text("Generating funny comments...")),
                )
              : ListView(
                  physics:
                      NeverScrollableScrollPhysics(), // From https://stackoverflow.com/a/51367188
                  shrinkWrap:
                      true, // From https://www.flutterbeads.com/listview-inside-column-in-flutter/
                  children: [
                    // Title Tile
                    KevInfoCard(title: gptJson['label'], body: ""),
                    // Fact #1 Tile
                    KevInfoCard(
                        title: 'sarcastic:', body: commentJson['sarcastic']),
                    // Fact #2 Tile
                    KevInfoCard(title: 'witty:', body: commentJson['witty']),
                    // Fact #3 Tile
                    KevInfoCard(title: 'funny:', body: commentJson['funny']),
                  ],
                ),
          body: Center(
            child: Container(
              color: Colors.red,
              // Reason I'm not using a FutureBuilder is to use the constraints argument from LayoutBuilder.
              // Otherwise I'm using it similarly. Works since setState rebuilds widgets.
              child: LayoutBuilder(builder: (context, constraints) {
                Image displayImage = Image.file(
                  File(widget.imagePath),
                  fit: BoxFit.cover,
                );

                if (isSegmentLoading) {
                  return Stack(children: [
                    displayImage,
                    Center(child: CircularProgressIndicator())
                  ]);
                } else {
                  // Bill returns the picture with the mask.
                  print("Fetching image from path: $segImgPath");
                  // From https://github.com/KevinTripi/Hey-Kevin/blob/bill-api-test/lib/screens/object_detection_screen.dart
                  displayImage = Image.network(segImgPath);

                  // From: https://flutterfixes.com/flutter-get-widget-size-image-file/
                  print(
                      "Constraints: ${constraints.maxWidth}, ${constraints.maxHeight}");

                  List<dynamic> maskArr =
                      jsonDecode(kevGooseJson['mask'])['nums'][0];

                  print("maskArr.length: ${maskArr.length}");
                  print("maskArr[0].length: ${maskArr[0].length}");

                  (int, int) p1 = (-1, -1),
                      p2 = (-1, -1),
                      p3 = (-1, -1),
                      pMaskStart = (-1, -1),
                      pMaskEnd = (-1, -1),
                      center = (
                        (constraints.maxWidth / 2).round(),
                        (constraints.maxHeight / 2).round()
                      );

                  double imgRatioHeight =
                      constraints.maxHeight / maskArr.length;
                  double imgRatioWidth =
                      constraints.maxWidth / maskArr[0].length;
                  // TODO: The mask size (1920 x 1080 in my case) doesn't match the actual display size (411.4 x 731.4)
                  // Removing Box.fit doesn't work. Both are the same ratio though...
                  // 731.4 / 1920 = 0.3809375, could I multiply the index by this to map it to the screen?
                  for (var i = 0; i < maskArr.length; i++) {
                    for (var j = 0; j < maskArr[i].length; j++) {
                      if (maskArr[i][j]) {
                        print("pMaskStart original points: ($i, $j)");
                        pMaskStart = (
                          (j * imgRatioWidth).round(),
                          (i * imgRatioHeight).round()
                        );
                        break;
                      }
                    }
                    if (pMaskStart != (-1, -1)) {
                      break;
                    }
                  }
                  print("pMaskStart: $pMaskStart");

                  for (var i = (maskArr.length - 1).round(); i >= 0; i--) {
                    for (var j = (maskArr[i].length - 1).round(); j >= 0; j--) {
                      if (maskArr[i][j]) {
                        print("pMaskEnd original points: ($i, $j)");
                        pMaskEnd = (
                          (j * imgRatioWidth).round(),
                          (i * imgRatioHeight).round()
                        );
                        break;
                      }
                    }
                    if (pMaskEnd != (-1, -1)) {
                      break;
                    }
                  }
                  print("pMaskEnd: $pMaskEnd");

                  // while (p1.isEmpty && p2.isEmpty && p3.isEmpty) {
                  //   List<int> tryPoint = [Random().nextInt(), ];
                  //   if ()
                  // }

                  // Simplified from: https://medium.com/flutter-community/a-deep-dive-into-custompaint-in-flutter-47ab44e3f216
                  // Error prevented by ensuring image is loaded (by isLoading) before calling CustomPaint.
                  return CustomPaint(
                      foregroundPainter: TextboxPointer([
                        [
                          [pMaskStart.$1, pMaskStart.$2],
                          [constraints.maxWidth, 0],
                          "start"
                        ],
                        [
                          [pMaskEnd.$1, pMaskEnd.$2],
                          [0, constraints.maxHeight],
                          "end"
                        ],
                      ]),
                      child: displayImage);
                  // return displayImage;
                }
              }),
            ),
          ),
        ));
  }
}
