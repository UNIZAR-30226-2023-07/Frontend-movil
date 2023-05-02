import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';
import 'package:untitled/dialogs/pause_game_dialog.dart';
import 'package:untitled/dialogs/winner_dialog.dart';
import 'package:untitled/services/audio_manager.dart';
import 'package:untitled/services/http_petitions.dart';
import 'package:web_socket_channel/io.dart';
import '../pages/chat_page.dart';
import '../services/open_snack_bar.dart';
import '../services/profile_image.dart';
import '../widgets/circular_border_picture.dart';

const String _IP = '52.166.36.105';
const String _PUERTO = '3001';

List<int> CSelecion= [];

List<List<Carta>> Cartas_abrir = [];
List<List<int>> Indices_abrir = [];

List<Carta> cartMano= [];
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

class BoardPage extends StatefulWidget {
  BoardPage({Key? key,this.actualizar = true,required this.email,required this.ws_partida, this.init = false, required this.idPartida,
    required this.MiCodigo, required this.turnos, required this.ranked, this.creador = false}) : super(key: key);
  String idPartida;
  IOWebSocketChannel ws_partida;
  String MiCodigo;
  bool creador;
  bool init, actualizar;
  bool ranked;
  String email;
  Map<String, String> turnos;
  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage>{
  bool _load = false;
  late StreamSubscription subscription_p;
  late List<int> fotos = <int>[];

  @override
  void initState() {
    super.initState();
    fotos.clear();
    AudioManager.toggleBGM(true);
    if(widget.init) {
      cartMano.clear();
      t_actual = widget.turnos["0"]!;
      if (t_actual == widget.MiCodigo) {
        modo = 1;
      } else {
        modo = 0;
      }
    }
    procesarFotos();


    if(!widget.ranked) {
      widget.ws_partida = IOWebSocketChannel.connect(
          'ws://$_IP:$_PUERTO/api/ws/partida/${widget.idPartida}');
    } else{
      widget.ws_partida = IOWebSocketChannel.connect(
          'ws://$_IP:$_PUERTO/api/ws/torneo/${widget.idPartida}');
    }
    widget.ws_partida.stream.handleError((error) {
      print('Error: $error');
    });

    subscription_p = widget.ws_partida.stream.listen((message) {
      Map<String, dynamic> datos = jsonDecode(message);
      if(datos["receptor"] == widget.MiCodigo || datos["receptor"] == "todos") {
        if (datos["tipo"] == "Mostrar_manos") {
            _load = false;
            print('mostar_manos');
            for (int j = 0; j < widget.turnos.length; j++) {
              if (widget.turnos[j.toString()] == widget.MiCodigo) {
                List<dynamic> cartas = datos["manos"][j];
                cartMano.clear();
                mostrar_carta.clear();
                List<Carta> temp = [];
                for (String i in cartas) {
                  List<String> listaNumeros = i.split(",");
                  int valor = int.parse(listaNumeros[0]);
                  int palo = int.parse(listaNumeros[1]);
                  temp.add(Carta(valor, palo));
                }
                setState(() {
                  cartMano = temp;
                  for (int i = 0; i < cartMano.length; i++){
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
            openSnackBar(context, const Text('Para terminar tu turno deja una carta en el monton de descartes'));
            Navigator.pop(context);
            Navigator.push(context,
              MaterialPageRoute(
                  builder: (context) =>
                      BoardPage(ws_partida: widget.ws_partida,
                          idPartida: widget.idPartida,
                          MiCodigo: widget.MiCodigo,
                          turnos: widget.turnos,
                          ranked: widget.ranked,
                          creador: widget.creador,
                          email: widget.email,)),);
          }
        }
        else if (datos["tipo"] == "Mostrar_tablero") {
          print('mostrar_tablero');
          if (datos["descartes"] != null) {
            String d = datos["descartes"][0];
            List<String> listaNumeros = d.split(",");
            int valor = int.parse(listaNumeros[0]);
            int palo = int.parse(listaNumeros[1]);
            descarte = PlayingCard(PaloToSuit(palo), NumToValue(valor));
          }
          t.clear();
          for (List<dynamic> comb in datos["combinaciones"]) {
            List<Carta> temp = [];
            print("comb:");
            print (comb);
            for (String c in comb) {
              List<String> listaNumeros = c.split(",");
              int valor = int.parse(listaNumeros[0]);
              int palo = int.parse(listaNumeros[1]);
              temp.add(Carta(valor, palo));
            }
            t.add(temp);
          }
        } else if (datos["tipo"] == "Colocar_combinacion") {
          print('colocar_combinacion');
          if (datos["info"] == "Ok") {
            CSelecion.clear();
            openSnackBar(context, const Text('Combinacion añadida correctamente'));
            Navigator.pop(context);
            Navigator.push(context,
              MaterialPageRoute(
                  builder: (context) =>
                      BoardPage(ws_partida: widget.ws_partida,
                          idPartida: widget.idPartida,
                          MiCodigo: widget.MiCodigo,
                          turnos: widget.turnos,
                          ranked: widget.ranked,
                          creador: widget.creador,
                          email: widget.email)),);
          } else
          if (int.tryParse(datos["info"]) == null ) {
            openSnackBar(context, const Text('Combinacion no valida, intentelo de nuevo'));
          } else {
            String ganador = datos["info"];
            String jugador = widget.turnos[ganador]!;
            showDialog(
                context: context,
                builder: (context) => WinnerDialog(ganador: jugador, ranked: widget.ranked, email: widget.email,));
          }
        }
        else if (datos["tipo"] == "Abrir") {
          print('abrir');
          if (datos["info"] == "Ok") {
            CSelecion.clear();
            openSnackBar(context, const Text('Has abierto correctamente'));
            Indices_abrir.clear();
            Cartas_abrir.clear();
            abrir = 2;
            Navigator.pop(context);
            Navigator.push(context,
              MaterialPageRoute(
                  builder: (context) =>
                      BoardPage(ws_partida: widget.ws_partida,
                          idPartida: widget.idPartida,
                          MiCodigo: widget.MiCodigo,
                          turnos: widget.turnos,
                          ranked: widget.ranked,
                          creador: widget.creador,
                          email: widget.email)),);
          } else {
            Cartas_abrir.clear();
            Indices_abrir.clear();
            openSnackBar(context, const Text('No puedes abrir con esas cartas, necesitas un minimo de 51 puntos'));
            Navigator.pop(context);
            Navigator.push(context,
              MaterialPageRoute(
                  builder: (context) =>
                      BoardPage(ws_partida: widget.ws_partida,
                          idPartida: widget.idPartida,
                          MiCodigo: widget.MiCodigo,
                          turnos: widget.turnos,
                          ranked: widget.ranked,
                          creador: widget.creador,
                          email: widget.email)),);
          }
        } else if (datos["tipo"] == "Robar_carta_descartes") {
          print('robar_carta_descartes');
          if (datos["info"] != null) {
            modo = 2;
            openSnackBar(context, const Text('Carta robada'));
            openSnackBar(context, const Text('Para terminar tu turno deja una carta en el monton de descartes'));
            Navigator.pop(context);
            Navigator.push(context,
              MaterialPageRoute(
                  builder: (context) =>
                      BoardPage(ws_partida: widget.ws_partida,
                          idPartida: widget.idPartida,
                          MiCodigo: widget.MiCodigo,
                          turnos: widget.turnos,
                          ranked: widget.ranked,
                          creador: widget.creador,
                          email: widget.email)),);
          }
        } else if (datos["tipo"] == "Colocar_carta") {
          print('colocar_carta');
          if (datos["info"] == "Ok") {
            CSelecion.clear();
            openSnackBar(context, const Text('Carta colocada correctamente'));
            Navigator.pop(context);
            Navigator.push(context,
              MaterialPageRoute(
                  builder: (context) =>
                      BoardPage(ws_partida: widget.ws_partida,
                          idPartida: widget.idPartida,
                          MiCodigo: widget.MiCodigo,
                          turnos: widget.turnos,
                          ranked: widget.ranked,
                          creador: widget.creador,
                          email: widget.email)),);
          } else if (int.tryParse(datos["info"]) == null){
            openSnackBar(context, const Text('No puedes colocar una carta porque no has abierto'));
          } else{
            String ganador = datos["info"];
            String jugador = widget.turnos[ganador]!;
            showDialog(
                context: context,
                builder: (context) => WinnerDialog(ganador: jugador, ranked: widget.ranked, email: widget.email,));
          }
        }
        else if (datos["tipo"] == "Descarte") {
          print('descarte');
          if(datos["ganador"] == "") {
            t_actual = widget.turnos[datos["turno"]]!;
            if (t_actual == widget.MiCodigo) {
              modo = 1;
              if (datos["abrir"] == "si") {
                abrir = 2;
              } else {
                abrir = 0;
              }
              openSnackBar(context, const Text('Roba una carta para comenzar'));
            } else {
              modo = 0;
            }
            Navigator.pop(context);
            Navigator.push(context,
              MaterialPageRoute(
                  builder: (context) =>
                      BoardPage(ws_partida: widget.ws_partida,
                          idPartida: widget.idPartida,
                          MiCodigo: widget.MiCodigo,
                          turnos: widget.turnos,
                          ranked: widget.ranked,
                          creador: widget.creador,
                          email: widget.email)),);
          } else{
            String ganador = datos["ganador"];
            String jugador = widget.turnos[ganador]!;
            showDialog(
                context: context,
                builder: (context) => WinnerDialog(ganador: jugador, ranked: widget.ranked, email: widget.email,));
          }
        }
        else if (datos["tipo"] == "Partida_Pausada") {
          openSnackBar(context, const Text('Partida Pausada'));
          Navigator.pop(context);
          Navigator.pop(context);
          Navigator.pop(context);
        }
      }
      else if((datos["tipo"] == "Colocar_carta" || datos["tipo"] == "Colocar_combinacion") && int.tryParse(datos["info"]) != null){
        String ganador = datos["info"];
        String jugador = widget.turnos[ganador]!;
        showDialog(
            context: context,
            builder: (context) => WinnerDialog(ganador: jugador, ranked: widget.ranked, email: widget.email,));
      }
    });

      if(widget.actualizar) {
        String data = '{"emisor": "${widget
            .MiCodigo}","tipo": "Mostrar_tablero"}';
        widget.ws_partida.sink.add(data);

        data = '{"emisor": "${widget.MiCodigo}","tipo": "Mostrar_manos"}';
        widget.ws_partida.sink.add(data);
      } else{
        setState(() {
          _load = true;
        });
      }

  }

  Future<void> procesarFotos() async {
    fotos.clear();
    for (int i = 0; i < widget.turnos.length; i++) {
      Map<String, dynamic>? user = await getUserCode(widget.turnos[i.toString()]!);
      fotos.add(user!["foto"]);
    }
  }

  @override
  void dispose() {
    subscription_p.cancel();
    widget.ws_partida.sink.close();
    AudioManager.toggleBGM(false);
    super.dispose();
  }

  bool compararCombinaciones(List<Carta> comb1, List<Carta> comb2){
    if(comb1.length != comb2.length){
      return false;
    }
    bool iguales = true;
    for(int i = 0; i < comb1.length; i++) {
      Carta c1 = comb1.elementAt(i);
      Carta c2 = comb2.elementAt(i);
      if (c1.numero == c2.numero && c1.palo == c2.palo) {
         iguales = true;
      } else {
        if (c1.numero == c2.numero && c1.numero == 0) {
          iguales = true;
        }
        else {
          return false;
        }
      }
    }
    return iguales;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          if(widget.creador) {
            showDialog(
                context: context,
                builder: (context) =>  PauseGameDialog(codigo: widget.MiCodigo, idPartida: widget.idPartida,)
            );
          } else{
            openSnackBar(context, Text("Solo puede parar una partida su creador"));
            return false;
          }
      return true;
    },
    child: Scaffold(
      body: !_load
          ? const Center(child: CircularProgressIndicator())
      :Container(
        color: Colors.green.shade900,
        child: Column(
            children: [
              const SizedBox(height: 10),
              SizedBox(
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: GestureDetector(
                        onTap: () {
                          if (modo == 1) {
                            String data = '{"emisor": "${widget.MiCodigo}","tipo": "Robar_carta"}';
                            widget.ws_partida.sink.add(data);
                          } else if(modo == 0){
                            openSnackBar(context, const Text('No es tu turno'));
                          } else {
                            openSnackBar(context, const Text("Ya has robado"));
                          }
                        },
                        child: PlayingCardView(
                          card: PlayingCard(Suit.hearts, CardValue.ace),
                          style: setStyle(),
                          showBack: true,
                        ),
                      ),
                    ),
                    abrir == 1 ?
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          if (modo == 2) {
                            List<String> cartas = [];
                            for(List<int> i in Indices_abrir){
                              String _cartas = i[0].toString();
                              for (int j = 1; j < i.length; j++) {
                                _cartas = _cartas + "," +
                                    i[j].toString();
                              }
                              _cartas = "\"$_cartas\"";
                              cartas.add(_cartas);
                            }
                            abrir = 0;
                            print("$cartas");
                            String data = '{"emisor": "${widget.MiCodigo}","tipo": "Abrir", "cartas": $cartas}';
                            widget.ws_partida.sink.add(data);
                              //mandar peticion a logica de que quiero cerrar
                          }
                        });
                      },
                      child: const Text('Fin Abrir'),
                    )
                        : Container(
                      height: 100,
                      width: 70,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (modo == 1 && descarte != null) {
                            String data = '{"emisor": "${widget.MiCodigo}","tipo": "Robar_carta_descartes"}';
                            widget.ws_partida.sink.add(data);
                          } else if (modo == 2) {
                            if (CSelecion.length == 1) {
                              String data = '{"emisor": "${widget.MiCodigo}","tipo": "Descarte", "info": "${CSelecion[0]}"}';
                              CSelecion.clear();
                              widget.ws_partida.sink.add(data);
                            } else{
                              openSnackBar(context, const Text('Debes seleccionar una carta para descartar'));
                            }
                          } else{
                            openSnackBar(context, const Text('No es tu turno'));
                          }
                        },
                        child: descarte == null ? Container(
                          height: 100,
                          width: 70,
                        )
                            : PlayingCardView(
                          card: descarte!, style: setStyle(),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Stack(
                          children:[
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(context,
                                  MaterialPageRoute(builder: (
                                      context) => ChatPage( amistad: false, idPartida: widget.idPartida, MiCodigo: widget.MiCodigo,)),);
                              },
                              child: const Text('Mostrar chat'),
                            ),

                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              if(modo == 2 && abrir == 0){
                                abrir = 1;
                                openSnackBar(context, const Text('Añade las combinaciones para abrir'));
                              }
                              else if(modo == 1){
                                openSnackBar(context, const Text('Roba una carta para comenzar'));
                              }
                              else {
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
                                    openSnackBar(context, const Text('Se han eviado las cartas, una vez hayas colocado las suficientes combinaciones '
                                        'para abrir pulsa Fin Abrir y recibiras los resultados'));
                                    Navigator.pushReplacement(context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              BoardPage(
                                                actualizar: false,
                                                ws_partida: widget.ws_partida,
                                                idPartida: widget.idPartida,
                                                MiCodigo: widget.MiCodigo,
                                                turnos: widget.turnos,
                                                ranked: widget.ranked,
                                                creador: widget.creador,
                                                email: widget.email)),);
                                  }
                                  else if (abrir == 2) {
                                    String cartas = CSelecion[0].toString();
                                    for (int i = 1; i < CSelecion.length; i++) {
                                      cartas = cartas + "," +
                                          CSelecion[i].toString();
                                    }
                                    cartas = "\"$cartas\"";
                                    String data = '{"emisor": "${widget
                                        .MiCodigo}","tipo": "Colocar_combinacion", "cartas": $cartas}';
                                    widget.ws_partida.sink.add(data);
                                  }
                                }
                                else{
                                  openSnackBar(context, const Text('Debes seleccionar las cartas a añadir'));
                                }
                              }
                            });
                          },
                          child: abrir == 0 ? const Text('Abrir') : const Text('Añadir Combinación'),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 10,),
              const Divider(color: Colors.white,),
              Expanded(
                child:SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: t.map((e) =>
                      Column(
                        children: [
                          CardView(ws_partida: widget.ws_partida, c: e, mano: false,idPartida: widget.idPartida,MiCodigo: widget.MiCodigo),
                          const Divider(color: Colors.white,),
                        ],
                      )).toList(),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: FractionalOffset.topCenter,
                    end: FractionalOffset.bottomCenter,
                    colors: [
                      Colors.brown.shade900,
                      Colors.brown,
                      Colors.brown.shade900
                    ],
                  ),
                ),

                child: CardView(ws_partida: widget.ws_partida,c: cartMano,mano: true,idPartida: widget.idPartida,MiCodigo: widget.MiCodigo),
              )
            ]),
      ),
      appBar: AppBar(
        title: Text('Turno de: $t_actual'),
        actions: [
          IconButton(
            onPressed: _openBottomSheet,
            icon: const Icon(Icons.person),
          ),
        ],
      ),
    ),
    );
  }
  Future _openBottomSheet() => showModalBottomSheet(
    context: context,
    builder: (context) => ListView.separated(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: widget.turnos.length,
    itemBuilder: (context, index)  {
      return ListTile(
        leading: CircularBorderPicture(image: ProfileImage.urls[fotos[index] % 6]!),
        title: Row(
          children: [
            Text(
              "${widget.turnos[index.toString()]}",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold
              ),
            ),
          ],
        ),
        trailing: t_actual == index.toString() ? Badge(
          label: Text('Jugando'),
        ) : Badge(),
        onTap: () {},
      );
    },
    separatorBuilder: (context, index) => const Divider(),
  ),
  );

}

