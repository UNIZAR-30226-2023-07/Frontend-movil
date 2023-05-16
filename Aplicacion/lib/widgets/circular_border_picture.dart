import 'package:flutter/material.dart';

class CircularBorderPicture extends StatelessWidget {
  const CircularBorderPicture(
      {super.key, this.image = 'images/pepoclown.jpg', this.size = 60});

  final String image;
  final int size;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          backgroundImage: ResizeImage(
            AssetImage(image),
            width: size * 2, height: size * 2
          ),
          radius: size / 2,
        ),
        Container(
          height: size * 1.0,
          width: size * 1.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme
                  .of(context)
                  .colorScheme
                  .primary,
              width: 3.0,
            ),
          ),
        ),
      ],
    );
  }
}
