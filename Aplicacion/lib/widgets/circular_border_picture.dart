import 'package:flutter/material.dart';

class CircularBorderPicture extends StatelessWidget {
  const CircularBorderPicture({super.key});

  final int _width = 60;
  final int _height = 60;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height * 1.5,
      child: Stack(
        children: [
          CircleAvatar(
            backgroundImage: ResizeImage(
                const AssetImage('images/pepoclown.jpg'),
                width: _width * 2, height: _height * 2
            ),
            radius: _width / 2,
          ),
          Container(
            height: _height * 1.0,
            width: _width * 1.0,
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