import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:untitled/services/http_petitions.dart';
import 'package:untitled/widgets/custom_filled_button.dart';
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
          decoration: InputDecoration(
            hintText: '4541',
            suffixIcon: IconButton(
              onPressed: () async {
                Clipboard.getData(Clipboard.kTextPlain).then((value){
                  idPartida.text = value!.text!;
                });
              },
              icon: Icon(Icons.content_paste, color: Theme.of(context).colorScheme.primary)
            ),
            border: const UnderlineInputBorder(),
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
      actionsAlignment: MainAxisAlignment.center,
      actionsOverflowAlignment: OverflowBarAlignment.center,
      actions: [
        CustomFilledButton(
          width: 40,
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
          content: const Text('Unirse a Partida'),
        ),
        const SizedBox(height: 10),
        CustomFilledButton(
          width: 40,
          onPressed: () async {
            if(joinGameFormKey.currentState!.validate()) {
              Map<String, dynamic>? res = await unirPartida(codigo, idPartida.text);
              if (context.mounted) {
                if (res == null) {
                  openSnackBar(context, const Text('No se ha podido enviar la petición'));
                  Navigator.pop(context);
                } else {
                  if (res["res"] == "ok") {
                    openSnackBar(context, const Text('Uniendose'));
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>
                          LobbyPage(creador: false,
                              ranked: true,
                              idPartida: idPartida.text,
                              MiCodigo: codigo,
                              jug: res["jugadores"],
                              email: email)),
                    );
                  } else {
                    openSnackBar(context, const Text('Sala llena'));
                    Navigator.pop(context);
                  }
                }
              }
            }
          },
          content: const Text('Unirse a Torneo'),
        ),
        const SizedBox(height: 10),
        CustomFilledButton(
          width: 40,
          onPressed: () {
            Navigator.pop(context);
          },
          content: const Text('Cancelar'),
        ),
      ],
    );
  }
}