import 'package:flutter/material.dart';
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
      body: ListView.separated(
        itemCount: 20,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircularBorderPicture(),
            title: Row(
              children: [
                Text(
                  (amigos![index])[0],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
            subtitle: Text((amigos![index])[2]),
            trailing: Badge(
              label: Text((amigos![index])[1]),
            ),
            onTap: () {},
          );
        },
        separatorBuilder: (context, index) => const Divider(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        tooltip: 'Añadir amigo',
        onPressed: () {
          openDialog(context, AddFriendDialog(codigo: widget.codigo));
        },
        child: const Icon(Icons.add_rounded, size: 30, color: Colors.white,),
      ),
    );
  }
}