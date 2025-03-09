import 'package:flutter/material.dart';

// From https://codewithandrea.com/videos/flutter-custom-painting-do-not-fear-canvas/
class ObjOutliner extends CustomPainter {
  /* 
  I believe that images (in openCV) are represented in a 2D numpy array.
  Each index is an int[3] with an index for this pixel's red, blue, and green values.
  In other words, if imgFromCV = int[height][width][3], imgFromCV[i][j] = [b, g, r] (for that specific pixel)
  Also note it wouldn't be an int[][][], but a uint8[][][].
  */
  // var outlineArr;

  // ObjOutliner(outlineArr) {
  //   this.outlineArr;
  // }

  // Where all the paint stuff goes
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.yellow;

    // canvas.drawCircle(Offset(size.width / 2, size.height / 2), 20, paint);

    // Draws cross to show dimensions of painter
    canvas.drawLine(Offset.zero, Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);

    // for (int i = 0; i < outlineArr.length - 1; i++) {
    //   var p1 = Offset(outlineArr[0])
    //   if (outlineArr[i] < )
    //   canvas.drawLine(p1, p2, paint)
    // }
  }

  // For if was stateless
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
    throw UnimplementedError();
  }
}
