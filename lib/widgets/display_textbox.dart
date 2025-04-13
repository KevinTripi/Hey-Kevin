import 'package:flutter/material.dart';

import 'package:hey_kevin/widgets/textbox_pointer.dart';

class DisplayTextboxes extends StatelessWidget {
  const DisplayTextboxes({
    super.key,
    required this.displayImage,
    required this.maskPoints,
    required this.textboxPoints,
  });

  final int textboxSizeX = 100;
  final int textboxSizeY = 30;
  final Color textColor = Colors.black;
  final Color textboxColor = Colors.yellow;

  final List<(int, int)> maskPoints;
  final List<(int, int)> textboxPoints;

  final Widget displayImage;

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      CustomPaint(
          foregroundPainter:
              TextboxPointer(convertTupleToList(maskPoints, textboxPoints)),
          child: displayImage),
      Positioned(
        left: textboxPoints[0].$1.toDouble(),
        top: textboxPoints[0].$2.toDouble(),
        child: GestureDetector(
          onTap: () {
            print("test1!");
          },
          child: buildTextbox("Hi!"),
        ),
      ),
      Positioned(
        left: textboxPoints[1].$1.toDouble(),
        top: textboxPoints[1].$2.toDouble(),
        child: GestureDetector(
          onTap: () {
            print("test2!");
          },
          child: buildTextbox("Hi!"),
        ),
      ),
      Positioned(
          left: textboxPoints[2].$1.toDouble(),
          top: textboxPoints[2].$2.toDouble(),
          child: GestureDetector(
            onTap: () {
              print("test3!");
            },
            child: buildTextbox("Hi!"),
          )),
    ]);
  }

  Container buildTextbox(String displayText) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 3),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [textboxColor, textboxColor]),
        borderRadius: BorderRadius.all(Radius.circular(100)),
      ),
      child: SizedBox(
        width: textboxSizeX.toDouble(),
        height: textboxSizeY.toDouble(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              displayText,
              style: TextStyle(fontSize: textboxSizeY - 5, color: textColor),
            ),
            Icon(
              Icons.arrow_drop_down,
              applyTextScaling: true,
              size: textboxSizeY.toDouble(),
              color: textColor,
            )
          ],
        ),
      ),
    );
  }

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
