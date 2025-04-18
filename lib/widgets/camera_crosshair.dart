import 'package:flutter/material.dart';

class CameraCrosshair extends StatelessWidget {
  final Color borderColor;

  const CameraCrosshair({super.key, this.borderColor = Colors.black});

  final double borderWidth = 5;
  final double borderLength = 40;
  final double borderOpacity = 0.5;
  final double dotSize = 15;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: borderOpacity,
      child: Stack(children: [
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            decoration: BoxDecoration(
              // idea from https://www.kindacode.com/article/flutter-container-border-examples
              border: BorderDirectional(
                top: BorderSide(width: borderWidth, color: borderColor),
                start: BorderSide(width: borderWidth, color: borderColor),
              ),
            ),
            child: SizedBox.square(
              dimension: borderLength,
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              border: BorderDirectional(
                top: BorderSide(width: borderWidth, color: borderColor),
                end: BorderSide(width: borderWidth, color: borderColor),
              ),
            ),
            child: SizedBox.square(
              dimension: borderLength,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: Container(
            decoration: BoxDecoration(
              border: BorderDirectional(
                bottom: BorderSide(width: borderWidth, color: borderColor),
                start: BorderSide(width: borderWidth, color: borderColor),
              ),
            ),
            child: SizedBox.square(
              dimension: borderLength,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              border: BorderDirectional(
                bottom: BorderSide(width: borderWidth, color: borderColor),
                end: BorderSide(width: borderWidth, color: borderColor),
              ),
            ),
            child: SizedBox.square(
              dimension: borderLength,
            ),
          ),
        ),
        Center(
            child: Icon(
          Icons.circle,
          size: dotSize,
        )),
      ]),
    );
  }
}
