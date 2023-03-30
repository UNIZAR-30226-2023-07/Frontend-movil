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
  Map<String, dynamic>? amigos;
  bool _load = false;
  late List<dynamic> lista_amigos;
  @override
  void initState() {
    super.initState();
    _getAmistades();
  }

  Future<void> _getAmistades() async {
    if(widget.codigo == "#admin"){
      _load = true;
      setState(() { });
      lista_amigos = [
        [{'Nombre': 'Amigo falso', 'Descp': 'Hola', 'Foto': '2'}]
      ];
    }
    amigos = await getAmistades(widget.codigo, context);
    lista_amigos = amigos!.values.toList();
    _load = true;
    setState(() { });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: !_load
          ? Center(child: CircularProgressIndicator())
          :Column(
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
                  )
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text('Amigos',
                style: Theme.of(context).textTheme.headlineSmall),
          ),
          Expanded(
            child: lista_amigos.isNotEmpty
                ? Container() : ListView.separated(
              itemCount: lista_amigos[0].length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircularBorderPicture(),
                  title: Row(
                    children:  [
                      Text(
                        (lista_amigos[0][index])["Nombre"],
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  subtitle: Text((lista_amigos[0][index])["Descp"]),
                  trailing: Badge(
                    label: Text('1'), //Text((amigos![index])[1])
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
