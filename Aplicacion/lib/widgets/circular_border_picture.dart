import 'package:flutter/material.dart';

class CircularBorderPicture extends StatelessWidget {
  const CircularBorderPicture({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Stack(
        children: [
          const CircleAvatar(
            backgroundImage: ResizeImage(
                AssetImage('images/pepoclown.jpg'),
                width: 120, height: 120
            ),
            radius: 30,
          ),
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.indigoAccent,
                width: 3.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}