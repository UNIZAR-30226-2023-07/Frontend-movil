import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';

class Carta {
  final int numero;
  final int palo;

  Carta(this.numero, this.palo);
}

class BoardPage extends StatefulWidget {
  const BoardPage({super.key});
  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage>{
  List<Carta> c= [
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.topCenter,
          child:Container(
              height: 600,
              decoration: BoxDecoration(
                color:Colors.green.shade900,
              ),
              child:Align(
                child: Container(
                  height: 580,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(width: 4.0, color: Colors.red.shade900),
                      bottom: BorderSide(width: 4.0, color: Colors.red.shade900),
                    ),
                  ),
                    child:SizedBox(
                      height: 580,
                      child:SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                        child: Column(
                          children: t.map((e) => CardView(e)).toList(),
                        ),
                      ),
                    ),
                ),
              ),
          ),
        ),
          const SizedBox(height: 10,),
          Container(
            height: 100,
            width: MediaQuery.of(context).size.width,
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

            child: CardView(c),
          )
      ]),
      appBar: AppBar(
        title: const Text('Turno de: '),

      ),
    );
  }
}

class CardView extends StatefulWidget {
  final List<Carta> c;
  const CardView(this.c, {Key? key}) : super(key: key);
  @override
  State<CardView> createState() => _CardViewState(c);
}


class _CardViewState extends State<CardView> {
  Suit suit = Suit.spades;
  CardValue value = CardValue.ace;
  final List<Carta> c;

  _CardViewState(this.c);

  PlayingCardViewStyle myCardStyles = PlayingCardViewStyle(suitStyles: {
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
  List<PlayingCard>? deck;

  @override
  void initState() {
    super.initState();
    deck = _createDeck(c);
  }

  List<PlayingCard> _createDeck(List<Carta> c) {
    List<PlayingCard> deck = standardFiftyTwoCardDeck();
    deck.clear();
    for (Carta i in c){
      if(i.numero == 0){
        deck.add(PlayingCard(Suit.joker, CardValue.joker_2));
      } else if (i.palo == 1){  // espadas
        deck.add(PlayingCard(Suit.spades, SUITED_VALUES[(i.numero-2)%13]));
      } else if (i.palo == 2){  //copas
        deck.add(PlayingCard(Suit.clubs, SUITED_VALUES[(i.numero-2)%13]));
      } else if (i.palo == 3){  // bastos
        deck.add(PlayingCard(Suit.diamonds, SUITED_VALUES[(i.numero-2)%13]));
      } else if (i.palo == 4){  // oros
        deck.add(PlayingCard(Suit.hearts, SUITED_VALUES[(i.numero-2)%13]));
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
            children: deck!.map((e) => PlayingCardView(card: e, style: myCardStyles)).toList(),
          ),
        ),
    );
  }
}



      //   children: [
      //
      //    PlayingCardView(
      //         card: PlayingCard(suit, value),
      //         style: myCardStyles),
      //
      //     Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      //       DropdownButton<Suit>(
      //           value: suit,
      //           items: Suit.values
      //               .map((s) =>
      //               DropdownMenuItem(value: s, child: Text(s.toString())))
      //               .toList(),
      //           onChanged: (val) {
      //             setState(() {
      //               suit = val!;
      //             });
      //           }),
      //       DropdownButton<CardValue>(
      //           value: value,
      //           items: CardValue.values
      //               .map((s) =>
      //               DropdownMenuItem(value: s, child: Text(s.toString())))
      //               .toList(),
      //           onChanged: (val) {
      //             setState(() {
      //               value = val!;
      //             });
      //           }),
      //     ])
      //   ],

