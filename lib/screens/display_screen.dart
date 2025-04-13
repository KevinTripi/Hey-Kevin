import 'dart:ffi';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sliding_drawer/sliding_drawer.dart';
import 'dart:ui' as ui;
import 'package:gal/gal.dart';
import 'package:touchable/touchable.dart';

import 'package:hey_kevin/widgets/kev_info_card.dart';
import 'package:hey_kevin/widgets/full_screen.dart';
import '../widgets/textbox_pointer.dart';
import '../util/bill_api_call.dart';
import '../util/ammar_api_call.dart';
import '../widgets/display_textbox.dart';

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

    if (mounted) {
      setState(() {
        isSegmentLoading = false;
      });
    }

    //
    //

    segImgPath =
        "https://www.kevinthegoose.com/images/${kevGooseJson['session_id']!}.jpg";

    //
    //

    return; // todo: delete this once bill get Bing working again.
    gptJson = await fetchGptResponse(kevGooseJson['session_id']);
    // print("Commentjson original return: ${commentJson!}");
    var startTime = DateTime.now();

    while (gptJson == null) {
      print("gptJson didn't return. Trying again in $intervalTime sec.");
      sleep(Duration(seconds: intervalTime));
      gptJson = await fetchGptResponse(kevGooseJson['session_id']);
      if (DateTime.now().difference(startTime).inMilliseconds / 1000 > 30 ||
          !mounted) {
        print("gpjJson took too long. Returning.");
        return;
      }
    }

    print("gptJson returned 200.\ngptJson: $gptJson");
    gptJson =
        jsonDecode(await fetchGptResponse(kevGooseJson['session_id']) ?? "");

    commentJson = gptJson['comments'];

    if (mounted) {
      setState(() {
        isChatGptLoading = false;
        print("isChatGptLoading is now false");
      });
    }
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
                  return SafeArea(
                    child: Stack(children: [
                      displayImage,
                      Center(child: CircularProgressIndicator())
                    ]),
                  );
                } else {
                  // From: https://flutterfixes.com/flutter-get-widget-size-image-file/
                  print(
                      "Constraints: ${constraints.maxWidth}, ${constraints.maxHeight}");

                  List<dynamic> maskArr =
                      jsonDecode(kevGooseJson['mask'])['nums'][0];

                  // Gal.putImage(widget.imagePath);

                  print("maskArr.length: ${maskArr.length}");
                  print("maskArr[0].length: ${maskArr[0].length}");

                  (int, int) maskPoint1 = (-1, -1),
                      maskPoint2 = (-1, -1),
                      maskPoint3 = (-1, -1),
                      textboxPoint1 = (-1, -1),
                      textboxPoint2 = (-1, -1),
                      textboxPoint3 = (-1, -1),
                      painterCenter = (
                        (constraints.maxWidth / 2).round(),
                        (constraints.maxHeight / 2).round()
                      );

                  double imgRatioHeight =
                      constraints.maxHeight / maskArr.length;
                  double imgRatioWidth =
                      constraints.maxWidth / maskArr[0].length;

                  // From "box_size = 700" in https://github.com/EegArlert/hey-kevin-backend/blob/main/image_processing/segmentation.py
                  // Defines the bounding box SAM limits itself to.
                  int samBoxPerimHalf = 700;

                  (int, int) samBoxTopLeft = (
                    ((maskArr[0].length / 2) - samBoxPerimHalf).round(),
                    ((maskArr.length / 2) - samBoxPerimHalf).round(),
                  );
                  (int, int) samBoxBottomRight = (
                    ((maskArr[0].length / 2) + samBoxPerimHalf).round(),
                    ((maskArr.length / 2) + samBoxPerimHalf).round(),
                  );

                  (int, int) randomPointInMask() {
                    while (true) {
                      // format: (x, y), can use samBoxPerimHalf * 2 since it's symmetrical. Same as samBoxBottomRight.$x - samBoxTopLeft.$x
                      (int, int) tryPoint = (
                        samBoxTopLeft.$1 +
                            Random().nextInt(
                                samBoxBottomRight.$1 - samBoxTopLeft.$1),
                        samBoxTopLeft.$2 +
                            Random().nextInt(
                                samBoxBottomRight.$2 - samBoxTopLeft.$2)
                      );
                      // print("Trying: $tryPoint");
                      // Note we have to flip the tuple here since the mask is y indexed.
                      if (maskArr[tryPoint.$2][tryPoint.$1]) {
                        print("Random point found: $tryPoint");
                        return (
                          // (tryPoint.$1 * imgRatioWidth).round(),
                          // (tryPoint.$2 * imgRatioHeight).round(),
                          (tryPoint.$1 * imgRatioWidth).round(),
                          // doesn't imgRatioHeight work...
                          (tryPoint.$2 * imgRatioWidth).round(),
                        );
                      }
                    }
                  }

                  try {
                    maskPoint1 = randomPointInMask();
                    maskPoint2 = randomPointInMask();
                    maskPoint3 = randomPointInMask();
                  } catch (e) {
                    print("Error finding mask random point:\n$e");
                  }

                  textboxPoint1 = (30, (constraints.maxHeight - 400).round());
                  textboxPoint2 = (50, (constraints.maxHeight - 300).round());
                  textboxPoint3 = (0, (constraints.maxHeight - 200).round());

                  int textboxSizeX = 100;
                  int textboxSizeY = 30;

                  // TODO: Fade in segmented from original? https://docs.flutter.dev/cookbook/images/fading-in-images
                  // Bill returns the picture with the mask.
                  print("Fetching image from path: $segImgPath");
                  // From https://github.com/KevinTripi/Hey-Kevin/blob/bill-api-test/lib/screens/object_detection_screen.dart
                  return Image.network(
                    segImgPath,
                    fit: BoxFit.contain,
                    // from https://stackoverflow.com/a/58048926
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        print("isLoadingImg: complete");

                        // Simplified from: https://medium.com/flutter-community/a-deep-dive-into-custompaint-in-flutter-47ab44e3f216
                        // Error prevented by ensuring image is loaded (by isLoading) before calling CustomPaint.
                        if (!isChatGptLoading) {
                          return FullScreen(child: displayImage);
                        } else {
                          return SafeArea(
                            child: Stack(children: [
                              CustomPaint(
                                  foregroundPainter: TextboxPointer([
                                    // [
                                    //   [
                                    //   (samBoxTopLeft.$1 * imgRatioWidth).round(),
                                    //   (samBoxTopLeft.$2 * imgRatioHeight).round(),],
                                    //   [constraints.maxWidth, 0],
                                    //   "start"
                                    // ],
                                    // [
                                    //   [painterCenter.$1, painterCenter.$2],
                                    //   [
                                    //     constraints.maxWidth,
                                    //     constraints.maxHeight / 2
                                    //   ],
                                    //   "center"
                                    // ],
                                    // [
                                    //   [
                                    //   (samBoxBottomRight.$1 * imgRatioWidth).round(),
                                    //   (samBoxBottomRight.$2 * imgRatioHeight).round(),],
                                    //   [0, constraints.maxHeight],
                                    //   "end"
                                    // ],
                                    [
                                      [maskPoint1.$1, maskPoint1.$2],
                                      [
                                        textboxPoint1.$1 + (textboxSizeX / 2),
                                        textboxPoint1.$2 + (textboxSizeY / 2)
                                      ],
                                      "p1"
                                    ],
                                    [
                                      [maskPoint2.$1, maskPoint2.$2],
                                      [
                                        textboxPoint2.$1 + (textboxSizeX / 2),
                                        textboxPoint2.$2 + (textboxSizeY / 2)
                                      ],
                                      "p2"
                                    ],
                                    [
                                      [maskPoint3.$1, maskPoint3.$2],
                                      [
                                        textboxPoint3.$1 + (textboxSizeX / 2),
                                        textboxPoint3.$2 + (textboxSizeY / 2)
                                      ],
                                      "p3"
                                    ],
                                  ]),
                                  child: child),
                              Positioned(
                                left: textboxPoint1.$1.toDouble(),
                                top: textboxPoint1.$2.toDouble(),
                                child: GestureDetector(
                                  onTap: () {
                                    print("test1!");
                                  },
                                  child: DisplayTextbox(
                                      textboxSizeX: textboxSizeX,
                                      textboxSizeY: textboxSizeY),
                                ),
                              ),
                              Positioned(
                                left: textboxPoint2.$1.toDouble(),
                                top: textboxPoint2.$2.toDouble(),
                                child: GestureDetector(
                                  onTap: () {
                                    print("test2!");
                                  },
                                  child: DisplayTextbox(
                                      textboxSizeX: textboxSizeX,
                                      textboxSizeY: textboxSizeY),
                                ),
                              ),
                              Positioned(
                                  left: textboxPoint3.$1.toDouble(),
                                  top: textboxPoint3.$2.toDouble(),
                                  child: GestureDetector(
                                    onTap: () {
                                      print("test3!");
                                    },
                                    child: DisplayTextbox(
                                        textboxSizeX: textboxSizeX,
                                        textboxSizeY: textboxSizeY),
                                  )),
                            ]),
                          );
                        }
                      }
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  );
                }
              }),
            ),
          ),
        ));
  }
}
