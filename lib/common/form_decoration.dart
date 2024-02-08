import 'package:flutter/material.dart';

/// Decoration used for my forms.
const InputDecoration formDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey, width: 1.0),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.grey, width: 1.0),
  ),
  errorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.red, width: 1.0),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.red, width: 1.0),
  ),
);
