import 'package:flutter/material.dart';
import 'package:untitled/main.dart';
import '../pages/lobby_page.dart';
import '../services/http_petitions.dart';
import '../services/open_snack_bar.dart';

class PauseGameDialog extends StatelessWidget {
  const PauseGameDialog({super.key, required this.codigo, required this.idPartida});
  final String codigo;
  final String idPartida;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pausar partida'),
      scrollable: true,
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        FilledButton(
          onPressed: () async {
            bool res = await pausarPartida(codigo,idPartida);
            if (context.mounted) {
              if (res == false) {
                Navigator.pop(context);
                openSnackBar(context, const Text('No se ha podido enviar la petición'));
              }
            }

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