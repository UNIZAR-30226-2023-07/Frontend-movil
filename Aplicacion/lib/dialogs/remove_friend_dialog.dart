import 'package:flutter/material.dart';
import '../services/http_petitions.dart';
import '../services/open_snack_bar.dart';

class RemoveFriendDialog extends StatelessWidget {
  const RemoveFriendDialog({super.key, this.nombre = "Amigo falso",required this.codigoEm,required this.codigoRec});

  final String nombre, codigoEm, codigoRec;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Eliminar amigo \'$nombre\''),
      scrollable: true,
      actionsAlignment: MainAxisAlignment.spaceAround,
      actions: [
        FilledButton(
          onPressed: () async {
            bool res = await denegarAmigo(codigoEm, codigoRec);
            if (context.mounted) {
              if (!res) {
                openSnackBar(context, const Text('No se ha podido enviar la petición'));
              } else {
                openSnackBar(context, const Text('Amigo eliminado'));
              }
            }
            else openSnackBar(context, const Text('Amigo eliminado'));
            Navigator.pop(context);
          },
          child: const Text('Sí'),
        ),
        FilledButton(
          onPressed: () async {
            Navigator.pop(context);
          },
          child: const Text('No'),
        ),
      ],
    );
  }
}