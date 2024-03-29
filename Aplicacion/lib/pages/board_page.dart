import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:playing_cards/playing_cards.dart';
import 'package:untitled/dialogs/pause_game_dialog.dart';
import 'package:untitled/dialogs/winner_dialog.dart';
import 'package:untitled/pages/rules_page.dart';
import 'package:untitled/services/audio_manager.dart';
import 'package:untitled/services/http_petitions.dart';
import 'package:untitled/widgets/custom_filled_button.dart';
import 'package:wakelock/wakelock.dart';
import 'package:web_socket_channel/io.dart';
import '../pages/chat_page.dart';
import '../services/open_snack_bar.dart';
import '../services/profile_image.dart';
import '../widgets/circular_border_picture.dart';
import '../widgets/points.dart';

const String _IP = '20.160.173.253';
const String _PUERTO = '3001';

List<int> CSelecion = [];
List<bool> selected = [];

List<List<Carta>> Cartas_abrir = [];
List<List<int>> Indices_abrir = [];

List<Carta> cartMano = [];
List<bool> mostrar_carta = [];

List<List<Carta>> t = [];

class Carta {
  final int numero;
  final int palo;

  Carta(this.numero, this.palo);
}

int modo = 1; // 0 - no turno, 1 - encarte, 2 - colocar/descarte
PlayingCard? descarte;
int abrir = 0; //0 - tiene que abrir, 1 - esta abriendo, 2 - no tiene que abrir
String t_actual = "";
bool v = true;

class BoardPage extends StatefulWidget {
  BoardPage(
      {Key? key,
      this.actualizar = true,
      required this.email,
      this.ws_partida = null,
      this.init = false,
      required this.idPartida,
      required this.MiCodigo,
      required this.turnos,
      required this.ranked,
      this.creador = false})
      : super(key: key);
  String idPartida;
  IOWebSocketChannel? ws_partida;
  String MiCodigo;
  bool creador;
  bool init, actualizar;
  bool ranked;
  String email;
  Map<String, String> turnos;
  Map<String, String> num_cartas = {};
  @override
  State<BoardPage> createState() => _BoardPageState();
}

List<String> puntos = ["0", "0", "0", "0"];

class _BoardPageState extends State<BoardPage> {
  bool _load = false;
  bool _load2 = false;
  late StreamSubscription subscription_p;
  late List<int> fotos = <int>[];
  late IOWebSocketChannel ws_torneo;

