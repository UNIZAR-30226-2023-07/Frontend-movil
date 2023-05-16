import 'package:flutter/material.dart';

class Points extends StatelessWidget {
  const Points({super.key, required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 5.0),
      decoration: const BoxDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.all(Radius.circular(50))),
      child: Text('$value'),
    );
  }
}