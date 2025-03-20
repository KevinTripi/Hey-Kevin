import 'dart:ffi';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sliding_drawer/sliding_drawer.dart';

import 'package:hey_kevin/widgets/kev_info_card.dart';
import 'package:hey_kevin/widgets/full_screen.dart';
import '../openAI/testingAI.dart';
import '../bing_api/bing_api.dart';
import '../widgets/textbox_pointer.dart';

class DisplayPictureScreen extends StatefulWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  State<DisplayPictureScreen> createState() => _DisplayPictureScreenState();
}

class _DisplayPictureScreenState extends State<DisplayPictureScreen> {
  List<List<String>> gptResults = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    // This is where Ammar/Alex's GPT comments come from.
    List<List<String>> result = await singleRunGetGptComments('Car');

    // Ensures all async calls are finished before trying to display the data.
    setState(() {
      gptResults = result;
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
          // The populated data comes from GPT.
          drawer: isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : ListView.builder(
                  physics:
                      NeverScrollableScrollPhysics(), // From https://stackoverflow.com/a/51367188
                  shrinkWrap:
                      true, // From https://www.flutterbeads.com/listview-inside-column-in-flutter/
                  itemBuilder: (context, index) {
                    // This format of List<List<String>> may be changed in the future.
                    // print("build index: $index");
                    if (index < gptResults.length) {
                      return KevInfoCard(
                          title: gptResults[index][0],
                          body: gptResults[index][1]);
                    }
                  },
                ),
          body: Center(
            child: Container(
              color: Colors.red,
              child: Stack(children: [
                Center(
                    // Can't figure out how to keep the full image on screen and have the CustomPaint match it's dimensions.
                    child: Image.file(
                  width: double.infinity,
                  height: double.infinity,
                  File(widget.imagePath),
                  fit: BoxFit.cover,
                )),
                SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: CustomPaint(
                    painter: TextboxPointer([200, 400], [200, 200], "Testing"),
                  ),
                )
              ]),
            ),
          ),
        ));
  }
}