  @override
  void initState() {
    super.initState();
    fotos.clear();
    procesarFotos();
    //Hacer que la pantalla no se pueda apagar
    Wakelock.enable();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    if (widget.init) {
      AudioManager.toggleBGM(true);
      abrir = 0;
      v = true;
      descarte = null;
      cartMano.clear();
      t_actual = widget.turnos["0"]!;
      if (t_actual == widget.MiCodigo) {
        modo = 1;
      } else {
        modo = 0;
      }
    }

    widget.ws_partida = IOWebSocketChannel.connect(
        'ws://$_IP:$_PUERTO/api/ws/partida/${widget.idPartida}');

    if (widget.ranked) {
      ws_torneo = IOWebSocketChannel.connect(
          'ws://$_IP:$_PUERTO/api/ws/torneo/${widget.idPartida}');
      ws_torneo.stream.listen((message) {
        Map<String, dynamic> datos = jsonDecode(message);
        if (datos["tipo"] == "Partida_terminada") {
          puntos.clear();
          for (int i = 0; i < datos["puntos"].length; i++) {
            puntos.add(datos["puntos"][i]);
          }
          if (datos["ganador"] != "") {
            String ganador = datos["ganador"];
            String jugador = widget.turnos[ganador]!;
            abrir = 0;
            v = true;
            descarte = null;
            cartMano.clear();
            t_actual = widget.turnos["0"]!;
            if (t_actual == widget.MiCodigo) {
              modo = 1;
            } else {
              modo = 0;
            }
            showDialog(
                context: context,
                builder: (context) => WinnerDialog(
                      ganador: jugador,
                      ranked: widget.ranked,
                      email: widget.email,
                      idPartida: widget.idPartida,
                      MiCodigo: widget.MiCodigo,
                      turnos: widget.turnos,
                      creador: widget.creador,
                      ws_partida: widget.ws_partida,
                      finT: true,
                    ));
          }
        } else if (datos["tipo"] == "Puntos") {
          puntos.clear();
          for (int i = 0; i < datos["puntos"].length; i++) {
            puntos.add(datos["puntos"][i]);
          }
        }
      });
    }
    widget.ws_partida!.stream.handleError((error) {
      print('Error: $error');
    });

    subscription_p = widget.ws_partida!.stream.listen((message) {
      Map<String, dynamic> datos = jsonDecode(message);
      if (datos["receptor"] == widget.MiCodigo ||
          datos["receptor"] == "todos") {
        if (datos["tipo"] == "Mostrar_manos") {
          _load = false;
          print('mostar_manos');
          for (int j = 0; j < widget.turnos.length; j++) {
            List<dynamic> cartas = datos["manos"][j];
            widget.num_cartas[j.toString()] = cartas.length.toString();
            if (widget.turnos[j.toString()] == widget.MiCodigo) {
              if (cartas.length >= 14) {
                abrir = 0;
              } else {
                abrir = 2;
              }
              cartMano.clear();
              mostrar_carta.clear();
              List<Carta> temp = [];
              for (String i in cartas) {
                List<String> listaNumeros = i.split(",");
                int valor = int.parse(listaNumeros[0]);
                int palo = int.parse(listaNumeros[1]);
                temp.add(Carta(valor, palo));
              }
              selected.clear();
              for (int i = 0; i < temp.length; i++) {
                selected.add(false);
              }
              setState(() {
                cartMano = temp;
                for (int i = 0; i < cartMano.length; i++) {
                  mostrar_carta.add(true);
                }
                _load = true;
              });
            }
          }
        } else if (datos["tipo"] == "Robar_carta") {
          print('robar_carta');
          if (datos["receptor"] == widget.MiCodigo) {
            modo = 2;
            openSnackBar(context, const Text('Carta robada'));
            if (v) {
              openSnackBar(
                  context,
                  const Text(
                      'Para terminar tu turno deja una carta en el monton de descartes'));
            }

            List<String> listaNumeros = datos["info"].split(",");
            int valor = int.parse(listaNumeros[0]);
            int palo = int.parse(listaNumeros[1]);
            mostrar_carta.add(true);
            cartMano.add(Carta(valor, palo));
            print("robada");
            print(cartMano.length);
            setState(() {});
            // Navigator.pop(context);
            // Navigator.push(context,
            //   MaterialPageRoute(
            //       builder: (context) =>
            //           BoardPage(ws_partida: widget.ws_partida,
            //               idPartida: widget.idPartida,
            //               MiCodigo: widget.MiCodigo,
            //               turnos: widget.turnos,
            //               ranked: widget.ranked,
            //               creador: widget.creador,
            //               email: widget.email,)),);
          }
        } else if (datos["tipo"] == "Mostrar_tablero") {
          print('mostrar_tablero');
          if (datos["descartes"] != null) {
            String d = datos["descartes"][0];
            List<String> listaNumeros = d.split(",");
            int valor = int.parse(listaNumeros[0]);
            int palo = int.parse(listaNumeros[1]);
            descarte = PlayingCard(PaloToSuit(palo), NumToValue(valor));
          }
          t.clear();
          if (datos["combinaciones"] != null) {
            for (List<dynamic> comb in datos["combinaciones"]) {
              List<Carta> temp = [];
              print("comb:");
              print(comb);
              for (String c in comb) {
                List<String> listaNumeros = c.split(",");
                int valor = int.parse(listaNumeros[0]);
                int palo = int.parse(listaNumeros[1]);
                temp.add(Carta(valor, palo));
              }
              t.add(temp);
            }
          }
        } else if (datos["tipo"] == "Colocar_combinacion") {
          print('colocar_combinacion');
          if (datos["info"] == "Ok") {
            print(CSelecion);
            CSelecion.sort();
            print(CSelecion);
            for (int i = CSelecion.length - 1; i >= 0; i--) {
              cartMano.removeAt(CSelecion[i]);
            }
            selected.clear();
            for (int i = 0; i < cartMano.length; i++) {
              selected.add(false);
            }
            CSelecion.clear();
            // for (String comb in datos["cartas"]) {
            //   List<Carta> temp = [];
            //   print("comb:");
            //   print(comb);
            //   for (String c in comb) {
            //     List<String> listaNumeros = c.split(",");
            //     int valor = int.parse(listaNumeros[0]);
            //     int palo = int.parse(listaNumeros[1]);
            //     temp.add(Carta(valor, palo));
            //   }
            //   t.add(temp);
            //   setState(() {
            //
            //   });
            // }
            openSnackBar(
                context, const Text('Combinacion añadida correctamente'));
            String data =
                '{"emisor": "${widget.MiCodigo}","tipo": "Mostrar_tablero"}';
            widget.ws_partida!.sink.add(data);

            data = '{"emisor": "${widget.MiCodigo}","tipo": "Mostrar_manos"}';
            widget.ws_partida!.sink.add(data);
            // Navigator.pop(context);
            // Navigator.push(context,
            //   MaterialPageRoute(
            //       builder: (context) =>
            //           BoardPage(ws_partida: widget.ws_partida,
            //               idPartida: widget.idPartida,
            //               MiCodigo: widget.MiCodigo,
            //               turnos: widget.turnos,
            //               ranked: widget.ranked,
            //               creador: widget.creador,
            //               email: widget.email)),);
          } else if (int.tryParse(datos["info"]) == null) {
            selected.clear();
            for (int i = 0; i < cartMano.length; i++) {
              selected.add(false);
            }
            openSnackBar(context,
                const Text('Combinacion no valida, intentelo de nuevo'));
          } else {
            String ganador = datos["info"];
            String jugador = widget.turnos[ganador]!;
            abrir = 0;
            v = true;
            descarte = null;
            cartMano.clear();
            t_actual = widget.turnos["0"]!;
            if (t_actual == widget.MiCodigo) {
              modo = 1;
            } else {
              modo = 0;
            }
            showDialog(
                context: context,
                builder: (context) => WinnerDialog(
                      ganador: jugador,
                      ranked: widget.ranked,
                      email: widget.email,
                      idPartida: widget.idPartida,
                      MiCodigo: widget.MiCodigo,
                      turnos: widget.turnos,
                      creador: widget.creador,
                      ws_partida: widget.ws_partida,
                    ));
          }
        } else if (datos["tipo"] == "Abrir") {
          print('abrir');
          if (datos["info"] == "Ok") {
            CSelecion.clear();
            openSnackBar(context, const Text('Has abierto correctamente'));
            Indices_abrir.clear();
            Cartas_abrir.clear();
            abrir = 2;
            selected.clear();
            for (int i = 0; i < cartMano.length; i++) {
              selected.add(false);
            }

            String data =
                '{"emisor": "${widget.MiCodigo}","tipo": "Mostrar_tablero"}';
            widget.ws_partida!.sink.add(data);

            data = '{"emisor": "${widget.MiCodigo}","tipo": "Mostrar_manos"}';
            widget.ws_partida!.sink.add(data);
            // Navigator.pop(context);
            // Navigator.push(context,
            //   MaterialPageRoute(
            //       builder: (context) =>
            //           BoardPage(ws_partida: widget.ws_partida,
            //               idPartida: widget.idPartida,
            //               MiCodigo: widget.MiCodigo,
            //               turnos: widget.turnos,
            //               ranked: widget.ranked,
            //               creador: widget.creador,
            //               email: widget.email)),);
          } else {
            Cartas_abrir.clear();
            Indices_abrir.clear();
            openSnackBar(
                context,
                const Text(
                    'No puedes abrir con esas cartas, necesitas un minimo de 51 puntos'));
            selected.clear();
            for (int i = 0; i < cartMano.length; i++) {
              selected.add(false);
            }
            String data =
                '{"emisor": "${widget.MiCodigo}","tipo": "Mostrar_tablero"}';
            widget.ws_partida!.sink.add(data);

            data = '{"emisor": "${widget.MiCodigo}","tipo": "Mostrar_manos"}';
            widget.ws_partida!.sink.add(data);
            // Navigator.pushReplacement(context,
            //   MaterialPageRoute(
            //       builder: (context) =>
            //           BoardPage(ws_partida: widget.ws_partida,
            //               idPartida: widget.idPartida,
            //               MiCodigo: widget.MiCodigo,
            //               turnos: widget.turnos,
            //               ranked: widget.ranked,
            //               creador: widget.creador,
            //               email: widget.email)),);
          }
        } else if (datos["tipo"] == "Robar_carta_descartes") {
          print('robar_carta_descartes');
          if (datos["info"] != null) {
            modo = 2;
            openSnackBar(context, const Text('Carta robada'));
            if (v) {
              openSnackBar(
                  context,
                  const Text(
                      'Para terminar tu turno deja una carta en el monton de descartes'));
            }
            List<String> listaNumeros = datos["info"].split(",");
            int valor = int.parse(listaNumeros[0]);
            int palo = int.parse(listaNumeros[1]);
            mostrar_carta.add(true);
            cartMano.add(Carta(valor, palo));
            print("robada");
            print(cartMano.length);
            descarte = null;
            setState(() {});
            // Navigator.pop(context);
            // Navigator.push(context,
            //   MaterialPageRoute(
            //       builder: (context) =>
            //           BoardPage(ws_partida: widget.ws_partida,
            //               idPartida: widget.idPartida,
            //               MiCodigo: widget.MiCodigo,
            //               turnos: widget.turnos,
            //               ranked: widget.ranked,
            //               creador: widget.creador,
            //               email: widget.email)),);
          }
        } else if (datos["tipo"] == "Colocar_carta") {
          print('colocar_carta');
          print(datos);
          if (datos["info"] == "Ok") {
            CSelecion.clear();
            openSnackBar(context, const Text('Carta colocada correctamente'));
            String data =
                '{"emisor": "${widget.MiCodigo}","tipo": "Mostrar_tablero"}';
            widget.ws_partida!.sink.add(data);

            data = '{"emisor": "${widget.MiCodigo}","tipo": "Mostrar_manos"}';
            widget.ws_partida!.sink.add(data);
            // Navigator.pushReplacement(context,
            //   MaterialPageRoute(
            //       builder: (context) =>
            //           BoardPage(ws_partida: widget.ws_partida,
            //               idPartida: widget.idPartida,
            //               MiCodigo: widget.MiCodigo,
            //               turnos: widget.turnos,
            //               ranked: widget.ranked,
            //               creador: widget.creador,
            //               email: widget.email)),);
          } else if (datos["info"].toString().startsWith("0,")) {
            CSelecion.clear();
            openSnackBar(context, const Text('Carta cambiada por jocker'));
            String data =
                '{"emisor": "${widget.MiCodigo}","tipo": "Mostrar_tablero"}';
            widget.ws_partida!.sink.add(data);

            data = '{"emisor": "${widget.MiCodigo}","tipo": "Mostrar_manos"}';
            widget.ws_partida!.sink.add(data);
            // Navigator.pushReplacement(context,
            //   MaterialPageRoute(
            //       builder: (context) =>
            //           BoardPage(ws_partida: widget.ws_partida,
            //               idPartida: widget.idPartida,
            //               MiCodigo: widget.MiCodigo,
            //               turnos: widget.turnos,
            //               ranked: widget.ranked,
            //               creador: widget.creador,
            //               email: widget.email)),);
          } else if (int.tryParse(datos["info"]) == null) {
            openSnackBar(
                context,
                const Text(
                    'No puedes colocar una carta porque no has abierto'));
          } else {
            String ganador = datos["info"];
            String jugador = widget.turnos[ganador]!;
            abrir = 0;
            v = true;
            descarte = null;
            cartMano.clear();
            t_actual = widget.turnos["0"]!;
            if (t_actual == widget.MiCodigo) {
              modo = 1;
            } else {
              modo = 0;
            }
            showDialog(
                context: context,
                builder: (context) => WinnerDialog(
                      ganador: jugador,
                      ranked: widget.ranked,
                      email: widget.email,
                      idPartida: widget.idPartida,
                      MiCodigo: widget.MiCodigo,
                      turnos: widget.turnos,
                      creador: widget.creador,
                      ws_partida: widget.ws_partida,
                    ));
          }
        } else if (datos["tipo"] == "Descarte") {
          print('descarte');
          if (datos["ganador"] == "") {
            t_actual = widget.turnos[datos["turno"]]!;
            if (t_actual == widget.MiCodigo) {
              modo = 1;
              if (datos["abrir"] == "si") {
                abrir = 2;
              } else {
                abrir = 0;
              }
              if (v) {
                openSnackBar(
                    context, const Text('Roba una carta para comenzar'));
              }
            } else {
              modo = 0;
            }
            if (datos["descartes"] != null) {
              String d = datos["descartes"][0];
              List<String> listaNumeros = d.split(",");
              int valor = int.parse(listaNumeros[0]);
              int palo = int.parse(listaNumeros[1]);
              descarte = PlayingCard(PaloToSuit(palo), NumToValue(valor));
            }
            if (datos["combinaciones"] != null) {
              t.clear();
              for (List<dynamic> comb in datos["combinaciones"]) {
                List<Carta> temp = [];
                print("comb:");
                print(comb);
                for (String c in comb) {
                  List<String> listaNumeros = c.split(",");
                  int valor = int.parse(listaNumeros[0]);
                  int palo = int.parse(listaNumeros[1]);
                  temp.add(Carta(valor, palo));
                }
                t.add(temp);
              }
            }
            if (t_actual == widget.MiCodigo) {
              String data =
                  '{"emisor": "${widget.MiCodigo}","tipo": "Mostrar_manos"}';
              widget.ws_partida!.sink.add(data);
            }
            setState(() {});
            // Navigator.pop(context);
            // Navigator.push(context,
            //   MaterialPageRoute(
            //       builder: (context) =>
            //           BoardPage(ws_partida: widget.ws_partida,
            //               idPartida: widget.idPartida,
            //               MiCodigo: widget.MiCodigo,
            //               turnos: widget.turnos,
            //               ranked: widget.ranked,
            //               creador: widget.creador,
            //               email: widget.email)),);
          } else {
            String ganador = datos["ganador"];
            String jugador = widget.turnos[ganador]!;
            abrir = 0;
            v = true;
            descarte = null;
            cartMano.clear();
            t_actual = widget.turnos["0"]!;
            if (t_actual == widget.MiCodigo) {
              modo = 1;
            } else {
              modo = 0;
            }
            showDialog(
                context: context,
                builder: (context) => WinnerDialog(
                      ganador: jugador,
                      ranked: widget.ranked,
                      email: widget.email,
                      idPartida: widget.idPartida,
                      MiCodigo: widget.MiCodigo,
                      turnos: widget.turnos,
                      creador: widget.creador,
                      ws_partida: widget.ws_partida,
                    ));
          }
        }
      } else if ((datos["tipo"] == "Colocar_carta" ||
              datos["tipo"] == "Colocar_combinacion") &&
          int.tryParse(datos["info"]) != null) {
        String ganador = datos["info"];
        String jugador = widget.turnos[ganador]!;
        abrir = 0;
        v = true;
        descarte = null;
        cartMano.clear();
        t_actual = widget.turnos["0"]!;
        if (t_actual == widget.MiCodigo) {
          modo = 1;
        } else {
          modo = 0;
        }
        showDialog(
            context: context,
            builder: (context) => WinnerDialog(
                  ganador: jugador,
                  ranked: widget.ranked,
                  email: widget.email,
                  idPartida: widget.idPartida,
                  MiCodigo: widget.MiCodigo,
                  turnos: widget.turnos,
                  creador: widget.creador,
                  ws_partida: widget.ws_partida,
                ));
      } else if (datos["tipo"] == "Partida_Pausada") {
        openSnackBar(context, const Text('Partida Pausada'));
        if (widget.creador) {
          Navigator.pop(context);
        }
        Navigator.pop(context);
        Navigator.pop(context);
      }
    });

    if (widget.actualizar &&
        t_actual != "bot1" &&
        t_actual != "bot2" &&
        t_actual != "bot3") {
      String data =
          '{"emisor": "${widget.MiCodigo}","tipo": "Mostrar_tablero"}';
      widget.ws_partida!.sink.add(data);

      data = '{"emisor": "${widget.MiCodigo}","tipo": "Mostrar_manos"}';
      widget.ws_partida!.sink.add(data);
    } else {
      print("load");
      _load = true;
      setState(() {
        _load = true;
      });
    }
  }

