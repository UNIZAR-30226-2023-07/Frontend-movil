import 'package:flutter/material.dart';
import 'package:untitled/services/http_petitions.dart';
import '../services/open_snack_bar.dart';

final addFriendFormKey = GlobalKey<FormState>();

class AddFriendDialog extends StatelessWidget {
  final String codigo;
  final TextEditingController idAmigo = TextEditingController();
  AddFriendDialog({super.key, required this.codigo});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Añadir amigo con ID'),
      content: Form(
        key: addFriendFormKey,
        child: TextFormField(
          controller: idAmigo,
          autofocus: true,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            hintText: 'amigo_123',
            border: UnderlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'El campo es obligatorio';
            } else if (value == codigo) {
              return 'No te puedes añadir a ti mismo';
            }
            return null;
          },
        ),
      ),
      scrollable: true,
      actionsAlignment: MainAxisAlignment.spaceAround,
      actions: [
        FilledButton(
          onPressed: () async {
            if(addFriendFormKey.currentState!.validate()) {
              bool res = await nuevoAmigo(codigo, idAmigo.text);
              if (context.mounted) {
                if (!res) {
                  openSnackBar(context, const Text('No se ha podido enviar la petición'));
                } else {
                  openSnackBar(context, const Text('Petición enviada'));
                }
                Navigator.pop(context);
              }
            }
          },
          child: const Text('Añadir amigo'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}