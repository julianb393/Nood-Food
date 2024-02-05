import 'package:flutter/material.dart';

class StyledText extends StatelessWidget {
  final String text;
  late final TextStyle? Function(BuildContext context)? getStyle;

  StyledText.displayLarge(this.text, {Key? key}) : super(key: key) {
    getStyle = (context) {
      return Theme.of(context).textTheme.displayLarge;
    };
  }

  StyledText.titleLarge(this.text, {Key? key}) : super(key: key) {
    getStyle = (context) {
      return Theme.of(context).textTheme.titleLarge;
    };
  }

  @override
  Widget build(BuildContext context) {
    return Text(text, style: getStyle?.call(context));
  }
}
