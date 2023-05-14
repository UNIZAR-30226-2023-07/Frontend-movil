import 'package:flutter/material.dart';
import 'package:untitled/main.dart';
import 'package:untitled/pages/main_page.dart';
import 'package:untitled/services/google_sign_in.dart';
import '../pages/login_page.dart';
import '../pages/profile_page.dart';
import '../services/http_petitions.dart';
import '../services/open_snack_bar.dart';

class DeleteAccountDialog extends StatelessWidget {
  final String code;
  const DeleteAccountDialog({super.key, required this.code});

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
            bool res = await borrarCuenta(code);
            if (context.mounted) {
              if (!res) {
                Navigator.pop(context);
                openSnackBar(context, const Text('No se ha podido borrar la cuenta'));
              } else {
                await GoogleSignInApi().signOut();
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pushReplacement(context,
                    MaterialPageRoute(
                      builder: (context) => const Login()
                    ));
                  openSnackBar(context, const Text('Cuenta borrada correctamente'));
                }
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