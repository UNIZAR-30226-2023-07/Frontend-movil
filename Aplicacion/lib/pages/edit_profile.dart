import 'dart:io';
import 'package:flutter/material.dart';
import 'package:untitled/dialogs/save_changes_dialog.dart';
import 'package:untitled/services/open_dialog.dart';
import 'package:untitled/services/profile_image.dart';
import 'package:untitled/widgets/circular_border_picture.dart';
import '../services/image_picker.dart';
import '../widgets/custom_filled_button.dart';

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
            icon: Hero(
              tag: 'foto',
              child: CircleAvatar(
                backgroundImage: ResizeImage(
                  AssetImage(ProfileImage.image),
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
  File? _image;
  String _urlImage = ProfileImage.image;
  bool _tipo = true;

  pickFromCamera(BuildContext context) async {
    File? aux;
    aux = await pickImageFromCamera(context);
    setState(() {
      _tipo = true;
      _image = aux;
    });
    if (context.mounted) Navigator.pop(context);
  }

  // Get from Camera
  pickFromGallery(BuildContext context) async {
    File? aux;
    aux = await pickImageFromGallery(context);
    setState(() {
      _tipo = true;
      _image = aux;
    });
    if (context.mounted) Navigator.pop(context);
  }

  pickFromPredefined(BuildContext context) {
    openDialog(
      context,
      AlertDialog(
        scrollable: true,
        content: SizedBox(
          height: 200,
          width: 350,
          child: GridView.count(
            crossAxisCount: 3, // especifica 3 columnas en cada fila
            children: List.generate(ProfileImage.urls.length, (index) {
              return GestureDetector(
                onTap: () {
                  ProfileImage.changeImage(index);
                  setState(() {
                    _tipo = false;
                    _urlImage = ProfileImage.urls[index]!;
                  });
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Container(
                  margin: const EdgeInsets.all(5.0),
                  child: Center(
                      child: CircularBorderPicture(image: ProfileImage.urls[index]!,width: 100, height: 100,)
                  ),
                )
              );
            }),
          )
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              SizedBox(
                height: 250,
                width: double.infinity,
                child: IconButton(
                  padding: const EdgeInsets.all(0),
                  onPressed: () {
                    _openBottomSheet();
                  },
                  iconSize: 300,
                  icon: Hero(
                    tag: 'foto',
                    child: (_tipo && _image != null)
                      ? CircleAvatar(
                        backgroundImage: FileImage(_image!),
                        radius: 100)
                      : CircleAvatar(
                        backgroundImage: ResizeImage(
                          AssetImage(_urlImage),
                          width: 250,
                          height: 250
                        ),
                        radius: 100,
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nickname', style: Theme.of(context).textTheme.headlineMedium),
                    const TextField(
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Ismaber',
                      ),
                    ),
                    const SizedBox(height: 10,),
                    const Divider(
                      color: Colors.indigoAccent,
                    ),
                    const SizedBox(height: 10,),
                    Text( 'Descripción', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 10,),
                    TextField(
                      keyboardType: TextInputType.text,
                      maxLength: 200,
                      maxLines: 5,
                      minLines: 5,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        hintText: 'Sobre mí',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10,),
              CustomFilledButton(
                content: const Text('Guardar cambios'),
                onPressed: () {
                  openDialog(context, const SaveChangesDialog());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future _openBottomSheet() => showModalBottomSheet(
    context: context,
    builder: (context) => Container(
      padding: const EdgeInsets.all(10),
      height: 250,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text('Seleccionar foto', style: Theme.of(context).textTheme.headlineMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  IconButton(
                    color: Theme.of(context).colorScheme.primary,
                    iconSize: 40,
                    icon: const Icon(Icons.photo),
                    tooltip: 'Galería',
                    onPressed: () {
                      pickFromGallery(context);
                    },
                  ),
                  const Text('Galería'),
                ],
              ),
              Column(
                children: [
                  IconButton(
                    color: Theme.of(context).colorScheme.primary,
                    iconSize: 40,
                    icon: const Icon(Icons.account_circle_rounded),
                    tooltip: 'Predefinidos',
                    onPressed: () {
                      pickFromPredefined(context);
                    },
                  ),
                  const Text('Predefinidos'),
                ],
              ),
              Column(
                children: [
                  IconButton(
                    color: Theme.of(context).colorScheme.primary,
                    iconSize: 40,
                    icon: const Icon(Icons.camera_alt_rounded),
                    tooltip: 'Cámara',
                    onPressed: () {
                      pickFromCamera(context);
                    },
                  ),
                  const Text('Cámara'),
                ],
              ),
            ],
          ),
          CustomFilledButton(
            content: const Text('Cancelar'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    ),
  );
}