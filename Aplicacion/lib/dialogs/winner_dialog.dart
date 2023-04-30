import 'package:flutter/material.dart';
import '../main.dart';
import '../services/http_petitions.dart';
import '../services/open_snack_bar.dart';

class WinnerDialog extends StatelessWidget {
  const WinnerDialog({super.key, required this.ganador, required this.ranked, required this.email});

  final String ganador;
  final bool ranked;
  final String email;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Fin de la partida. Ganador: \'$ganador\''),
      scrollable: true,
      actionsAlignment: MainAxisAlignment.spaceAround,
      actions: [
        FilledButton(
          onPressed: () {
            if(!ranked){
              openSnackBar(context, const Text('Gracias por jugar'));
              Navigator.pop(context);
              Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (
                    context) => MyHomePage(email: email)),
              );
            } else{
            }
            //volver al inicio o seguir torneo
          },
          child: const Text('Finalizar'),
        ),
      ],
    );
  }
}