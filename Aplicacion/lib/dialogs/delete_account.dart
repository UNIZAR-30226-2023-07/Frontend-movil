import 'package:flutter/material.dart';
import 'package:untitled/main.dart';
import 'package:untitled/pages/main_page.dart';
import 'package:untitled/services/google_sign_in.dart';
import '../pages/profile_page.dart';
import '../services/http_petitions.dart';
import '../services/open_snack_bar.dart';

class DeleteAccountDialog extends StatelessWidget {
  final String email;
  const DeleteAccountDialog({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('¿Está seguro que quiere borrar la cuenta?'),
      content: const Text('Esta acción será irreversible'),
      scrollable: true,
      actionsAlignment: MainAxisAlignment.spaceAround,
      actions: [
        FilledButton(
          onPressed: () async {
            bool res = await borrarCuenta(email);
            if (context.mounted) {
              if (!res) {
                openSnackBar(context, const Text('No se ha podido borrar la cuenta'));
                Navigator.pop(context);
              } else {
                openSnackBar(context, const Text('Cuenta borrada correctamente'));
                Navigator.pop(context);
                Navigator.pop(context);
                GoogleSignInApi.logout();
              }
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