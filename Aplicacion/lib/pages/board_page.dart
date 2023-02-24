import 'package:flutter/material.dart';

class BoardPage extends StatefulWidget {
  const BoardPage({super.key});
  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage>{

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
            child:Text(
              "Aqui irian mis cartas",
              textAlign: TextAlign.center,
              style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            )
          )
      ]),
      appBar: AppBar(
        title: Text('Turno de: '),

      ),
    );
  }
}