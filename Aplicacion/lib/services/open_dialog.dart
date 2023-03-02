import 'package:flutter/material.dart';

Future openDialog(BuildContext context, Widget dialog) => showDialog(
  context: context,
  builder: (context) => dialog
);