  Future<void> procesarFotos() async {
    fotos.clear();
    for (int i = 0; i < widget.turnos.length; i++) {
      if (widget.turnos[i.toString()] != "bot1" &&
          widget.turnos[i.toString()] != "bot2" &&
          widget.turnos[i.toString()] != "bot3") {
        Map<String, dynamic>? user =
            await getUserCode(widget.turnos[i.toString()]!);
        fotos.add(user!["foto"]);
      } else {
        fotos.add(2);
      }
    }
    _load2 = true;
    setState(() {});
  }

  @override
  void dispose() {
    //Permitir que la pantalla se pueda apagar
    Wakelock.disable();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    AudioManager.toggleBGM(false);

    subscription_p.cancel();
    widget.ws_partida!.sink.close();
    super.dispose();
  }

  bool compararCombinaciones(List<Carta> comb1, List<Carta> comb2) {
    if (comb1.length != comb2.length) {
      return false;
    }
    bool iguales = true;
    for (int i = 0; i < comb1.length; i++) {
      Carta c1 = comb1.elementAt(i);
      Carta c2 = comb2.elementAt(i);
      if (c1.numero == c2.numero && c1.palo == c2.palo) {
        iguales = true;
      } else {
        if (c1.numero == c2.numero && c1.numero == 0) {
          iguales = true;
        } else {
          return false;
        }
      }
    }
    return iguales;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    return WillPopScope(
      onWillPop: () async {
        if (widget.creador && modo == 1) {
          showDialog(
              context: context,
              builder: (context) => PauseGameDialog(
                    codigo: widget.MiCodigo,
                    idPartida: widget.idPartida,
                  ));
        } else {
          openSnackBar(
              context,
              const Text(
                  "Solo puede parar una partida su creador en su turno"));
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: !_load || !_load2
            ? const Center(child: CircularProgressIndicator())
            : Container(
                color: Colors.green.shade900,
                child: Column(children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: List.generate(
                                    widget.turnos.length,
                                        (index) => AnimatedContainer(
                                        height: 50,
                                        duration: const Duration(
                                            milliseconds: 300),
                                        decoration: BoxDecoration(
                                          color: t_actual !=
                                              widget.turnos[
                                              "$index"]
                                              ? Theme.of(context)
                                              .colorScheme
                                              .secondaryContainer
                                              : Colors
                                              .indigoAccent[100],
                                          borderRadius:
                                          BorderRadius.circular(30),
                                        ),
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding:
                                              const EdgeInsets
                                                  .fromLTRB(
                                                  0, 3, 0, 3),
                                              child: CircularBorderPicture(
                                                  image: ProfileImage
                                                      .urls[
                                                  fotos[index] %
                                                      9]!),
                                            ),
                                            Column(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text("${widget.turnos[index.toString()]}", style: const TextStyle(fontWeight: FontWeight.bold),),
                                                  Text('${widget.num_cartas[index.toString()]} cartas')
                                                ]),
                                            const Spacer(),
                                            widget.ranked
                                                ? Points(value: int.parse(puntos[index]))
                                                : const SizedBox.shrink(),
                                            const SizedBox(width: 10,)
                                          ],
                                        )),
                                  ))
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                              children: t.map((e) => Column(
                                children: [
                                  CardView(
                                      ws_partida: widget.ws_partida,
                                      c: e,
                                      mano: false,
                                      idPartida: widget.idPartida,
                                      MiCodigo: widget.MiCodigo),
                                ],
                              ))
                                  .toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                    width: MediaQuery.of(context).size.width,
                    height: 110,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: FractionalOffset.topCenter,
                        end: FractionalOffset.bottomCenter,
                        colors: [
                          /*
                        Colors.brown.shade900,
                        Colors.brown,
                        Colors.brown.shade900
                        */
                          Theme.of(context).colorScheme.secondaryContainer,
                          Theme.of(context).colorScheme.tertiaryContainer,
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        Container(
                          height: 100,
                          width: 70,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Theme.of(context).colorScheme.primary),
                              borderRadius: BorderRadius.circular(10)),
                          child: GestureDetector(
                            onTap: () {
                              if (modo == 1) {
                                String data =
                                    '{"emisor": "${widget.MiCodigo}","tipo": "Robar_carta"}';
                                widget.ws_partida!.sink.add(data);
                              } else if (modo == 0) {
                                openSnackBar(
                                    context, const Text('No es tu turno'));
                              } else {
                                openSnackBar(
                                    context, const Text("Ya has robado"));
                              }
                            },
                            child: PlayingCardView(
                              card: PlayingCard(Suit.hearts, CardValue.ace),
                              style: setStyle(),
                              showBack: true,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Container(
                          height: 100,
                          width: 70,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Theme.of(context).colorScheme.primary),
                              borderRadius: BorderRadius.circular(10)),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              if (modo == 1 && descarte != null && abrir != 0) {
                                String data =
                                    '{"emisor": "${widget.MiCodigo}","tipo": "Robar_carta_descartes"}';
                                widget.ws_partida!.sink.add(data);
                              } else if (modo == 1 &&
                                  descarte != null &&
                                  abrir == 0) {
                                openSnackBar(
                                    context, const Text('Aun no has abierto'));
                              } else if (modo == 2) {
                                print(CSelecion.length);
                                if (CSelecion.length == 1) {
                                  v = false;
                                  String data =
                                      '{"emisor": "${widget.MiCodigo}","tipo": "Descarte", "info": "${CSelecion[0]}"}';
                                  cartMano.removeAt(CSelecion[0]);
                                  mostrar_carta.removeAt(CSelecion[0]);
                                  selected[CSelecion[0]] =
                                  !selected[CSelecion[0]];
                                  CSelecion.clear();
                                  widget.ws_partida!.sink.add(data);
                                } else {
                                  openSnackBar(
                                      context,
                                      const Text(
                                          'Debes seleccionar una carta para descartar'));
                                }
                              } else {
                                openSnackBar(
                                    context, const Text('No es tu turno'));
                              }
                            },
                            child: descarte == null
                                ? Container(
                              height: 100,
                              width: 70,
                            )
                                : PlayingCardView(
                              card: descarte!,
                              style: setStyle(),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: CardView(
                              ws_partida: widget.ws_partida,
                              c: cartMano,
                              mano: true,
                              idPartida: widget.idPartida,
                              MiCodigo: widget.MiCodigo),
                        ),
                        Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            width: 200,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                abrir == 1
                                    ? const SizedBox.shrink()
                                    : Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      tooltip: 'Salir de la partida',
                                      onPressed: () async {
                                        if (widget.creador && modo == 1) {
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  PauseGameDialog(
                                                    codigo:
                                                    widget.MiCodigo,
                                                    idPartida:
                                                    widget.idPartida,
                                                  ));
                                        } else {
                                          openSnackBar(
                                              context,
                                              const Text(
                                                  "Solo puede parar una partida su creador en su turno"));
                                        }
                                      },
                                      icon: Icon(
                                        Icons.exit_to_app,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Ver reglas',
                                      onPressed: _openRulesPage,
                                      icon: Icon(
                                        Icons.info,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Mostrar chat',
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ChatPage(
                                                    amistad: false,
                                                    idPartida:
                                                    widget.idPartida,
                                                    MiCodigo:
                                                    widget.MiCodigo,
                                                  )),
                                        );
                                      },
                                      icon: Icon(
                                        Icons.chat,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ],
                                ),
                                CustomFilledButton(
                                  height: 40,
                                  content: abrir == 0
                                      ? const Text('Abrir')
                                      : const Text('Añadir Combinación'),
                                  onPressed: () {
                                    setState(() {
                                      if (modo == 2 && abrir == 0) {
                                        abrir = 1;
                                        openSnackBar(
                                            context,
                                            const Text(
                                                'Añade las combinaciones para abrir'));
                                      } else if (modo == 1) {
                                        openSnackBar(
                                            context,
                                            const Text(
                                                'Roba una carta para comenzar'));
                                      } else {
                                        if (CSelecion.isNotEmpty) {
                                          if (abrir == 1) {
                                            List<int> temp_i = [];
                                            for (int i in CSelecion) {
                                              temp_i.add(i);
                                              mostrar_carta[i] = false;
                                            }
                                            Indices_abrir.add(temp_i);

                                            List<Carta> temp = [];
                                            for (int i in CSelecion) {
                                              temp.add(cartMano[i]);
                                            }
                                            Cartas_abrir.add(temp);

                                            // CSelecion.sort((a, b) => b.compareTo(a));
                                            // for (int i in CSelecion) {
                                            //   cartMano.removeAt(i);
                                            // }
                                            CSelecion.clear();
                                            if (v) {
                                              openSnackBar(
                                                  context,
                                                  const Text(
                                                      'Se han eviado las cartas, una vez hayas colocado las suficientes combinaciones '
                                                          'para abrir pulsa Fin Abrir y recibiras los resultados'));
                                            }
                                            setState(() {});
                                            // Navigator.pushReplacement(context,
                                            //   MaterialPageRoute(
                                            //       builder: (context) =>
                                            //           BoardPage(
                                            //             actualizar: false,
                                            //             ws_partida: widget.ws_partida,
                                            //             idPartida: widget.idPartida,
                                            //             MiCodigo: widget.MiCodigo,
                                            //             turnos: widget.turnos,
                                            //             ranked: widget.ranked,
                                            //             creador: widget.creador,
                                            //             email: widget.email)),);
                                          } else if (abrir == 2) {
                                            String _cartas =
                                            CSelecion[0].toString();
                                            for (int i = 1;
                                            i < CSelecion.length;
                                            i++) {
                                              _cartas = _cartas +
                                                  "," +
                                                  CSelecion[i].toString();
                                            }
                                            _cartas = "\"$_cartas\"";
                                            List<String> cartas = [_cartas];
                                            String data =
                                                '{"emisor": "${widget.MiCodigo}","tipo": "Colocar_combinacion", "cartas": $cartas}';
                                            widget.ws_partida!.sink.add(data);
                                          }
                                        } else {
                                          openSnackBar(
                                              context,
                                              const Text(
                                                  'Debes seleccionar las cartas a añadir'));
                                        }
                                      }
                                    });
                                  },
                                ),
                                abrir == 1
                                    ? CustomFilledButton(
                                  height: 40,
                                  content: const Text('Fin Abrir'),
                                  onPressed: () {
                                    setState(() {
                                      if (modo == 2) {
                                        List<String> cartas = [];
                                        for (List<int> i
                                        in Indices_abrir) {
                                          String _cartas =
                                          i[0].toString();
                                          for (int j = 1;
                                          j < i.length;
                                          j++) {
                                            _cartas = _cartas +
                                                "," +
                                                i[j].toString();
                                          }
                                          _cartas = "\"$_cartas\"";
                                          cartas.add(_cartas);
                                        }
                                        abrir = 0;
                                        print("$cartas");
                                        String data =
                                            '{"emisor": "${widget.MiCodigo}","tipo": "Abrir", "cartas": $cartas}';
                                        widget.ws_partida!.sink.add(data);
                                        //mandar peticion a logica de que quiero cerrar
                                      }
                                    });
                                  },
                                )
                                    : const SizedBox.shrink(),
                              ],
                            )),
                      ],
                    ),
                  )
                ]),
              ),
        /*
      appBar: AppBar(
        title: Text('Turno de: $t_actual'),
        actions: [
          IconButton(
            tooltip: 'Ver reglas',
            onPressed: _openRulesPage,
            icon: const Icon(Icons.info),
          ),
          IconButton(
            tooltip: 'Ver jugadores',
            onPressed: _openBottomSheet,
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      */
      ),
    );
  }

  Future _openBottomSheet() => showModalBottomSheet(
        context: context,
        builder: (context) => ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.turnos.length,
          itemBuilder: (context, index) {
            return ListTile(
                leading: CircularBorderPicture(
                    image: ProfileImage.urls[fotos[index] % 9]!),
                title: Row(
                  children: [
                    Text(
                      "${widget.turnos[index.toString()]}",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                trailing: !widget.ranked
                    ? Badge(
                        label: Text(
                            '${widget.num_cartas[index.toString()]} cartas'))
                    : Badge(
                        label: Text(
                            '${puntos[index]} puntos // ${widget.num_cartas[index.toString()]} cartas')));
          },
          separatorBuilder: (context, index) => const Divider(),
        ),
      );

  void _openRulesPage() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const RulesPage()));
  }
}

