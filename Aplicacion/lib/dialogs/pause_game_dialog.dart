import 'package:flutter/material.dart';
import 'package:untitled/main.dart';
import '../pages/lobby_page.dart';

class PauseGameDialog extends StatelessWidget {
  const PauseGameDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pausar partida'),
      scrollable: true,
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context);
            Navigator.pop(context);
          },
          child: const Text('Guardar y Salir'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Volver a la partida'),
        ),
      ],
    );
  }
}