import 'package:flutter/material.dart';

// From https://codewithandrea.com/videos/flutter-custom-painting-do-not-fear-canvas/
// TextboxPointer([
//                  [
//                    [23, 40], // Pointer start
//                    [100, 12], // Pointer end
//                  ],
//                  ...
//                ]);
class TextboxPointer extends CustomPainter {
  List<List<dynamic>> textboxPointList;
  late Canvas myCanvas;
  late Size myCanvasSize;

  TextboxPointer(this.textboxPointList);

  final pointerCircleRadius = 7.0;
  final textboxFontSize = 31.0;

  // Where all the paint stuff goes
  @override
  void paint(Canvas canvas, Size size) {
    print("Paint size: x: ${size.width} y: ${size.height}");

    myCanvas = canvas;
    myCanvasSize = size;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;

    for (int i = 0; i < textboxPointList.length; i++) {
      paintPoint(
          Offset(textboxPointList[i][0][0].toDouble(),
              textboxPointList[i][0][1].toDouble()),
          Offset(textboxPointList[i][1][0].toDouble(),
              textboxPointList[i][1][1].toDouble()),
          paint);
    }
  }

  // Paints a circle at circOffset, a textbox at textOffset, and line connecting the two.
  void paintPoint(Offset circOffset, Offset textOffset, Paint paint) {
    // Ensures that the points actually appear on the screen.
    circOffset = offsetOnscreen(circOffset, Size.zero);
    textOffset = offsetOnscreen(textOffset, Size.zero);

    myCanvas.drawCircle(circOffset, pointerCircleRadius, paint); // Draws circle

    myCanvas.drawLine(circOffset, textOffset, paint); // Draws line
  }

  Offset offsetOnscreen(Offset offset, Size objSize) {
    Offset retOffset = offset;

    if (offset.dx + objSize.width >= myCanvasSize.width) {
      retOffset = Offset(myCanvasSize.width - objSize.width, offset.dy);
    }

    if (offset.dy + objSize.height >= myCanvasSize.height) {
      retOffset = Offset(retOffset.dx, myCanvasSize.height - objSize.height);
    }

    return retOffset;
  }

  // For if was stateless
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
    throw UnimplementedError();
  }
}
