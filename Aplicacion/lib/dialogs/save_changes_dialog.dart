import 'package:flutter/material.dart';
import '../services/http_petitions.dart';
import '../services/open_snack_bar.dart';

class SaveChangesDialog extends StatelessWidget {
  final String nombre, foto, desc, email;
  const SaveChangesDialog({required this.nombre, required this.foto, required this.desc, required this.email});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('¿Guardar cambios?'),
      scrollable: true,
      actionsAlignment: MainAxisAlignment.spaceAround,
      actions: [
        FilledButton(
          onPressed: () async {
              bool res = await editProfile(email, nombre, desc, foto, context);
              if (!res) {
                openSnackBar(context, const Text('No se ha podido añadir'));
                Navigator.pop(context);
              }
            },
          child: const Text('Sí'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('No'),
        ),
      ],
    );
  }
}