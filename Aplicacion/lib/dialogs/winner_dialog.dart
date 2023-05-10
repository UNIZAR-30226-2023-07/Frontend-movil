import 'package:flutter/material.dart';
import '../main.dart';
import '../pages/board_page.dart';
import '../services/audio_manager.dart';
import '../services/http_petitions.dart';
import '../services/open_snack_bar.dart';

class WinnerDialog extends StatelessWidget {
  const WinnerDialog({super.key, required this.ganador, required this.ranked, required this.email, required this.idPartida,
  required this.MiCodigo, required this.turnos, required this.creador, this.finT = false, required this.ws_partida});

  final String ganador;
  final bool ranked;
  final String email;
  final String idPartida;
  final String MiCodigo;
  final Map<String, String> turnos;
  final bool creador;
  final bool finT;
  final ws_partida;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: !finT ? Text('Fin de la partida. Ganador: \'$ganador\'') :
      Text('Fin del torneo. Ganador: \'$ganador\'') ,
      scrollable: true,
      actionsAlignment: MainAxisAlignment.spaceAround,
      actions: [
        FilledButton(
          onPressed: () {
            if(!ranked){
              AudioManager.toggleBGM(false);
              openSnackBar(context, const Text('Gracias por jugar'));
              Navigator.pop(context);
              Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (
                    context) => MyHomePage(email: email)),
              );
            } else{
              if(!finT) {
                String data = '{"emisor": "${MiCodigo}","tipo": "Mostrar_tablero"}';
                ws_partida!.sink.add(data);

                data = '{"emisor": "${MiCodigo}","tipo": "Mostrar_manos"}';
                ws_partida!.sink.add(data);
                Navigator.pop(context);
                // Navigator.push(context,
                //   MaterialPageRoute(
                //       builder: (context) =>
                //           BoardPage(
                //             idPartida: idPartida,
                //             MiCodigo: MiCodigo,
                //             turnos: turnos,
                //             ranked: ranked,
                //             creador: creador,
                //             email: email,
                //             init: true,)),);
              } else {
                AudioManager.toggleBGM(false);
                openSnackBar(context, const Text('Gracias por jugar'));
                Navigator.pop(context);
                Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (
                      context) => MyHomePage(email: email)),
                );
              }
            }
          },
          child: const Text('Aceptar'),
        ),
      ],
    );
  }
}