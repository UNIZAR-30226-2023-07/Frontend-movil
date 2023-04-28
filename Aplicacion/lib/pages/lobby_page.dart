import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import '../services/http_petitions.dart';
import '../services/open_snack_bar.dart';
import '../services/profile_image.dart';
import 'board_page.dart';
import '../widgets/custom_filled_button.dart';
import '../widgets/circular_border_picture.dart';

const String _IP = '52.174.124.24';
const String _PUERTO = '3001';

List<Map<String, dynamic>> jugadores = [];

class LobbyPage extends StatefulWidget {
  const LobbyPage({Key? key, required this.ranked, required this.idPartida, required this.MiCodigo}) : super(key: key);
  final bool ranked;
  final String idPartida;
  final String MiCodigo;
  @override
  State<LobbyPage> createState() => _LobbyPage();
}

class _LobbyPage extends State<LobbyPage> {
  late final ws_partida;
  late StreamSubscription subscription;
  bool _load = false;

  @override
  void initState() {
    super.initState();
    jugadores.clear();
    recuperarUser(widget.MiCodigo);

      ws_partida = IOWebSocketChannel.connect('ws://$_IP:$_PUERTO/api/ws/partida/${widget.idPartida}');
      ws_partida.stream.handleError((error) {
        print('Error: $error');
      });

        subscription = ws_partida.stream.listen((message) async {
        print('Received: $message');
        Map<String, dynamic> datos = jsonDecode(message);
        int indice = datos["tipo"].indexOf(": ");
        String tipo = indice >= 0 ? datos["tipo"].substring(0, indice) : datos["tipo"];
        if(tipo == "Partida_Iniciada"){
          openSnackBar(context, const Text('Iniciando partida'));
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>  BoardPage(idPartida: widget.idPartida,
              MiCodigo: widget.MiCodigo,)),
          );
        } else if(tipo == "Nuevo_Jugador"){
          String N_codigo = indice >= 0 ? datos["tipo"].substring(indice + 2) : "";
          recuperarUser(N_codigo);
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
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: CircularBorderPicture(image: ProfileImage
                            .urls[(jugadores[index])["foto"] % 6]!,),
                      ),
                      Text(
                        (jugadores[index])["nombre"],
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
              ),
            ),
            const SizedBox(height: 20,),
            CustomFilledButton(
              content: const Text('Empezar partida'),
              onPressed: () async {
                bool res = await iniciarPartida(widget.MiCodigo,widget.idPartida);
                if (context.mounted) {
                  if (res == null) {
                    openSnackBar(context, const Text('No se ha podido enviar la petición'));
                    Navigator.pop(context);
                  }
                }
              }
            ),
            const SizedBox(height: 20,),
            Align(
              alignment: Alignment.center,
              child: Text('Código: ${widget.idPartida}', style: Theme.of(context).textTheme.headlineMedium),
            ),
          ],
        ),
      ),
    );
  }
}