class CardView extends StatefulWidget {
  final List<Carta> c;
  final bool mano;
  final String idPartida;
  final String MiCodigo;
  final ws_partida;
  const CardView({Key? key,required this.ws_partida, required this.c,required this.mano, required this.idPartida,required this.MiCodigo,} ) : super(key: key);
  @override
  State<CardView> createState() => _CardViewState();
}


Suit PaloToSuit(int p){
  Suit? s;
  if (p == 1){  // espadas
    s = Suit.spades;
  } else if (p == 2){  //copas
    s = Suit.clubs;
  } else if (p == 3){  // bastos
    s = Suit.diamonds;
  } else if (p == 4){ //oros
    s = Suit.hearts;
  }
  return s!;
}

int SuitToPalo(Suit p){
  int? s;
  if (p == Suit.spades){  // espadas
    s = 1;
  } else if (p == Suit.clubs){  //copas
    s = 2;
  } else if (p == Suit.diamonds){  // bastos
    s = 3;
  } else { //oros
    s = 4;
  }
  return s!;
}

CardValue NumToValue(int n){
  if (n == 0){
    return CardValue.joker_2;
  }
  return SUITED_VALUES[(n-2)%13];
}

int ValueToNum(CardValue v){
  int n;
  if(v == CardValue.joker_2){
    n = 0;
  } else {
    n = (SUITED_VALUES.indexOf(v)+2)%13;
    if (n == 0) n = 13;
  }
  return n;
}

