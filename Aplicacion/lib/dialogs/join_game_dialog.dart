import 'package:flutter/material.dart';

final joinGameFormKey = GlobalKey<FormState>();

class JoinGameDialog extends StatelessWidget {
  const JoinGameDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Unirse a partida'),
      content: Form(
        key: joinGameFormKey,
        child: TextFormField(
          autofocus: true,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            hintText: '45tg34g435',
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
          onPressed: () {
            if(joinGameFormKey.currentState!.validate()) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Amigo añadido'),
                  showCloseIcon: true,
                ),
              );
              Navigator.pop(context);
            }
          },
          child: const Text('Unirse'),
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