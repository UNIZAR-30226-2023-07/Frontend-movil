import 'package:flutter/material.dart';
import '../services/open_snack_bar.dart';

class AcceptFriendDialog extends StatelessWidget {
  const AcceptFriendDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Aceptar solicitud de amistad'),
      scrollable: true,
      actionsAlignment: MainAxisAlignment.spaceAround,
      actions: [
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            openSnackBar(context, const Text('Amigo añadido'));
          },
          child: const Text('Sí'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            openSnackBar(context, const Text('Solicitud denegada'));
          },
          child: const Text('No'),
        ),
      ],
    );
  }
}