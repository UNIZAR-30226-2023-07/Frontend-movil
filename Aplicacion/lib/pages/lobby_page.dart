import 'package:flutter/material.dart';
import 'board_page.dart';
import '../widgets/circular_border_picture.dart';

class LobbyPage extends StatelessWidget {
  const LobbyPage({super.key, required this.ranked});
  final bool ranked;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ranked == false
        ? const Text('Partida normal')
        : const Text('Partida clasificatoria'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const CircularBorderPicture(),
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
                );
              },
              separatorBuilder: (context, index) => const Divider(),
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
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BoardPage()),
                );
              },
              child: const Text('Empezar partida'),
            ),
            const Text('work in progress'),
          ],
        ),
      ),
    );
  }
}