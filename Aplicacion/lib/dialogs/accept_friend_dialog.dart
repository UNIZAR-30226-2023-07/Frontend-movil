import 'package:flutter/material.dart';
import '../services/http_petitions.dart';
import '../services/open_snack_bar.dart';

class AcceptFriendDialog extends StatelessWidget {
  const AcceptFriendDialog({super.key, this.nombre = "Amigo falso",required this.codigoEm,required this.codigoRec});

  final String nombre, codigoEm, codigoRec;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Aceptar solicitud de amistad de \'$nombre\''),
      scrollable: true,
      actionsAlignment: MainAxisAlignment.spaceAround,
      actions: [
        FilledButton(
          onPressed: () async {
            bool res = await aceptarAmigo(codigoEm, codigoRec);
            if (context.mounted) {
              Navigator.pop(context);
              if (!res) {
                openSnackBar(context, const Text('No se ha podido aceptar la solicitud'));
              } else {
                openSnackBar(context, const Text('Amigo añadido'));
              }
            }
          },
          child: const Text('Sí'),
        ),
        FilledButton(
          onPressed: () async {
            bool res = await denegarAmigo(codigoEm, codigoRec);
            if (context.mounted) {
              Navigator.pop(context);
              if (!res) {
                openSnackBar(context, const Text('No se ha podido denegadar la solicitud'));
              } else {
                openSnackBar(context, const Text('Solicitud denegada'));
              }
            }
          },
          child: const Text('No'),
        ),
      ],
    );
  }
}