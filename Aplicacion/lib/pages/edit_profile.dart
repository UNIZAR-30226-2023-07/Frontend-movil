import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:untitled/dialogs/save_changes_dialog.dart';
import 'package:untitled/services/open_dialog.dart';
import 'package:untitled/services/profile_image.dart';
import 'package:untitled/widgets/circular_border_picture.dart';
import '../services/image_picker.dart';
import '../widgets/custom_filled_button.dart';

class EditProfilePage extends StatefulWidget {
  final String nombre, desc, email, codigo;
  final int foto;
  final bool editActive;

  const EditProfilePage(
      {super.key,
      required this.nombre,
      required this.foto,
      required this.desc,
      required this.email,
      required this.codigo,
      required this.editActive});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage>{

  @override
  Widget build(BuildContext context) {
    String descrp = widget.desc;
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Container(
            height: 20,
            color: Theme.of(context).colorScheme.secondaryContainer,
          ),
          Stack(
            children: [
              Container(
                height: 60,
                color: Theme.of(context).colorScheme.secondaryContainer,
              ),
              Center(
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                    shape: BoxShape.circle
                  ),
                ),
              ),
              Center(
                child: Container(
                  margin: const EdgeInsets.all(10),
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 3.0,
                    ),
                  ),
                  child: IconButton(
                    padding: const EdgeInsets.all(0),
                    enableFeedback: widget.editActive,
                    onPressed: () {
                      if (widget.editActive) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ProfilePicture(email: widget.email, nombre: widget.nombre, desc: widget.desc, codigo: widget.codigo)),
                        );
                      }
                    },
                    icon: Hero(
                      tag: 'foto',
                      child: CircleAvatar(
                        backgroundImage: ResizeImage(
                          AssetImage(ProfileImage.getImage(widget.foto%9)),
                          width: 200,
                          height: 200,
                        ),
                        radius: 50,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Text(
            widget.nombre,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '#${widget.codigo}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              (widget.editActive)
              ? Tooltip(
                message: 'Compartir código de amigo',
                child: IconButton(
                    onPressed: () {
                      Share.share(widget.codigo);
                    },
                    icon: Icon(Icons.share, color: Theme.of(context).colorScheme.primary,)
                )
              )
              : const SizedBox()
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 30),
            child: Text(
              descrp,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.blueGrey,
                fontSize: 18,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfilePicture extends StatefulWidget {
  final String email, nombre, desc, codigo;
  const ProfilePicture({super.key, required this.email,required this.nombre,required this.desc, required this.codigo});

  @override
  State<ProfilePicture> createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  File? _image;
  String _urlImage = ProfileImage.image;
  bool _tipo = true;
  late TextEditingController _nombre;
  late TextEditingController _descripcion;
  final _changesKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nombre = TextEditingController(text: widget.nombre);
    _descripcion = TextEditingController(text: widget.desc);
  }

  @override
  void dispose() {
    _nombre.dispose();
    _descripcion.dispose();
    super.dispose();
  }

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
          content: SizedBox(
            height: 300,
            width: 350,
            child: GridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
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
                  child: Center(
                      child: CircularBorderPicture(
                    image: ProfileImage.urls[index]!,
                    size: 100,
                  )),
                );
              }),
            )),
        ));
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
                child: GestureDetector(
                  onTap: () {
                    _openBottomSheet();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: FittedBox(
                      child: Hero(
                        tag: 'foto',
                        child: (_tipo && _image != null)
                            ? CircleAvatar(
                          backgroundImage: FileImage(_image!),
                          radius: 100,
                        )
                            : CircleAvatar(
                          backgroundImage: ResizeImage(AssetImage(_urlImage),
                              width: 250, height: 250),
                          radius: 100,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Form(
                  key: _changesKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nickname',
                          style: Theme.of(context).textTheme.headlineMedium),
                      TextFormField(
                        controller: _nombre,
                        keyboardType: TextInputType.text,
                        maxLength: 20,
                        decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'apodo',
                            counterText: ""
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'El campo no puede estar vacío';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Divider(
                        color: Colors.indigoAccent,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text('Descripción',
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: _descripcion,
                        keyboardType: TextInputType.multiline,
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
              ),
              const SizedBox(
                height: 10,
              ),
              CustomFilledButton(
                content: const Text('Guardar cambios'),
                onPressed: () {
                  if(_changesKey.currentState!.validate()) {
                    final safeContent = _descripcion.text.replaceAll('\n', '\\n');
                    openDialog(
                        context,
                        SaveChangesDialog(
                            nombre: _nombre.text,
                            desc: safeContent == "" ? " " : safeContent,
                            foto: ProfileImage.getIndex(),
                            email: widget.email,
                            codigo: widget.codigo));
                  }
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
              Text('Seleccionar foto',
                  style: Theme.of(context).textTheme.headlineMedium),
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
