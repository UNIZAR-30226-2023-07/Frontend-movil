import 'package:flutter/material.dart';

class CustomFilledButton extends StatelessWidget {
  const CustomFilledButton({super.key, required this.content, required this.onPressed, this.height = 50});

  final Widget? content;
  final void Function()? onPressed;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: FilledButton(
        onPressed: onPressed,
        child: content,
      ),
    );
  }
}