class CardView extends StatefulWidget {
  final List<Carta> c;
  final bool mano;
  final String idPartida;
  final String MiCodigo;
  final ws_partida;
  const CardView({
    Key? key,
    required this.ws_partida,
    required this.c,
    required this.mano,
    required this.idPartida,
    required this.MiCodigo,
  }) : super(key: key);
  @override
  State<CardView> createState() => _CardViewState();
}

Suit PaloToSuit(int p) {
  Suit? s;
  if (p == 1) {
    // espadas
    s = Suit.spades;
  } else if (p == 2) {
    //copas
    s = Suit.clubs;
  } else if (p == 3) {
    // bastos
    s = Suit.diamonds;
  } else if (p == 4) {
    //oros
    s = Suit.hearts;
  }
  return s!;
}

int SuitToPalo(Suit p) {
  int? s;
  if (p == Suit.spades) {
    // espadas
    s = 1;
  } else if (p == Suit.clubs) {
    //copas
    s = 2;
  } else if (p == Suit.diamonds) {
    // bastos
    s = 3;
  } else {
    //oros
    s = 4;
  }
  return s!;
}

CardValue NumToValue(int n) {
  if (n == 0) {
    return CardValue.joker_2;
  }
  return SUITED_VALUES[(n - 2) % 13];
}

