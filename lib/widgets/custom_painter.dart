import 'package:flutter/material.dart';

// From https://codewithandrea.com/videos/flutter-custom-painting-do-not-fear-canvas/
class ObjOutliner extends CustomPainter {
  // Where all the paint stuff goes
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..color = Colors.yellow;

    // canvas.drawCircle(Offset(size.width / 2, size.height / 2), 20, paint);

    canvas.drawLine(Offset.zero, Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  // For if was stateless
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return false;
    throw UnimplementedError();
  }
}
