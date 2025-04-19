import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:hey_kevin/widgets/full_screen.dart';

import 'package:hey_kevin/widgets/textbox_pointer.dart';

class DisplayTextboxes extends StatelessWidget {
  const DisplayTextboxes({
    super.key,
    required this.textboxSizeX,
    required this.textboxSizeY,
    required this.displayImage,
    required this.maskPoints,
    required this.textboxPoints,
    required this.textboxText,
  });

  final int textboxSizeX;
  final int textboxSizeY;
  final Color textColor = Colors.black;
  final Color textboxColor = Colors.yellow;

  final List<(int, int)> maskPoints;
  final List<(int, int)> textboxPoints;
  final List<String> textboxText;

  final Widget displayImage;

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      CustomPaint(
          foregroundPainter:
              TextboxPointer(convertTupleToList(maskPoints, (textboxPoints))),
          child: displayImage),
      Positioned(
        // left: textboxPoints[0].$1.toDouble(),
        top: textboxPoints[0].$2.toDouble(),
        child: Center(
          child: GestureDetector(
            onTap: () {
              print("test1!");
            },
            child: buildTextbox(context, textboxText[0]),
          ),
        ),
      ),
      Positioned(
        // left: textboxPoints[1].$1.toDouble(),
        bottom: 0,
        child: SafeArea(
          child: GestureDetector(
            onTap: () {
              print("test2!");
            },
            child: buildTextbox(context, textboxText[1]),
          ),
        ),
      ),
      // Positioned(
      //     left: textboxPoints[2].$1.toDouble(),
      //     top: textboxPoints[2].$2.toDouble(),
      //     child: GestureDetector(
      //       onTap: () {
      //         print("test3!");
      //       },
      //       child: buildTextbox("Hi!"),
      //     )),
    ]);
  }

  Widget buildTextbox(BuildContext context, String displayText) {
    return SizedBox(
      width: textboxSizeX.toDouble(),
      height: textboxSizeY.toDouble(),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [textboxColor, textboxColor]),
          borderRadius: BorderRadius.all(Radius.circular(25)),
        ),
        child: AutoSizeText(
          displayText,
          style: TextStyle(color: textColor, fontSize: 30),
        ),
      ),
    );
  }

  // TextboxPointer takes a list of lists as an arugment, but this class is given a list of tuples.
  List<List<dynamic>> convertTupleToList(
      List<(int, int)> listPointer, List<(int, int)> listTextbox) {
    List<List<dynamic>> retList = [];

    for (var i = 0; i < listPointer.length; i++) {
      retList.add([
        [listPointer[i].$1, listPointer[i].$2],
        [
          listTextbox[i].$1 + (textboxSizeX / 2),
          listTextbox[i].$2 + (textboxSizeY / 2)
        ]
      ]);
    }

    return retList;
  }
}
