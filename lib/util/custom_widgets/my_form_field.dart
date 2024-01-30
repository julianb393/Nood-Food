import 'package:flutter/material.dart';

class MyTextFormField extends StatefulWidget {
  final String labelText;
  final Icon? icon;
  final bool hideText;
  final String? Function(String?)? validator;
  const MyTextFormField({
    super.key,
    required this.labelText,
    this.icon,
    this.hideText = false,
    this.validator,
  });

  @override
  State<MyTextFormField> createState() => _MyTextFormFieldState();
}

class _MyTextFormFieldState extends State<MyTextFormField> {
  // Used for toggling text being hidden
  bool _textIsHidden = false;

  void _toggleHiddenText() {
    setState(() {
      _textIsHidden = !_textIsHidden;
    });
  }

  @override
  void initState() {
    super.initState();
    _textIsHidden = widget.hideText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      validator: widget.validator,
      obscureText: _textIsHidden,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.zero,
        prefixIcon: widget.icon,
        suffixIcon: !widget.hideText
            ? null
            : IconButton(
                icon: Icon(_textIsHidden
                    ? Icons.remove_red_eye
                    : Icons.remove_red_eye_outlined),
                onPressed: _toggleHiddenText,
              ),
        labelText: widget.labelText,
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1.0),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 1.0),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 1.0),
        ),
      ),
    );
  }
}
