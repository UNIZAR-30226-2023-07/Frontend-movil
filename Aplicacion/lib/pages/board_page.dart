import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';
import 'package:untitled/dialogs/pause_game_dialog.dart';
import 'package:untitled/services/audio_manager.dart';
import 'package:web_socket_channel/io.dart';
import '../pages/chat_page.dart';
import '../widgets/circular_border_picture.dart';

const String _IP = '52.174.124.24';
const String _PUERTO = '3001';

List<int> CSelecion= [];

List<List<Carta>> Cartas_abrir = [];

List<Carta> cartMano= [];

List<Map<String, dynamic>> msg = [];

List<List<Carta>> t = [
  // [Carta(2,2),
  //   Carta(3,2),
  //   Carta(4,2),
  //   Carta(4,2),
  //   Carta(4,2),
  //   Carta(4,2),Carta(4,2),
  //   Carta(4,2),
  //   Carta(4,2),
  //   Carta(4,2),
  // ],
  // [Carta(5,1),
  //   Carta(5,3),
  //   Carta(5,4),],
  // [Carta(12,4),
  //   Carta(13,4),
  //   Carta(1,4),],
  // [Carta(4,1),
  //   Carta(4,4),
  //   Carta(0,2),],
  // [Carta(1,3),
  //   Carta(2,3),
  //   Carta(3,3),],
  // [Carta(1,3),
  //   Carta(2,3),
  //   Carta(3,3),],
  // [Carta(1,3),
  //   Carta(2,3),
  //   Carta(3,3),],
];

class Carta {
  final int numero;
  final int palo;

  Carta(this.numero, this.palo);
}

int modo = 1; // 0 - no turno, 1 - encarte, 2 - colocar/descarte
PlayingCard? descarte;
int abrir = 0; //0 - tiene que abrir, 1 - esta abriendo, 2 - no tiene que abrir

