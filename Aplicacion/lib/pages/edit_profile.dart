import 'dart:io';
import 'package:flutter/material.dart';
import 'package:untitled/dialogs/save_changes_dialog.dart';
import 'package:untitled/services/open_dialog.dart';
import '../services/image_picker.dart';
import '../widgets/custom_filled_button.dart';

class EditProfilePage extends StatefulWidget {
  final String nombre, foto, desc, email;
  EditProfilePage({required this.nombre, required this.foto, required this.desc, required this.email});

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
                MaterialPageRoute(builder: (context) => ProfilePicture(email: widget.email)),
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
          children: [
            Text(
              widget.nombre,
              style: const TextStyle(
                color: Colors.indigoAccent,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              widget.desc,
              style: const TextStyle(
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
  final String email;
  const ProfilePicture({required this.email});

  @override
  State<ProfilePicture> createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  File? image;
  final TextEditingController _nombre = TextEditingController();
  final TextEditingController _descripcion = TextEditingController();

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
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              SizedBox(
                height: 250,
                width: double.infinity,
                child: image == null
                    ? IconButton(
                  padding: const EdgeInsets.all(0),
                  onPressed: () {
                    _openBottomSheet();
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
                    _openBottomSheet();
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
              SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text( 'Nickname', style: Theme.of(context).textTheme.headlineMedium),
                    TextField(
                      controller: _nombre,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'apodo',
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
                      controller: _descripcion,
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
                  openDialog(context, SaveChangesDialog(nombre: _nombre.text, desc: _descripcion.text, foto: "foto",email: widget.email));
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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