int ValueToNum(CardValue v) {
  int n;
  if (v == CardValue.joker_2) {
    n = 0;
  } else {
    n = (SUITED_VALUES.indexOf(v) + 2) % 13;
    if (n == 0) n = 13;
  }
  return n;
}

bool compararCartas(Carta c1, Carta c2) {
  if (c1.numero == c2.numero && c1.palo == c2.palo) {
    return true;
  } else {
    if (c1.numero == c2.numero && c1.numero == 0) {
      return true;
    } else {
      return false;
    }
  }
}

PlayingCardViewStyle setStyle() {
  return PlayingCardViewStyle(suitStyles: {
    Suit.spades: SuitStyle(
        builder: (context) => const FittedBox(
              fit: BoxFit.fitHeight,
              child: Text(
                "⚔",
                style: TextStyle(fontSize: 40),
              ),
            ),
        style: const TextStyle(color: Colors.lightBlueAccent),
        cardContentBuilders: {
          CardValue.jack: (context) => Image.asset("images/espadas_sota.png"),
          CardValue.queen: (context) =>
              Image.asset("images/espadas_caballo.png"),
          CardValue.king: (context) => Image.asset("images/espadas_rey.png"),
        }),
    Suit.hearts: SuitStyle(
        builder: (context) => const FittedBox(
              fit: BoxFit.fitHeight,
              child: Text(
                "⊛",
                style: TextStyle(fontSize: 40),
              ),
            ),
        style: const TextStyle(color: Colors.orange),
        cardContentBuilders: {
          CardValue.jack: (context) => Image.asset("images/oros_sota.png"),
          CardValue.queen: (context) => Image.asset("images/oros_caballo.png"),
          CardValue.king: (context) => Image.asset("images/oros_rey.png"),
        }),
    Suit.diamonds: SuitStyle(
        builder: (context) => const FittedBox(
              fit: BoxFit.fitHeight,
              child: Text(
                "۲",
                style: TextStyle(fontSize: 40),
              ),
            ),
        style: const TextStyle(color: Colors.green),
        cardContentBuilders: {
          CardValue.jack: (context) => Image.asset("images/bastos_sota.png"),
          CardValue.queen: (context) =>
              Image.asset("images/bastos_caballo.png"),
          CardValue.king: (context) => Image.asset("images/bastos_rey.png"),
        }),
    Suit.clubs: SuitStyle(
        builder: (context) => const FittedBox(
              fit: BoxFit.fitHeight,
              child: Text(
                "🍷",
                style: TextStyle(fontSize: 40),
              ),
            ),
        style: const TextStyle(color: Colors.red),
        cardContentBuilders: {
          CardValue.jack: (context) => Image.asset("images/copas_sota.png"),
          CardValue.queen: (context) => Image.asset("images/copas_caballo.png"),
          CardValue.king: (context) => Image.asset("images/copas_rey.png"),
        }),
    Suit.joker: SuitStyle(builder: (context) => Container()),
  });
}

