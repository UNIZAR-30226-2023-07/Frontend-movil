import 'package:flutter/material.dart';
import 'package:untitled/dialogs/accept_friend_dialog.dart';
import '../dialogs/add_friend_dialog.dart';
import '../services/http_petitions.dart';
import '../services/open_dialog.dart';
import '../widgets/circular_border_picture.dart';

class FriendsPage extends StatefulWidget {
  final String codigo;
  FriendsPage({required this.codigo});
  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  // 0 - codigo amigo;
  // 1 - mensajes sin leer;
  // 2 - descripcion
  List<Map<String, dynamic>>? amigos;
  @override
  void initState() {
    super.initState();
    _getAmistades();
  }

  Future<void> _getAmistades() async {
    amigos = await getAmistades(widget.codigo, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text('Solicitudes de amistad',
                style: Theme.of(context).textTheme.headlineSmall),
          ),
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 10,
              itemBuilder: (context, index) {
                return GestureDetector(
                    onTap: () {
                      openDialog(context, const AcceptFriendDialog());
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(5),
                      child: CircularBorderPicture(),
                    ));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text('Amigos',
                style: Theme.of(context).textTheme.headlineSmall),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: 20,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircularBorderPicture(),
                  title: Row(
                    children: const [
                      Text(
                        'Amigo falso',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  subtitle: Text('perro'),
                  trailing: Badge(
                    label: Text('1'),
                  ),
                  onTap: () {},
                );
              },
              separatorBuilder: (context, index) => const Divider(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        tooltip: 'Añadir amigo',
        onPressed: () {
          openDialog(context, AddFriendDialog(codigo: widget.codigo));
        },
        child: const Icon(
          Icons.add_rounded,
          size: 30,
          color: Colors.white,
        ),
      ),
    );
  }
}
