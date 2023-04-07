import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';
import 'package:untitled/dialogs/pause_game_dialog.dart';
import 'package:untitled/services/audio_manager.dart';
import '../pages/chat_page.dart';
import '../widgets/circular_border_picture.dart';

List<int> CSelecion= [];

List<Carta> cartMano= [
  Carta(1,1),
  Carta(2,1),
  Carta(7,2),
  Carta(11,2),
  Carta(12,3),
  Carta(13,3),
  Carta(10,3),
  Carta(3,4),
  Carta(9,4),
  Carta(0,2),
];
List<List<Carta>> t = [
  [Carta(2,2),
    Carta(3,2),
    Carta(4,2),
    Carta(4,2),
    Carta(4,2),
    Carta(4,2),Carta(4,2),
    Carta(4,2),
    Carta(4,2),
    Carta(4,2),
  ],
  [Carta(5,1),
    Carta(5,3),
    Carta(5,4),],
  [Carta(12,4),
    Carta(13,4),
    Carta(1,4),],
  [Carta(4,1),
    Carta(4,4),
    Carta(0,2),],
  [Carta(1,3),
    Carta(2,3),
    Carta(3,3),],
  [Carta(1,3),
    Carta(2,3),
    Carta(3,3),],
  [Carta(1,3),
    Carta(2,3),
    Carta(3,3),],
];

class Carta {
  final int numero;
  final int palo;

  Carta(this.numero, this.palo);
}

int modo = 1; // 0 - no turno, 1 - encarte, 2 - colocar/descarte
PlayingCard? descarte;

class BoardPage extends StatefulWidget {
  const BoardPage({Key? key}) : super(key: key);
  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage>{

  @override
  void initState() {
    super.initState();
    AudioManager.toggleBGM(true);
  }

  @override
  void dispose() {
    AudioManager.toggleBGM(false);
    super.dispose();
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
      body: Container(
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
                                  builder: (context) => const BoardPage()),);
                          }
                        },
                        child: PlayingCardView(
                          card: PlayingCard(Suit.hearts, CardValue.ace),
                          style: setStyle(),
                          showBack: true,
                        ),
                      ),
                    ),
                    Container(
                      height: 100,
                      width: 70,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: GestureDetector(
                        onTap: () {
                          if (modo == 1 && descarte != null) {
                            PlayingCard temp = PlayingCard(
                                descarte!.suit, descarte!.value);
                            Carta t2 = Carta(ValueToNum(temp.value), SuitToPalo(
                                temp.suit));
                            cartMano.insert(0, t2);
                            descarte = null;
                            modo = 2;
                            Navigator.pop(context);
                            Navigator.push(context,
                              MaterialPageRoute(builder: (
                                  context) => const BoardPage()),
                            );
                          } else if (modo == 2) {
                            if (CSelecion.length == 1) {
                              descarte = PlayingCard(PaloToSuit(
                                  cartMano[CSelecion[0]].palo),
                                  NumToValue(cartMano[CSelecion[0]].numero));
                              modo = 1;
                              cartMano.removeAt(CSelecion[0]);
                              CSelecion.clear();
                              Navigator.pop(context);
                              Navigator.push(context,
                                MaterialPageRoute(
                                    builder: (context) => const BoardPage()),
                              );
                            }
                          }
                        },
                        child: descarte == null ? SizedBox(
                          height: 100,
                          width: 70,
                        )
                            : PlayingCardView(
                          card: descarte!, style: setStyle(),),
                      ),

                    ),
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(context,
                              MaterialPageRoute(builder: (
                                  context) => const ChatPage()),);
                          },
                          child: const Text('Mostrar chat'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              if (CSelecion.isNotEmpty) {
                                t.insert(0, []);
                                for (int i in CSelecion) {
                                  t[0].add(cartMano[i]);
                                }
                                CSelecion.sort((a, b) => b.compareTo(a));
                                for (int i in CSelecion) {
                                  cartMano.removeAt(i);
                                }
                                CSelecion.clear();
                                Navigator.pushReplacement(context,
                                  MaterialPageRoute(
                                      builder: (context) => const BoardPage()),);
                              }
                            });
                          },
                          child: const Text('Añadir Combinación'),
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
                          CardView(e, false),
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

                child: CardView(cartMano, true),
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
  const CardView(this.c, this.mano,{Key? key}) : super(key: key);
  @override
  State<CardView> createState() => _CardViewState(c,mano);
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
  final List<Carta> c;
  List<bool> selected = [];
  final bool mano;
  _CardViewState(this.c, this.mano);

  PlayingCardViewStyle myCardStyles = setStyle();
  List<PlayingCard>? deck;

  @override
  void initState() {
    super.initState();
    deck = _createDeck(c);
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
                  setState(() {
                    if (modo == 2) {
                      if (mano) {
                        selected[index] = !selected[index];
                        if (selected[index]) {
                          CSelecion.add(index);
                        } else {
                          CSelecion.remove(index);
                        }
                      } else {
                        int i = t.indexOf(c);
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
                        Navigator.pop(context);
                        Navigator.push(context,
                          MaterialPageRoute(
                              builder: (context) => const BoardPage()),);
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

