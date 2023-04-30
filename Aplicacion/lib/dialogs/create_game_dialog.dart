import 'package:flutter/material.dart';
import 'package:untitled/services/http_petitions.dart';
import '../pages/lobby_page.dart';
import '../services/open_snack_bar.dart';

class CreateGameDialog extends StatelessWidget {
  const CreateGameDialog({super.key, required this.codigo});
  final String codigo;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Crear partida'),
      scrollable: true,
      actionsAlignment: MainAxisAlignment.spaceAround,
      actions: [
        FilledButton(
          onPressed: () async {
            Map<String, dynamic>? res = await crearPartida(codigo,"amistosa");
            if (context.mounted) {
              if (res == null) {
                openSnackBar(context, const Text('No se ha podido enviar la petición'));
                Navigator.pop(context);
              } else {
                openSnackBar(context, const Text('Creando partida'));
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LobbyPage(creador: true,ranked: false, idPartida: res["clave"], MiCodigo: codigo,)),
                );
              }
            }
          },
          child: const Text('Partida normal'),
        ),
        FilledButton(
          onPressed: () async {
            Map<String, dynamic>? res = await crearPartida(codigo,"torneo");
            if (context.mounted) {
              if (res == null) {
                openSnackBar(context, const Text('No se ha podido enviar la petición'));
                Navigator.pop(context);
              } else {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>
                      LobbyPage(ranked: true,
                        idPartida: res["clave"],
                        MiCodigo: codigo, creador: true,)),
                );
              }
            }
          },
          child: const Text('Partida clasificatoria'),
        ),
      ],
    );
  }
}