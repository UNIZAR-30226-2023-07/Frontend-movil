import 'package:flutter/material.dart';
import 'package:untitled/dialogs/accept_friend_dialog.dart';
import 'package:untitled/services/profile_image.dart';
import '../dialogs/add_friend_dialog.dart';
import '../dialogs/remove_friend_dialog.dart';
import '../services/http_petitions.dart';
import '../services/open_dialog.dart';
import '../widgets/circular_border_picture.dart';
import 'chat_page.dart';
import 'profile_page.dart';

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
  Map<String, dynamic>? solicitudes;
  bool _load = false;
  late List<dynamic> lista_amigos;
  late List<dynamic> lista_solicitudes;
  @override
  void initState() {
    super.initState();
    _getAmistades();
    _getSolicitudes();
  }

  Future<void> _getAmistades() async {
    if(widget.codigo == "#admin"){
      lista_amigos = [      [{'Nombre': 'Amigo falso', 'Descp': 'Hola', 'Foto': '2'}]
      ];
    }
    amigos = await getAmistades(widget.codigo);
    lista_amigos = amigos!.values.toList();
  }

  Future<void> _getSolicitudes() async {
    if(widget.codigo == "#admin"){
      _load = true;
      lista_solicitudes = [      [{'Nombre': 'Amigo falso', 'Foto': '2'}]
      ];
    }
    solicitudes = await getSolicitudes(widget.codigo);
    lista_solicitudes = solicitudes!.values.toList();
    _load = true;
    setState(() {});
  }

  void showOptions(BuildContext context, Offset position, Map<String, dynamic> amigo) async {
    final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;
    final RelativeRect positionPopup = RelativeRect.fromRect(
      Rect.fromPoints(position, position),
      Offset.zero & overlay.size,
    );

    final result = await showMenu(
      context: context,
      position: positionPopup,
      items: <PopupMenuEntry>[
        const PopupMenuItem(
          child: Text('Eliminar amigo'),
          value: 'Eliminar',
        ),
        const PopupMenuItem(
          child: Text('Abrir chat'),
          value: 'Chat',
        ),
      ],
    );

    if (result == 'Eliminar') {
      await openDialog(context, RemoveFriendDialog(nombre: amigo["Nombre"],codigoEm: widget.codigo, codigoRec: amigo["Codigo"]));
      await _getAmistades();
      await _getSolicitudes();
      setState(() {});
      build(context);
    } else if (result == 'Chat') {
      Navigator.push(context,
        MaterialPageRoute(builder: (
            context) => const ChatPage()),
      );
      build(context);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: !_load
          ? const Center(child: CircularProgressIndicator())
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text('Solicitudes de amistad',
              style: Theme.of(context).textTheme.headlineSmall),
          ),
          SizedBox(
            height: 70,
            child: lista_solicitudes[0] == null
            ? Container() : ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: lista_solicitudes[0].length,
              itemBuilder: (context, index) {
                if ((lista_solicitudes[0][index])["Estado"] == "pendiente") {
                  return GestureDetector(
                      onTap: () async {
                        await openDialog(context, AcceptFriendDialog(
                            nombre: (lista_solicitudes[0][index])["Nombre"],
                            codigoEm: (lista_solicitudes[0][index])["Codigo"],
                            codigoRec: widget.codigo));
                        await _getAmistades();
                        await _getSolicitudes();
                        setState(() {});
                        build(context);
                      },
                      child: Padding(
                        padding: EdgeInsets.all(5),
                        child: CircularBorderPicture(image: ProfileImage
                            .urls[(lista_solicitudes[0][index])["Foto"] % 6]!),
                      )
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text('Amigos',
                style: Theme.of(context).textTheme.headlineSmall),
          ),
          Expanded(
            child: lista_amigos[0] == null
              ? Container()
              : ListView.separated(
              itemCount: lista_amigos[0].length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onLongPressStart: (LongPressStartDetails details) {
                    showOptions(context, details.globalPosition,(lista_amigos[0][index]));
                  },

                child: ListTile(
                  leading: CircularBorderPicture(image: ProfileImage.urls[(lista_amigos[0][index])["Foto"]%6]!),
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

                ),
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
        onPressed: () async {
           await openDialog(context, AddFriendDialog(codigo: widget.codigo));
          await _getAmistades();
          await _getSolicitudes();
          setState(() {});
          build(context);
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
