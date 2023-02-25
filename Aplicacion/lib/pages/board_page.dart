import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';

class BoardPage extends StatefulWidget {
  const BoardPage({super.key});
  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage>{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Turno de: '),
      ),
      body: Column(
        children: [
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.topCenter,
          child:Container(
              height: 600,
              width:370,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color:Colors.green.shade900,
              ),
            child:Align(
              child: Container(
                height: 580,
                width:350,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.red.shade900,
                    width: 4.0,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ),
          const SizedBox(height: 10,),
          Container(
            height: 100,
            // width: double.infinity también serviría porque lo que hace es ocupar todo el espacio que puede
            // no sé cual de los dos es mejor en este caso, pero es otra opción
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
            child: const CardView(),
            // child:const Text(
            //   "Aqui irian mis cartas",
            //   textAlign: TextAlign.center,
            //   style: TextStyle(
            //   color: Colors.white,
            //   fontSize: 20,
            //   fontWeight: FontWeight.bold,
            // ),
            // )
          )
      ]),
    );
  }
}

class CardView extends StatefulWidget {
  const CardView({super.key});

  @override
  State<CardView> createState() => _CardViewState();
}


class _CardViewState extends State<CardView> {
  Suit suit = Suit.spades;
  CardValue value = CardValue.ace;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [

         PlayingCardView(
              card: PlayingCard(suit, value),
              style: myCardStyles),

          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            DropdownButton<Suit>(
                value: suit,
                items: Suit.values
                    .map((s) =>
                    DropdownMenuItem(value: s, child: Text(s.toString())))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    suit = val!;
                  });
                }),
            DropdownButton<CardValue>(
                value: value,
                items: CardValue.values
                    .map((s) =>
                    DropdownMenuItem(value: s, child: Text(s.toString())))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    value = val!;
                  });
                }),
          ])
        ],
      ),
    );
  }
}
