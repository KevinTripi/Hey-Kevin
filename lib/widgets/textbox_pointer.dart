import 'package:flutter/material.dart';

// From https://codewithandrea.com/videos/flutter-custom-painting-do-not-fear-canvas/
class TextboxPointer extends CustomPainter {
  // In the format of TextboxPointer([
  //                    [
  //                      [23, 40], // Pointer start
  //                      [100, 12], // Textbox start
  //                      "hello" // text
  //                    ],
  //                    ...
  //                  ]);
  List<List<dynamic>> textboxPointList;
  late Canvas myCanvas;
  late Size myCanvasSize;

  TextboxPointer(this.textboxPointList);

  // Where all the paint stuff goes
  @override
  void paint(Canvas canvas, Size size) {
    print("Paint size: x: ${size.width} y: ${size.height}");

    myCanvas = canvas;
    myCanvasSize = size;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.yellow;

    for (int i = 0; i < textboxPointList.length; i++) {
      paintPoint(
          Offset(textboxPointList[i][0][0].toDouble(),
              textboxPointList[i][0][1].toDouble()),
          Offset(textboxPointList[i][1][0].toDouble(),
              textboxPointList[i][1][1].toDouble()),
          textboxPointList[i][2].toString(),
          paint);
    }
  }

  // Paints a circle at circOffset, a textbox at textOffset, and line connecting the two.
  void paintPoint(
      Offset circOffset, Offset textOffset, String text, Paint paint) {
    double textboxWidth;
    double textboxHeight;

    // Ensures that the points actually appear on the screen.
    circOffset = Offset(circOffset.dx, circOffset.dy);
    textOffset = Offset(textOffset.dx, textOffset.dy);

    circOffset = offsetOnscreen(circOffset, Size.zero);
    textOffset = offsetOnscreen(textOffset, Size.zero);

    myCanvas.drawCircle(circOffset, 10, paint); // Draws circle
    // Draws textbox, updates textOffset (incase it was moved within the method), instantiates textboxSize.
    (textOffset, (textboxWidth, textboxHeight)) =
        customTextPaint(textOffset, text, paint);

    print("textbox drawn");

    Offset textLineOffset = textOffset;

    // If the circle sits to the right of the text box, draw the line from the right side of the textbox.
    if (circOffset.dx > textLineOffset.dx) {
      textLineOffset =
          Offset(textLineOffset.dx + textboxWidth, textLineOffset.dy);
    }
    // If the circle sits to the below of the text box, draw the line from the bottom side of the textbox.
    if (circOffset.dy > textLineOffset.dy) {
      textLineOffset =
          Offset(textLineOffset.dx, textLineOffset.dy + textboxHeight);
    }
    myCanvas.drawLine(circOffset, textLineOffset, paint); // Draws line
  }

  // Draws the text arg then a border around it. Returns the Offset it started painting at and the size of the box.
  (Offset, (double, double)) customTextPaint(
      Offset offset, String text, Paint paint) {
    var painter = TextPainter(
        text: TextSpan(
            text: text,
            style: TextStyle(
              color: paint.color,
              fontSize: 35,
            )),
        textDirection: TextDirection.ltr);
    painter.layout();

    Offset newOffset =
        offsetOnscreen(offset, Size(painter.width + 10, painter.height + 10));

    myCanvas.drawRect(
        Rect.fromLTWH(
          newOffset.dx - 5,
          newOffset.dy - 5,
          painter.size.width + 10,
          painter.size.height + 10,
        ),
        paint);
    painter.paint(myCanvas, newOffset);

    return (newOffset, (painter.width, painter.height));
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
