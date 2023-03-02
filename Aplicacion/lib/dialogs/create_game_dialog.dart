import 'package:flutter/material.dart';
import '../pages/lobby_page.dart';

class CreateGameDialog extends StatelessWidget {
  const CreateGameDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Crear partida'),
      scrollable: true,
      actionsAlignment: MainAxisAlignment.spaceAround,
      actions: [
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LobbyPage(ranked: false)),
            );
          },
          child: const Text('Partida normal'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LobbyPage(ranked: true)),
            );
          },
          child: const Text('Partida clasificatoria'),
        ),
      ],
    );
  }
}