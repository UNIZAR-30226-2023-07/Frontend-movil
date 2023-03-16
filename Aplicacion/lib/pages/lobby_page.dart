import 'package:flutter/material.dart';
import 'board_page.dart';
import '../widgets/custom_filled_button.dart';
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
                itemCount: 4,
                itemBuilder: (context, index) {
                  return Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: CircularBorderPicture(),
                      ),
                      Text(
                        'Amigo falso',
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BoardPage()),
                );
              }
            ),
          ],
        ),
      ),
    );
  }
}