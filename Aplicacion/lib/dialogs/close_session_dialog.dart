import 'package:flutter/material.dart';
import 'package:untitled/services/google_sign_in.dart';
import '../pages/login_page.dart';

class CloseSessionDialog extends StatelessWidget {
  const CloseSessionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('¿Estás seguro de querer cerrar sesión?'),
      scrollable: true,
      actionsAlignment: MainAxisAlignment.spaceAround,
      actions: [
        FilledButton(
          onPressed: () async {
            await GoogleSignInApi().signOut();
            if (context.mounted) {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Login()),
              );
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