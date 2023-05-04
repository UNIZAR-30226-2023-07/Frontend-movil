import 'package:flutter/material.dart';

class ProfileImage {

  static String image = 'images/pepoclown.jpg';

  static var urls = {
    0:'images/pepoclown.jpg',
    1:'images/saul.jpg',
    2:'images/bot.jpg',
    3:'images/jaime.jpg',
    4:'images/lucia.jpg',
    5:'images/patricia.jpg',
    //6:'images/jorge.jpg',
    //7:'images/picachu.jpg',
    //8:'images/mondongo.jpg'
  };

  static void prepImages() {
    image = 'images/pepoclown.jpg';
    urls = {
      0:'images/pepoclown.jpg',
      1:'images/saul.jpg',
      2:'images/bot.jpg',
      3:'images/jaime.jpg',
      4:'images/lucia.jpg',
      5:'images/patricia.jpg',
      //6:'images/jorge.jpg',
      //7:'images/picachu.jpg',
      //8:'images/mondongo.jpg'
    };
  }

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