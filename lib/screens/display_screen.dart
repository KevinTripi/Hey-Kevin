import 'dart:ffi';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sliding_drawer/sliding_drawer.dart';

import 'package:hey_kevin/widgets/kev_info_card.dart';
import 'package:hey_kevin/widgets/full_screen.dart';
import '../widgets/custom_painter.dart';
import '../openAI/testingAI.dart';
import '../bing_api/bing_api.dart';

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

    // in the form of numpy json array. if any pixel is [0, 0, 0], the mask isn't there.
    final imgMaskJson = jsonEncode({
      "image": [
        [
          [255, 0, 0],
          [0, 255, 0],
          [0, 0, 255]
        ],
        [
          [255, 255, 0],
          [0, 255, 255],
          [255, 0, 255]
        ],
        [
          [128, 128, 128],
          [64, 64, 64],
          [0, 0, 0]
        ]
      ]
    });

    return Scaffold(
        appBar: AppBar(title: const Text('Display the Picture')),
        // The image is stored as a file on the device. Use the `Image.file`
        // constructor with the given path to display the image.

        body: SlidingDrawer(
          // From https://pub.dev/packages/sliding_drawer
          controller: _drawerController,
          axisDirection: AxisDirection.up,

          // The drawer holds the ListView where our results will sit.
          drawer: FutureBuilder(
              future: singleRunGetGptComments('Car'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator()); // Loading state
                } else if (snapshot.hasError) {
                  return Center(
                      child: Text("Error: ${snapshot.error}")); // Error state
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                      child: Text("No data available")); // Empty state
                }

                return ListView.builder(
                  physics:
                      NeverScrollableScrollPhysics(), // From https://stackoverflow.com/a/51367188
                  shrinkWrap:
                      true, // From https://www.flutterbeads.com/listview-inside-column-in-flutter/
                  itemBuilder: (context, index) {
                    // print("build index: $index");
                    if (index < snapshot.data!.length) {
                      return KevInfoCard(
                          title: snapshot.data![index][0],
                          body: snapshot.data![index][1]);
                    }
                  },
                );
              }),
          body: Center(
            child: Container(
              color: Colors.red,
              child: Stack(children: [
                Center(
                    // Can't figure out how to keep the full image on screen and have the CustomPaint match it's dimensions.
                    child: Image.file(
                  width: double.infinity,
                  height: double.infinity,
                  File(imagePath),
                  fit: BoxFit.cover,
                )),
                SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: CustomPaint(
                    painter: ObjOutliner([200, 400], [0100, 200]),
                  ),
                )
              ]),
            ),
          ),
        ));
  }
}
