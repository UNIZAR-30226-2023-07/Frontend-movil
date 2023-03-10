import 'package:flutter/material.dart';

class TournamentPage extends StatelessWidget {
  const TournamentPage({super.key, required this.id});
  final int id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Torneo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 200,
              child: Hero(
                tag: id,
                child: const Icon(
                  Icons.wine_bar,
                  size: 150,
                  color: Colors.amber,
                ),
              ),
            ),
            Container(
              height: 200,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.indigoAccent, width: 1),
                  borderRadius: BorderRadius.circular(20)
              ),
              child: ListView.builder(
                itemCount: 16,
                itemBuilder: (context, index) {
                  return const ListTile(
                    title: Text('adasdasd'),
                  );
                },
              ),
            ),
            FilledButton(
              onPressed: (){},
              child: const Text('Unirse'),
            ),
          ],
        ),
      ),
    );
  }
}