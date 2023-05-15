import 'package:flutter/material.dart';
import 'package:untitled/services/http_petitions.dart';
import 'package:untitled/widgets/custom_filled_button.dart';
import '../pages/lobby_page.dart';
import '../services/open_snack_bar.dart';

class CreateGameDialog extends StatelessWidget {
  const CreateGameDialog({super.key, required this.codigo, required this.email});
  final String codigo;
  final String email;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Crear partida'),
      scrollable: true,
      actionsAlignment: MainAxisAlignment.spaceAround,
      actionsOverflowAlignment: OverflowBarAlignment.center,
      actions: [
        CustomFilledButton(
          height: 40,
          onPressed: () async {
            Map<String, dynamic>? res = await crearPartida(codigo,"amistosa");
            if (context.mounted) {
              if (res == null) {
                Navigator.pop(context);
                openSnackBar(context, const Text('No se ha podido enviar la petición'));
              } else {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LobbyPage(email: email, creador: true,ranked: false,
                    idPartida: res["clave"], MiCodigo: codigo,)),
                );
                openSnackBar(context, const Text('Creando partida'));
              }
            }
          },
          content: const Text('Partida normal'),
        ),
        const SizedBox(height: 10),
        CustomFilledButton(
          height: 40,
          onPressed: () async {
            Map<String, dynamic>? res = await crearPartida(codigo,"torneo");
            if (context.mounted) {
              if (res == null) {
                Navigator.pop(context);
                openSnackBar(context, const Text('No se ha podido enviar la petición'));
              } else {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>
                      LobbyPage(ranked: true,
                        idPartida: res["clave"],
                        MiCodigo: codigo, creador: true,
                        email: email)),
                );
              }
            }
          },
          content: const Text('Partida clasificatoria'),
        ),
      ],
    );
  }
}