bool compararCartas(Carta c1, Carta c2){
  if (c1.numero == c2.numero && c1.palo == c2.palo){
    return true;
  } else{
    if (c1.numero == c2.numero && c1.numero == 0){
      return true;
    }
    else {
      return false;
    }
  }
}

PlayingCardViewStyle setStyle(){
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
          CardValue.jack: (context) =>
              Image.asset("images/espadas_sota.png"),
          CardValue.queen: (context) =>
              Image.asset("images/espadas_caballo.png"),
          CardValue.king: (context) =>
              Image.asset("images/espadas_rey.png"),
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
          CardValue.jack: (context) =>
              Image.asset("images/oros_sota.png"),
          CardValue.queen: (context) =>
              Image.asset("images/oros_caballo.png"),
          CardValue.king: (context) =>
              Image.asset("images/oros_rey.png"),
        }),
    Suit.diamonds: SuitStyle(
        builder: (context) => const FittedBox(
          fit: BoxFit.fitHeight,
          child: Text(
            "↾",
            style: TextStyle(fontSize: 40),
          ),
        ),
        style: const TextStyle(color: Colors.green),
        cardContentBuilders: {
          CardValue.jack: (context) =>
              Image.asset("images/bastos_sota.png"),
          CardValue.queen: (context) =>
              Image.asset("images/bastos_caballo.png"),
          CardValue.king: (context) =>
              Image.asset("images/bastos_rey.png"),
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
          CardValue.jack: (context) =>
              Image.asset("images/copas_sota.png"),
          CardValue.queen: (context) =>
              Image.asset("images/copas_caballo.png"),
          CardValue.king: (context) =>
              Image.asset("images/copas_rey.png"),
        }
    ),

    Suit.joker: SuitStyle(
        builder: (context) => Container()),
  }
  );
}

