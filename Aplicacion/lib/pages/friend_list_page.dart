import 'package:flutter/material.dart';
import 'package:untitled/dialogs/accept_friend_dialog.dart';
import 'package:untitled/services/profile_image.dart';
import '../dialogs/add_friend_dialog.dart';
import '../dialogs/deny_friend_dialog.dart';
import '../dialogs/remove_friend_dialog.dart';
import '../services/http_petitions.dart';
import '../services/open_dialog.dart';
import '../widgets/circular_border_picture.dart';
import 'chat_page.dart';
import 'profile_page.dart';

class FriendsPage extends StatefulWidget {
  final String codigo;
  const FriendsPage({super.key, required this.codigo});
  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  // 0 - codigo amigo;
  // 1 - mensajes sin leer;
  // 2 - descripcion
  Map<String, dynamic>? amigos;
  Map<String, dynamic>? solicitudes;
  Map<String, dynamic>? mensajes;
  bool _load = false;
  late List<dynamic> lista_amigos;
  late List<dynamic> lista_solicitudes;
  late List<dynamic> lista_mensajes;
  @override
  void initState() {
    super.initState();
    _getAmistades();
    _getMensajes();
    _getSolicitudes();
  }

  @override
  void didUpdateWidget(FriendsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _load = false;
    _getAmistades();
    _getMensajes();
    _getSolicitudes();
  }

  Future<void> _getAmistades() async {
    if(widget.codigo == "#admin"){
      lista_amigos = [      [{'Nombre': 'Amigo falso', 'Descp': 'Hola', 'Foto': 2, 'Codigo': '1'}]
      ];
    } else {
      amigos = await getAmistades(widget.codigo);
      lista_amigos = amigos!.values.toList();
    }
  }

  Future<void> _getSolicitudes() async {
    if(widget.codigo == "#admin"){
      _load = true;
      lista_solicitudes = [      [{'Nombre': 'Amigo falso', 'Foto': 2, 'Codigo':'1'}]
      ];
    } else {
      solicitudes = await getSolicitudes(widget.codigo);
      lista_solicitudes = solicitudes!.values.toList();
    }
    _load = true;
    setState(() {});
  }

  Future<void> _getMensajes() async {
    if(widget.codigo == "#admin"){
      lista_mensajes = [      [{'Emisor': '1', 'Receptor': '#admin', 'Contenido': 'Hola', 'Leido': 0}]
      ];
    } else {
      mensajes = await getMensajes(widget.codigo);
      lista_mensajes = mensajes!.values.toList();
    }
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
          value: 0,
          child: Text('Eliminar amigo'),
        ),
        const PopupMenuItem(
          value: 1,
          child: Text('Abrir chat'),
        ),
      ],
    );

    if (context.mounted) {
      if (result == 0) {
        await openDialog(context, RemoveFriendDialog(nombre: amigo["Nombre"],
            codigoEm: widget.codigo,
            codigoRec: amigo["Codigo"]));
        await _getAmistades();
        await _getMensajes();
        await _getSolicitudes();
        setState(() {});
        build(context);
      } else if (result == 1) {
        Navigator.push(context,
          MaterialPageRoute(builder: (context) =>
              ChatPage(MiCodigo: widget.codigo,
                  codigo2: amigo["Codigo"],
                  amistad: true)),
        );
        build(context);
      }
    }
  }

  String contarMsgPendientes(String emisor) {
    int n = 0;
    if(lista_mensajes[0] != null) {
      for (int i = 0; i < lista_mensajes[0].length; i++) {
        if ((lista_mensajes[0][i])["Emisor"] == emisor && (lista_mensajes[0][i])["Receptor"] == widget.codigo
        && (lista_mensajes[0][i])["Leido"] == 0){
          n++;
        }
      }
    }
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: !_load
        ? const Center(child: CircularProgressIndicator())
        : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          lista_solicitudes[0] == null
          ? const SizedBox()
          : Padding(
            padding: const EdgeInsets.all(10),
            child: Text('Solicitudes de amistad',
              style: Theme.of(context).textTheme.headlineSmall),
          ),
          lista_solicitudes[0] == null
          ? const SizedBox()
          : SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: lista_solicitudes[0].length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () async {
                      if ((lista_solicitudes[0][index])["Estado"] == "pendiente") {
                        await openDialog(context, AcceptFriendDialog(
                        nombre: (lista_solicitudes[0][index])["Nombre"],
                        codigoEm: (lista_solicitudes[0][index])["Codigo"],
                        codigoRec: widget.codigo));
                      } else {
                        await openDialog(context, DenyFriendDialog(
                        nombre: (lista_solicitudes[0][index])["Nombre"],
                        codigoEm: (lista_solicitudes[0][index])["Codigo"],
                        codigoRec: widget.codigo));
                      }
                      await _getAmistades();
                      await _getMensajes();
                      await _getSolicitudes();
                      setState(() {});
                      build(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: CircularBorderPicture(image: ProfileImage
                        .urls[(lista_solicitudes[0][index])["Foto"] % 6]!),
                  )
                );
              }
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
                  onTap: () async {
                    Map<String, dynamic>? user = await getUserCode((lista_amigos[0][index])["Codigo"]);
                    setState(() { });
                    if (context.mounted) {
                      Navigator.push(context,
                        MaterialPageRoute(builder: (
                            context) => ProfilePage(email: '', user: user)),
                      );
                    }
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
                    trailing: contarMsgPendientes((lista_amigos[0][index])["Codigo"]) == '0'
                      ? const SizedBox()
                      : Badge(
                        label: Text(contarMsgPendientes((lista_amigos[0][index])["Codigo"])), //Text((amigos![index])[1])
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
        tooltip: 'Añadir amigo',
        onPressed: () async {
          await openDialog(context, AddFriendDialog(codigo: widget.codigo));
          await _getAmistades();
          await _getMensajes();
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
