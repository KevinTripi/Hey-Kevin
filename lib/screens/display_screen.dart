import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:gal/gal.dart';

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
  String appBarText = "Kevin is thinking...";

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    kevGooseJson = jsonDecode(await sendImageToSegment(widget.imagePath) ?? "");

    kevGooseJson.forEach((key, value) {
      print("kevGooseJson[$key]: $value");
    });

    if (mounted) {
      setState(() {
        isSegmentLoading = false;
      });
    }

    segImgPath = kevGooseJson['segmented_image_path'];

    gptJson = await fetchGptResponse(kevGooseJson['session_id']);
    var startTime = DateTime.now();

    while (gptJson == null) {
      print("gptJson didn't return. Trying again in $intervalTime sec.");
      sleep(Duration(seconds: intervalTime));
      gptJson = await fetchGptResponse(kevGooseJson['session_id']);
      if (DateTime.now().difference(startTime).inMilliseconds / 1000 > 30 || !mounted) {
        print("gpjJson took too long. Returning.");
        return;
      }
    }

    print("gptJson returned 200.\ngptJson: $gptJson");
    gptJson = jsonDecode(await fetchGptResponse(kevGooseJson['session_id']) ?? "");

    commentJson = gptJson['comments'];

    if (mounted) {
      setState(() {
        appBarText = gptJson['label'];
        isChatGptLoading = false;
        print("isChatGptLoading is now false");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appBarText)),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Center(
        child: Container(
          child: LayoutBuilder(builder: (context, constraints) {
            Image displayImage = Image.file(
              File(widget.imagePath),
              fit: BoxFit.cover,
            );

            if (isSegmentLoading) {
              return SafeArea(
                child: Stack(children: [
                  FullScreen(child: Container(color: Color(0xFF006BD9))),
                  Center(
                    child: Image.asset(
                      'res/goose.gif',
                      width: 190,
                      height: 190,
                      fit: BoxFit.cover,
                    ),
                  ),
                ]),
              );
            } else {
              // From: https://flutterfixes.com/flutter-get-widget-size-image-file/
              print("Constraints: ${constraints.maxWidth}, ${constraints.maxHeight}");

              // Gal.putImage(widget.imagePath);
              List<dynamic> maskArr = jsonDecode(kevGooseJson['mask'])['nums'][0];

              (int, int) painterCenter = (
              (constraints.maxWidth / 2).round(),
              (constraints.maxHeight / 2).round()
              );

              double imgRatioHeight = constraints.maxHeight / maskArr.length;
              double imgRatioWidth = constraints.maxWidth / maskArr[0].length;

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

              List<(int, int)> maskPoints = [];

              for (var i = 0; i < 2; i++) {
                while (true) {
                  (int, int) tryPoint = (
                  samBoxTopLeft.$1 + Random().nextInt(samBoxBottomRight.$1 - samBoxTopLeft.$1),
                  samBoxTopLeft.$2 + Random().nextInt(samBoxBottomRight.$2 - samBoxTopLeft.$2)
                  );
                  // print("Trying: $tryPoint");
                  // Note we have to flip the tuple here since the mask is y indexed.

                  if (maskArr[tryPoint.$2][tryPoint.$1]) {
                    print("Random point found: $tryPoint");
                    maskPoints.add((
                    (tryPoint.$1 * imgRatioWidth).round(),
                    (tryPoint.$2 * imgRatioWidth).round(),
                    ));
                    break;
                  }
                }
              }

              if (maskPoints[0].$2 > maskPoints[1].$2) {
                var temp = maskPoints[0];
                maskPoints[0] = maskPoints[1];
                maskPoints[1] = temp;
              }

              print("Fetching image from path: $segImgPath");

              return Image.network(
                segImgPath,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  Offset dragStartPos = Offset.zero;
                  Offset dragEndPos = Offset.zero;

                  Widget swipeDownGestureDetector = FullScreen(
                    child: GestureDetector(
                      onTap: () {},
                      onHorizontalDragEnd: (details) {},
                      onVerticalDragStart: (details) {
                        dragStartPos = details.globalPosition;
                      },
                      onVerticalDragEnd: (details) {
                        dragEndPos = details.globalPosition;
                        if (dragStartPos.dy < dragEndPos.dy) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  );

                  if (loadingProgress == null) {
                    print("isLoadingImg: complete");

                    if (isChatGptLoading) {
                      return Stack(children: [
                        FullScreen(child: displayImage),
                        swipeDownGestureDetector
                      ]);
                    } else {
                      List<String> commentArr = [];
                      gptJson['comments'].forEach((key, value) {
                        commentArr.add(value.toString());
                      });

                      if (gptJson['label'] == "No representative query available") {
                        return Stack(children: [
                          Container(
                              foregroundDecoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [
                                    Colors.black.withAlpha(170),
                                    Colors.black.withAlpha(170)
                                  ])),
                              child: FullScreen(child: child)),
                          Center(
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    border: Border.all(color: Colors.yellow)),
                                child: Text(
                                  "Comment generation failed.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 15, color: Colors.white),
                                ),
                              )),
                          swipeDownGestureDetector,
                        ]);
                      }

                      return Stack(children: [
                        SafeArea(
                            child: DisplayTextboxes(
                              textboxSizeX: (constraints.maxWidth).round(),
                              textboxSizeY: 120,
                              displayImage: child,
                              maskPoints: maskPoints,
                              textboxPoints: [
                                (0, 0),
                                (0, (constraints.maxHeight * 0.8).round()),
                              ],
                              textboxText: commentArr,
                            )),
                        swipeDownGestureDetector
                      ]);
                    }
                  }

                  return Center(
                    child: Image.asset(
                      'res/goose.gif',
                      width: 100,
                      height: 100,
                    ),
                  );
                },
              );
            }
          }),
        ),
      ),
    );
  }
}