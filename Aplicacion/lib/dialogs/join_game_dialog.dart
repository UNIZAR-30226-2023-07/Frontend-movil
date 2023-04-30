import 'package:flutter/material.dart';
import 'package:untitled/services/http_petitions.dart';
import '../pages/lobby_page.dart';
import '../services/open_snack_bar.dart';

final joinGameFormKey = GlobalKey<FormState>();

class JoinGameDialog extends StatelessWidget {
  JoinGameDialog({super.key, required this.codigo, required this.email});
  final String codigo;
  final String email;
  final TextEditingController idPartida = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Unirse a partida'),
      content: Form(
        key: joinGameFormKey,
        child: TextFormField(
          controller: idPartida,
          autofocus: true,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            hintText: '4541',
            border: UnderlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'El campo es obligatorio';
            }
            return null;
          },
        ),
      ),
      scrollable: true,
      actionsAlignment: MainAxisAlignment.spaceAround,
      actions: [
        FilledButton(
          onPressed: () async {
            if(joinGameFormKey.currentState!.validate()) {
              Map<String, dynamic>? res = await unirPartida(codigo, idPartida.text);
              if (context.mounted) {
                if (res == null) {
                  openSnackBar(context, const Text('No se ha podido enviar la petición'));
                  Navigator.pop(context);
                } else {
                  openSnackBar(context, const Text('Uniendose'));
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LobbyPage(creador: false, ranked: false, idPartida: idPartida.text,
                      MiCodigo: codigo, jug: res["jugadores"], email:email)),
                  );
                }
              }
            }
          },
          child: const Text('Unirse a Partida'),
        ),
        FilledButton(
          onPressed: () async {
            if(joinGameFormKey.currentState!.validate()) {
              Map<String, dynamic>? res = await unirPartida(codigo, idPartida.text);
              if (context.mounted) {
                if (res == null) {
                  openSnackBar(context, const Text('No se ha podido enviar la petición'));
                  Navigator.pop(context);
                } else {
                  openSnackBar(context, const Text('Uniendose'));
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LobbyPage(creador: false, ranked: true, idPartida: idPartida.text,
                      MiCodigo: codigo, jug: res["jugadores"],email:email)),
                  );
                }
              }
            }
          },
          child: const Text('Unirse a Torneo'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}