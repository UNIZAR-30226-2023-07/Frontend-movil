import 'package:flutter/material.dart';
import '../services/http_petitions.dart';
import '../services/open_snack_bar.dart';

class DenyFriendDialog extends StatelessWidget {
  const DenyFriendDialog({super.key, this.nombre = "Amigo falso",required this.codigoEm,required this.codigoRec});

  final String nombre, codigoEm, codigoRec;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Eliminar solicitud de amistad pendiente de \'$nombre\''),
      scrollable: true,
      actionsAlignment: MainAxisAlignment.spaceAround,
      actions: [
        FilledButton(
          onPressed: () async {
            bool res = await denegarAmigo(codigoEm, codigoRec);
            if (context.mounted) {
              Navigator.pop(context);
              if (!res) {
                openSnackBar(context, const Text('No se ha podido eliminar la solicitud'));
              } else {
                openSnackBar(context, const Text('Solicitud eliminada'));
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