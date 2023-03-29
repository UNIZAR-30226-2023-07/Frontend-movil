import 'package:flutter/material.dart';
import 'package:untitled/services/http_petitions.dart';
import '../services/open_snack_bar.dart';

final addFriendFormKey = GlobalKey<FormState>();

class AddFriendDialog extends StatelessWidget {
  final String codigo;
  final TextEditingController id_amigo = TextEditingController();
  AddFriendDialog({required this.codigo});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Añadir amigo con ID'),
      content: Form(
        key: addFriendFormKey,
        child: TextFormField(
          controller: id_amigo,
          autofocus: true,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            hintText: '#1234',
            border: UnderlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'El campo es obligatorio';
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
              bool res = await nuevoAmigo(codigo, id_amigo.text, context);
              if (!res) {
                openSnackBar(context, const Text('No se ha podido añadir'));
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