import 'package:flutter/material.dart';

class CircularBorderPicture extends StatelessWidget {
  const CircularBorderPicture({super.key, this.width = 60, this.height = 60});

  final int width;
  final int height;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          backgroundImage: ResizeImage(
              const AssetImage('images/pepoclown.jpg'),
              width: width * 2, height: height * 2
          ),
          radius: width / 2,
        ),
        Container(
          height: height * 1.0,
          width: width * 1.0,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.indigoAccent,
              width: 3.0,
            ),
          ),
        ),
      ],
    );
  }
}