class _CardViewState extends State<CardView> {
  Suit suit = Suit.spades;
  CardValue value = CardValue.ace;
  List<bool> selected = [];
  PlayingCardViewStyle myCardStyles = setStyle();
  List<PlayingCard>? deck;

  @override
  void initState() {
    super.initState();
    deck = _createDeck(widget.c);
    for (int i = 0 ; i < deck!.length; i++) {
      selected.add(false);
    }
  }

  List<PlayingCard> _createDeck(List<Carta> c) {
    List<PlayingCard> deck = standardFiftyTwoCardDeck();
    deck.clear();
    for (Carta i in c){
      if(i.numero == 0){
        deck.add(PlayingCard(Suit.joker, CardValue.joker_2));
      } else {
        deck.add(PlayingCard(PaloToSuit(i.palo), NumToValue(i.numero)));
      }
    }
    return deck;
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      height: 100,
      color: Colors.white.withOpacity(0),
      child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: deck!.asMap().entries.map((entry) {
              final int index = entry.key;
              final PlayingCard card = entry.value;
              if (widget.mano) {
                return mostrar_carta[index] ? GestureDetector(
                  child: PlayingCardView(
                    card: card,
                    style: myCardStyles,
                    shape: selected[index]
                        ? RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: Colors.lightBlueAccent,
                        width: 3,
                      ),
                    )
                        : null, // No shape border when not selected
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
                      } else if (modo == 1){
                        openSnackBar(context, const Text('Roba una carta para comenzar'));
                      }
                    });
                  },
                ) : SizedBox();
              } else {
                return GestureDetector(
                  child: PlayingCardView(
                    card: card,
                    style: myCardStyles,
                    shape: selected[index]
                        ? RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: Colors.lightBlueAccent,
                        width: 3,
                      ),
                    )
                        : null, // No shape border when not selected
                  ),
                  onTap: () {
                    AudioManager.toggleSFX(true);
                    setState(() {
                      if (modo == 2) {
                        if (abrir == 2) {
                          if(CSelecion.length > 1){
                            openSnackBar(context, const Text('Solo puedes añadir cartas a una combinacion de 1 en 1'));
                          } else {
                            int i = t.indexOf(widget.c);
                            String inf = "${i.toString()},${CSelecion[0]}";
                            String data = '{"emisor": "${widget
                                .MiCodigo}","tipo": "Colocar_carta", "info": "$inf"}';
                            widget.ws_partida.sink.add(data);
                          }
                        }
                      } else if (modo == 1){
                        openSnackBar(context, const Text('Roba una carta para comenzar'));
                      }
                    });
                  },
                );
              }
            }).toList(),
          ),
        ),
    );
  }
}

