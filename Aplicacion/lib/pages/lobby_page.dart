import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:share_plus/share_plus.dart';
import '../services/http_petitions.dart';
import '../services/open_snack_bar.dart';
import '../services/profile_image.dart';
import '../widgets/points.dart';
import 'board_page.dart';
import '../widgets/custom_filled_button.dart';
import '../widgets/circular_border_picture.dart';

const String _IP = '20.160.173.253';
const String _PUERTO = '3001';

List<Map<String, dynamic>> jugadores = [];

bool _isChecked = false;

class LobbyPage extends StatefulWidget {

  final bool ranked;
  final String idPartida;
  final String MiCodigo;
  final bool creador;
  final String email;
  final bool nueva;
  final List<dynamic> jug;

  const LobbyPage({
    super.key,
    this.nueva = true,
    required this.email,
    required this.creador,
    required this.ranked,
    required this.idPartida,
    required this.MiCodigo,
    this.jug = const []});

  @override
  State<LobbyPage> createState() => _LobbyPage();
}

class _LobbyPage extends State<LobbyPage> {
  late final ws_partida;
  late final ws_torneo;
  late StreamSubscription subscription;
  bool _load = false;
  Map<String, String> turnos = {};

  @override
  void initState() {
    super.initState();
    jugadores.clear();
    for (int i = 0; i < widget.jug.length; i++) {
      recuperarUser(widget.jug[i]);
    }
      recuperarUser(widget.MiCodigo);

      if (widget.ranked) {
        ws_torneo = IOWebSocketChannel.connect(
            'ws://$_IP:$_PUERTO/api/ws/torneo/${widget.idPartida}');

      }
      ws_partida = IOWebSocketChannel.connect(
        'ws://$_IP:$_PUERTO/api/ws/partida/${widget.idPartida}');
      ws_partida.stream.handleError((error) {
        print('Error: $error');
      });

    if(widget.ranked) {
      ws_torneo.stream.listen((message) async {
        print('Received: $message');
        Map<String, dynamic> datos = jsonDecode(message);
        int indice = datos["tipo"].indexOf(": ");
        String tipo = indice >= 0
            ? datos["tipo"].substring(0, indice)
            : datos["tipo"];
        if (tipo == "Partida_Iniciada") {
          turnos.clear();
          for (int i = 0; i < datos["turnos"].length; i++) {
            List<dynamic> t = datos["turnos"][i];
            turnos[t[1]] = t[0];
          }
        } else if (tipo == "Nuevo_Jugador" || tipo == "Nuevo_Jugador ") {
          String N_codigo = indice >= 0
              ? datos["tipo"].substring(indice + 2)
              : "";
          recuperarUser(N_codigo);
        } else if(tipo == "Partida_Creada"){
          openSnackBar(context, const Text('Iniciando torneo'));
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>
                BoardPage(init: true,
                    idPartida: widget.idPartida,
                    MiCodigo: widget.MiCodigo,
                    turnos: turnos,
                    ranked: widget.ranked,
                    creador: widget.creador,
                    email: widget.email,
                    ws_partida: ws_partida)),
          );
        }
        else if (tipo == "Partida_reanudada" && !widget.nueva) {
          openSnackBar(context, const Text('Reanudando torneo'));

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>
                BoardPage(init: true,
                    idPartida: widget.idPartida,
                    MiCodigo: widget.MiCodigo,
                    turnos: turnos,
                    ranked: widget.ranked,
                    creador: widget.creador,
                    email: widget.email,
                    ws_partida: ws_partida)),
          );
        }
      });
    }

      subscription = ws_partida.stream.listen((message) async {
        print('Received: $message');
        Map<String, dynamic> datos = jsonDecode(message);
        int indice = datos["tipo"].indexOf(": ");
        String tipo = indice >= 0
            ? datos["tipo"].substring(0, indice)
            : datos["tipo"];
        if (tipo == "Partida_Iniciada") {
          turnos.clear();
          for (int i = 0; i < datos["turnos"].length; i++) {
            List<dynamic> t = datos["turnos"][i];
            turnos[t[1]] = t[0];
          }
        } else if(tipo == "Partida_Creada"){
          openSnackBar(context, const Text('Iniciando partida'));
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>
                BoardPage(init: true,
                    idPartida: widget.idPartida,
                    MiCodigo: widget.MiCodigo,
                    turnos: turnos,
                    ranked: widget.ranked,
                    creador: widget.creador,
                    email: widget.email,
                    ws_partida: ws_partida)),
          );
        }
        else if (tipo == "Nuevo_Jugador" || tipo == "Nuevo_Jugador ") {
          String N_codigo = indice >= 0
              ? datos["tipo"].substring(indice + 2)
              : "";
          recuperarUser(N_codigo);
        } else if (tipo == "Partida_reanudada" && !widget.nueva) {
          openSnackBar(context, const Text('Reanudando partida'));

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>
                BoardPage(init: true,
                    idPartida: widget.idPartida,
                    MiCodigo: widget.MiCodigo,
                    turnos: turnos,
                    ranked: widget.ranked,
                    creador: widget.creador,
                    email: widget.email,
                    ws_partida: ws_partida)),
          );
        }
      });
  }


  void recuperarUser(String code) async{
    Map<String, dynamic>? user = await getUserCode(code);
    jugadores.add(user!);
    _load = true;
    setState(() { });
  }

  @override
  void dispose() {
    subscription.cancel();
    ws_partida.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.ranked == false
        ? const Text('Partida normal')
        : const Text('Partida clasificatoria'),
      ),
      body: !_load
          ? const Center(child: CircularProgressIndicator())
      : SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text('Jugadores', style: Theme.of(context).textTheme.headlineMedium),
            ),
            const SizedBox(height: 10,),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                border: Border.all(color: Colors.indigoAccent),
                borderRadius: BorderRadius.circular(30),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: jugadores.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20,10,10,10),
                        child: CircularBorderPicture(image: ProfileImage
                            .urls[(jugadores[index])["foto"] % 9]!,),
                      ),
                      Text(
                        (jugadores[index])["nombre"],
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      const Spacer(),
                      Points(value: ((jugadores[index])["puntos"])),
                      const SizedBox(width: 20)
                    ],
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                    'Código: ${widget.idPartida}',
                    style: Theme.of(context).textTheme.headlineMedium
                ),
                Tooltip(
                    message: 'Compartir código de partida',
                    child: IconButton(
                        onPressed: () {
                          Share.share(widget.idPartida);
                        },
                        icon: Icon(Icons.share, color: Theme.of(context).colorScheme.primary,)
                    )
                )
              ],
            ),
            const SizedBox(height: 20),
            (widget.creador)
            ? Column(
              children: [
                CustomFilledButton(
              content: const Text('Empezar partida'),
              onPressed: () async {
                if (jugadores.length >= 2 || _isChecked) {
                  bool res = await iniciarPartida(widget.MiCodigo,widget.idPartida,_isChecked);
                  if (context.mounted) {
                    if (res == false) {
                      Navigator.pop(context);
                      if(widget.ranked && widget.ranked){
                        openSnackBar(context, const Text('No estan todos los jugadores'));
                      } else if(!widget.creador){
                        openSnackBar(context, const Text('Solo el creador puede comenzar la partida'));
                      } else{
                        openSnackBar(context, const Text('No se ha podido enviar la petición'));
                      }
                    }
                  }
                } else {
                  openSnackBar(context, const Text('Se necesitan al menos 2 jugadores para empezar la partida'));
                }
              }
            ),
              const SizedBox(),
              Row(
                children: [
                  Checkbox(
                    value: _isChecked,
                    onChanged: (bool? value) {
                      setState(() {
                        _isChecked = value!;
                      });
                    },
                  ),
                  const Text('Jugar con bots')
                ],
              ),
            ]
            )
            : const SizedBox(),
          ],
        ),
      ),
    );
  }
}