class _CardViewState extends State<CardView> {
  Suit suit = Suit.spades;
  CardValue value = CardValue.ace;

  PlayingCardViewStyle myCardStyles = setStyle();
  List<PlayingCard>? deck;

  @override
  void initState() {
    super.initState();
    deck = _createDeck(widget.c);
    selected.clear();
    for (int i = 0; i < deck!.length; i++) {
      selected.add(false);
    }
  }

  List<PlayingCard> _createDeck(List<Carta> c) {
    List<PlayingCard> deck = standardFiftyTwoCardDeck();
    deck.clear();
    for (Carta i in c) {
      if (i.numero == 0) {
        deck.add(PlayingCard(Suit.joker, CardValue.joker_2));
      } else {
        deck.add(PlayingCard(PaloToSuit(i.palo), NumToValue(i.numero)));
      }
    }
    return deck;
  }

  @override
  Widget build(BuildContext context) {
    deck = _createDeck(widget.c);
    if (deck!.length > selected.length) {
      for (int i = selected.length; i < deck!.length; i++) {
        selected.add(false);
      }
    }
    print(selected);
    return SizedBox(
      width: double.infinity,
      height: 110,
      child: Stack(
        children: deck!.asMap().entries.map((entry) {
          final numCards = deck!.asMap().entries.length;
          final width = MediaQuery.of(context).size.width;
          double availableSpace =
              width - 390 - 70.0; // 70.0 es el ancho de la tarjeta
          double spacing = availableSpace / (numCards - 1);
          final int index = entry.key;
          final PlayingCard card = entry.value;
          if (widget.mano) {
            return mostrar_carta[index]
                ? AnimatedPositioned(
                    bottom: selected[index] ? 10 : 0,
                    left: numCards <= 10
                        ? (width - 390 - (numCards + 1) * 35) / 2 + index * 35.0
                        : index * spacing,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease,
                    child: GestureDetector(
                      child: SizedBox(
                        width: 70,
                        height: 100,
                        child: PlayingCardView(
                          card: card,
                          style: myCardStyles,
                          shape: selected[index]
                              ? RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    width: 3,
                                  ),
                                )
                              : null, // No shape border when not selected
                        ),
                      ),
                      onTap: () {
                        AudioManager.toggleSFX(true);
                        setState(() {
                          if (modo == 2) {
                            if (widget.mano) {
                              selected[index] = !selected[index];
                              if (selected[index]) {
                                CSelecion.add(index);
                              } else {
                                CSelecion.remove(index);
                              }
                            }
                          } else if (modo == 1) {
                            openSnackBar(context,
                                const Text('Roba una carta para comenzar'));
                          }
                        });
                      },
                    ),
                  )
                : const SizedBox();
          } else {
            return AnimatedPositioned(
              left: numCards <= 10
                  ? ((width - (width / 7 * 2)) - (numCards + 1) * 35) / 2 +
                      index * 35.0
                  : index * spacing,
              duration: const Duration(milliseconds: 300),
              curve: Curves.ease,
              child: GestureDetector(
                child: SizedBox(
                  width: 70,
                  height: 100,
                  child: PlayingCardView(
                    card: card,
                    style: myCardStyles,
                  ),
                ),
                onTap: () {
                  AudioManager.toggleSFX(true);
                  setState(() {
                    if (modo == 2) {
                      if (abrir == 2) {
                        if (CSelecion.length > 1) {
                          openSnackBar(
                              context,
                              const Text(
                                  'Solo puedes añadir cartas a una combinacion de 1 en 1'));
                        } else {
                          int i = t.indexOf(widget.c);
                          String inf = "${i.toString()},${CSelecion[0]}";
                          String data =
                              '{"emisor": "${widget.MiCodigo}","tipo": "Colocar_carta", "info": "$inf"}';
                          widget.ws_partida.sink.add(data);
                        }
                      }
                    } else if (modo == 1) {
                      openSnackBar(
                          context, const Text('Roba una carta para comenzar'));
                    }
                  });
                },
              ),
            );
          }
        }).toList(),
      ),
    );
  }
}
