import 'dart:io';
import 'package:flutter/material.dart';
import '../services/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          margin: const EdgeInsets.all(10),
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.indigoAccent,
              width: 3.0,
            ),
          ),
          child: IconButton(
            padding: const EdgeInsets.all(0),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePicture()),
              );
            },
            icon: const Hero(
              tag: 'foto',
              child: CircleAvatar(
                backgroundImage: ResizeImage(
                  AssetImage('images/pepoclown.jpg'),
                  width: 200,
                  height: 200,
                ),
                radius: 50,
              ),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Ismaber#1234',
              style: TextStyle(
                color: Colors.indigoAccent,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'El puto amo',
              style: TextStyle(
                color: Colors.blueGrey,
                fontSize: 18,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ProfilePicture extends StatefulWidget {
  const ProfilePicture({super.key});

  @override
  State<ProfilePicture> createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  File? image;

  pickFromCamera(BuildContext context) async {
    File? aux;
    aux = await pickImageFromCamera(context);
    setState(() {
      image = aux;
    });
    if (context.mounted) Navigator.pop(context);
  }

  /// Get from Camera
  pickFromGallery(BuildContext context) async {
    File? aux;
    aux = await pickImageFromGallery(context);
    setState(() {
      image = aux;
    });
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 300,
              width: double.infinity,
              child: image == null
                  ? IconButton(
                padding: const EdgeInsets.all(0),
                onPressed: () {
                  openDialog();
                },
                iconSize: 300,
                icon: const Hero(
                  tag: 'foto',
                  child: CircleAvatar(
                    backgroundImage: ResizeImage(
                      AssetImage('images/pepoclown.jpg'),
                      width: 300,
                      height: 300,
                    ),
                    radius: 100,
                  ),
                ),
              )
                  : IconButton(
                padding: const EdgeInsets.all(0),
                onPressed: () {
                  openDialog();
                },
                iconSize: 300,
                icon: Hero(
                  tag: 'foto',
                  child: CircleAvatar(
                    backgroundImage: FileImage(image!),
                    radius: 100,
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nickname',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextField(
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Ismaber',
                    ),
                  ),
                  Container(
                    color: Colors.indigoAccent,
                    height: 1,
                  ),
                  const Text(
                    'Descripción',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextField(
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Sobre mí',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future openDialog() => showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Elegir foto de perfil'),
      scrollable: true,
      actionsAlignment: MainAxisAlignment.spaceAround,
      actions: [
        FilledButton(
          onPressed: () {
            pickFromGallery(context);
          },
          child: const Text('Galería'),
        ),
        FilledButton(
          onPressed: () {
            pickFromCamera(context);
          },
          child: const Text('Cámara'),
        ),
      ],
    ),
  );
}