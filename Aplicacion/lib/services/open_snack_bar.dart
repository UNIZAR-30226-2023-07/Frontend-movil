import 'package:flutter/material.dart';

void openSnackBar(BuildContext context, Widget content) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: content,
      showCloseIcon: true,
    ),
  );
}