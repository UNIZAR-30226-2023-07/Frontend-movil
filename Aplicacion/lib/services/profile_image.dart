import 'package:flutter/material.dart';

class ProfileImage {

  static String image = 'images/pepoclown.jpg';

  static const urls = {
    0:'images/pepoclown.jpg',
    1:'images/saul.jpg',
    2:'images/bot.jpg',
    3:'images/jaime.jpg',
    4:'images/lucia.jpg',
    5:'images/patricia.jpg',
  };

  static void changeImage(int option) {
    image = urls[option]!;
  }

  static int getIndex(){
    return urls.values.toList().indexOf(image);
  }

  static String getImage(int index){
    return urls[index]!;
  }
}