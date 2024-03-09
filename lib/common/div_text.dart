import 'package:flutter/material.dart';

class DivText extends StatelessWidget {
  final String text;
  const DivText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(text),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}
