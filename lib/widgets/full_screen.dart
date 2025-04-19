import 'package:flutter/material.dart';

class FullScreen extends StatelessWidget {
  final child;

  // Makes the child stretch to the size of the screen.
  const FullScreen({
    super.key,
    required Widget this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height,
        width: MediaQuery.sizeOf(context).width,
        child: child,
      ),
    );
  }
}