class BoardPage extends StatefulWidget {
  BoardPage({Key? key, required this.idPartida,required this.MiCodigo, required this.turnos, required this.ranked, this.creador = false}) : super(key: key);
  String idPartida;
  //final ws_partida;
  String MiCodigo;
  bool creador;
  bool ranked;
  Map<String, String> turnos;
  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage>{
  late final ws_chat;
  late final ws_partida;
  bool nuevos_msg = false;
  bool _load = false;
  @override
  void initState() {
    super.initState();
    AudioManager.toggleBGM(true);
    msg.clear();
    setState(() {
    nuevos_msg = false;
    });
    cartMano.clear();
    ws_chat= IOWebSocketChannel.connect('ws://$_IP:$_PUERTO/api/ws/chat/lobby/${widget.idPartida}');
    ws_chat.stream.handleError((error) {
      print('Error: $error');
    });

    ws_chat.stream.listen((message) {
      setState(() {
        nuevos_msg = true;
      });
      print("mensaje reivido: " + message);
      Map<String, dynamic> datos = jsonDecode(message);
      bool esta = false;
      for(Map<String, dynamic> i in msg){
        if(datos["id"] == i["id"] && datos["codigo"] == i["codigo"]){
          esta = true;
        }
      }
      if(!esta) {
        msg.add(datos);
      }

    });

    if(!widget.ranked) {
      ws_partida = IOWebSocketChannel.connect(
          'ws://$_IP:$_PUERTO/api/ws/partida/${widget.idPartida}');
    } else{
      ws_partida = IOWebSocketChannel.connect(
          'ws://$_IP:$_PUERTO/api/ws/torneo/${widget.idPartida}');
    }
    ws_partida.stream.handleError((error) {
      print('Error: $error');
    });

    ws_partida.stream.listen((message) {
      Map<String, dynamic> datos = jsonDecode(message);
      if(datos["tipo"] == "Mostrar_manos") {
        _load = false;
        print('mostar_manos');
        for(int j = 0; j < widget.turnos.length; j++) {
          if(widget.turnos[j.toString()] == widget.MiCodigo) {
            List<dynamic> cartas = datos["manos"][j];
            cartMano.clear();
            List<Carta> temp = [];
            for (String i in cartas) {
              List<String> listaNumeros = i.split(",");
              int valor = int.parse(listaNumeros[0]);
              int palo = int.parse(listaNumeros[1]);
              temp.add(Carta(valor, palo));
            }
            setState(() {
              cartMano = temp;
              _load = true;
            });
          }
        }
      }
    });

      String data = '{"emisor": "${widget.MiCodigo}","tipo": "Mostrar_manos"}';
      ws_partida.sink.add(data);
  }

  @override
  void dispose() {
    AudioManager.toggleBGM(false);
    super.dispose();
  }

  @override
  void didUpdateWidget(BoardPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      nuevos_msg = false;
    });
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
          showDialog(
              context: context,
              builder: (context) => const PauseGameDialog()
          );
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
                            PlayingCard temp = PlayingCard(
                                Suit.hearts, CardValue.two);
                            Carta t2 = Carta(
                                ValueToNum(temp.value), SuitToPalo(temp.suit));
                            cartMano.insert(0, t2);
                            modo = 2;
                            Navigator.pop(context);
                            Navigator.push(context,
                              MaterialPageRoute(
                                  builder: (context) => BoardPage(idPartida: widget.idPartida,MiCodigo:  widget.MiCodigo,turnos: widget.turnos, ranked: widget.ranked)),);
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
                              //mandar peticion a logica de que quiero cerrar
                              for (List<Carta> comb in Cartas_abrir){
                                for(int i = 0; i < t.length; i++){
                                  List<Carta> tablero = t.elementAt(i);
                                  if (compararCombinaciones(tablero,comb)){
                                    t.removeAt(i);
                                  }
                                }
                                for(Carta cart in comb){
                                  cartMano.add(cart);
                                }
                              }
                              Cartas_abrir.clear();
                              abrir = 2;
                              // Navigator.pop(context);
                              // Navigator.push(context,
                              //   MaterialPageRoute(
                              //       builder: (context) => BoardPage(idPartida: widget.idPartida, MiCodigo: widget.MiCodigo,)),
                              //);
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
                            PlayingCard temp = PlayingCard(
                                descarte!.suit, descarte!.value);
                            Carta t2 = Carta(ValueToNum(temp.value), SuitToPalo(
                                temp.suit));
                            cartMano.insert(0, t2);
                            descarte = null;
                            modo = 2;
                            // Navigator.pop(context);
                            // Navigator.push(context,
                            //   MaterialPageRoute(builder: (
                            //       context) => BoardPage(idPartida: widget.idPartida, MiCodigo: widget.MiCodigo,)),
                            //);
                          } else if (modo == 2) {
                            if (CSelecion.length == 1) {
                              descarte = PlayingCard(PaloToSuit(
                                  cartMano[CSelecion[0]].palo),
                                  NumToValue(cartMano[CSelecion[0]].numero));
                              modo = 1;
                              cartMano.removeAt(CSelecion[0]);
                              CSelecion.clear();
                              // Navigator.pop(context);
                              // Navigator.push(context,
                              //   MaterialPageRoute(
                              //       builder: (context) => BoardPage(idPartida: widget.idPartida, MiCodigo: widget.MiCodigo,)),
                              // );
                            }
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
                                setState(() {
                                nuevos_msg = false;
                                });
                                Navigator.push(context,
                                  MaterialPageRoute(builder: (
                                      context) => ChatPage(msg: msg, amistad: false, idPartida: widget.idPartida, MiCodigo: widget.MiCodigo,)),);
                              },
                              child: const Text('Mostrar chat'),
                            ),
                            if (nuevos_msg)
                              Positioned(
                                right: 0,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              if(modo == 2 && abrir == 0){
                                //madar peticion abrir
                                abrir = 1;
                              }
                              else {
                                if (CSelecion.isNotEmpty) {
                                  t.insert(0, []);
                                  for (int i in CSelecion) {
                                    t[0].add(cartMano[i]);
                                  }
                                  if (abrir == 1) {
                                    List<Carta> temp = [];
                                    for (int i in CSelecion) {
                                      temp.add(cartMano[i]);
                                    }
                                    Cartas_abrir.add(temp);
                                  }
                                  CSelecion.sort((a, b) => b.compareTo(a));
                                  for (int i in CSelecion) {
                                    cartMano.removeAt(i);
                                  }
                                  CSelecion.clear();
                                  // Navigator.pushReplacement(context,
                                  //   MaterialPageRoute(
                                  //       builder: (
                                  //           context) => BoardPage(idPartida: widget.idPartida, MiCodigo: widget.MiCodigo,)),);
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
                          CardView(c: e, mano: false,idPartida: widget.idPartida,MiCodigo: widget.MiCodigo),
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

                child: CardView(c: cartMano,mano: true,idPartida: widget.idPartida,MiCodigo: widget.MiCodigo),
              )
            ]),
      ),
      appBar: AppBar(
        title: const Text('Turno de: '),
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
    itemCount: 4,
    itemBuilder: (context, index) {
      return ListTile(
        leading: CircularBorderPicture(),
        title: Row(
          children: const [
            Text(
              'Amigo falso',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold
              ),
            ),
          ],
        ),
        trailing: Badge(
          label: Text('Cartas en mano: 4'),
        ),
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
  const CardView({Key? key, required this.c,required this.mano, required this.idPartida,required this.MiCodigo,} ) : super(key: key);
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
            "𓇳",
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
            "𓋾",
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
                      if (widget.mano) {
                        selected[index] = !selected[index];
                        if (selected[index]) {
                          CSelecion.add(index);
                        } else {
                          CSelecion.remove(index);
                        }
                      } else if (abrir == 2) {
                        int i = t.indexOf(widget.c);
                        for (int j in CSelecion) {
                          setState(() {
                            t[i].add(cartMano[j]);
                          });
                        }
                        CSelecion.sort((a, b) => b.compareTo(a));
                        for (int j in CSelecion) {
                          cartMano.removeAt(j);
                        }
                        CSelecion.clear();
                        // Navigator.pop(context);
                        // Navigator.push(context,
                        //   MaterialPageRoute(
                        //       builder: (context) => BoardPage(idPartida: idPartida, MiCodigo: MiCodigo,)),);
                      }
                    }
                  });
                },
              );
            }).toList(),
          ),
        ),
    );
  }
}

