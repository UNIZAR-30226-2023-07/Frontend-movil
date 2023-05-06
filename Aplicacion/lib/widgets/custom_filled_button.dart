import 'package:flutter/material.dart';

class CustomFilledButton extends StatelessWidget {
  const CustomFilledButton({super.key, required this.content, required this.onPressed, this.width = 50});

  final Widget? content;
  final void Function()? onPressed;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: width,
      child: FilledButton(
        onPressed: onPressed,
        child: content,
      ),
    );
  }
}