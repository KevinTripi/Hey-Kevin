import 'package:flutter/material.dart';

class DisplayTextbox extends StatelessWidget {
  const DisplayTextbox({
    super.key,
    required this.textboxSizeX,
    required this.textboxSizeY,
  });

  final int textboxSizeX;
  final int textboxSizeY;
  final Color textColor = Colors.black;
  final Color textboxColor = Colors.yellow;

  @override
  Widget build(BuildContext context) {
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
              "HI",
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
}
