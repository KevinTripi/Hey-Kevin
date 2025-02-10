import 'package:flutter/material.dart';

class KevInfoCard extends StatelessWidget {
  final String title, body;

  // Makes the child stretch to the size of the screen.
  const KevInfoCard({
    super.key,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(textAlign: TextAlign.center, title),
      subtitle: Text(body),
    );
  }
}
