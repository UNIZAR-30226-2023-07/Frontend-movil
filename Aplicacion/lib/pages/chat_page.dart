import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:web_socket_channel/io.dart';
import '../services/http_petitions.dart';
import '../services/open_snack_bar.dart';
import '../services/profile_image.dart';
import '../widgets/circular_border_picture.dart';

List<String> msgs = [];
const String _IP = '52.174.124.24';
const String _PUERTO = '3001';

class ShowMessages extends StatefulWidget {
  const ShowMessages({super.key, required this.len, required this.MiCodigo});

  final List<dynamic> len;
  final String MiCodigo;

  @override
  State<ShowMessages> createState() => _ShowMessagesState();
}

class _ShowMessagesState extends State<ShowMessages> {
  ///final ScrollController _scrollController = ScrollController();

  /*
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    });
  }
  */
  late List<int> fotos = <int>[];
  bool _load = false;

  @override
  void initState(){
    super.initState();
    _load = false;
    fotos = <int>[];
    procesarMensajes();
  }

  @override
  void didUpdateWidget(ShowMessages oldWidget) {
    super.didUpdateWidget(oldWidget);
    _load = false;
    fotos = <int>[];
    procesarMensajes();
  }

  void procesarMensajes() async{
    fotos.clear();
    for(int i = 0; i < widget.len.length; i++){
      Map<String, dynamic>? user = await getUserCode(widget.len[i]["Emisor"]);
      fotos.add(user!["foto"]);
      if(widget.len[i]["Receptor"] == widget.MiCodigo) {
        bool res = await leerMensajes(
            widget.len[i]["Emisor"], widget.len[i]["Receptor"]);
        if (context.mounted) {
          if (!res) {
            openSnackBar(
                context, const Text('No se ha podido enviar la petición'));
          }
        }
      }
    }
    _load = true;
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return !_load
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
      ///controller: _scrollController,
      itemCount: widget.len.length,
      addAutomaticKeepAlives: true,
      itemBuilder: (context, index){
        final esMio = widget.len[index]["Emisor"] == widget.MiCodigo;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Padding(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                child: CircularBorderPicture(width: 52, height: 52, image: ProfileImage.urls[fotos[index] % 6]!),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: !esMio ? Theme.of(context).colorScheme.secondaryContainer :
                    Colors.indigoAccent[100],
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Text(widget.len[index]["Contenido"]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


class ChatPage extends StatefulWidget {
  const ChatPage({Key? key, this.MiCodigo = "",this.codigo2 = "", this.amistad = false}) : super(key: key);
  final String MiCodigo, codigo2;
  final bool amistad;
  @override
  State<ChatPage> createState() => _ChatPage();
}

class _ChatPage extends State<ChatPage> {
  final TextEditingController _textController = TextEditingController();

  List<String> msg = [];
  late List<dynamic> lista_mensajes = [[{'Emisor': '1', 'Receptor': '#admin', 'Contenido': 'Hola', 'Leido': 0}]];
  Map<String, dynamic>? mensajes;
  bool _load = false;
  late final wb_amistad;
  @override
  void initState() {
    super.initState();
    if(widget.amistad) {
      _getMensajes();
      wb_amistad = IOWebSocketChannel.connect('ws://$_IP:$_PUERTO/api/ws/chat/${widget.MiCodigo}');
      wb_amistad.stream.handleError((error) {
        print('Error: $error');
      });

      wb_amistad.stream.listen((message) {
        print('Received: $message');
      });

      // wb_amistad.stream.listen((event) {
      //   if (wb_amistad?.closeCode == null && wb_amistad?.closeReason == null) {
      //     if (wb_amistad?.readyState == WebSocket.open) {
      //       print("Conectado");
      //     }
      //   }
      // });
    }
  }

  Future<void> _getMensajes() async {
    if(widget.MiCodigo == "#admin"){
      lista_mensajes = [[{'Emisor': '1', 'Receptor': '#admin', 'Contenido': 'Hola', 'Leido': 0}]
      ];
    } else {
      mensajes = await getMensajes(widget.MiCodigo);
      lista_mensajes = mensajes!.values.toList();
      lista_mensajes = separarMensajesCodigo(widget.MiCodigo, widget.codigo2);
    }
    _load = true;
    setState(() {});
   // _load = true;
  }



  List<dynamic> separarMensajesCodigo(String codigo1, String codigo2) {
    int j = 0;
    List<dynamic>? lista_mensajes_amistad = <dynamic>[];
    if(lista_mensajes[0] != null) {
      for (int i = 0; i < lista_mensajes[0].length; i++) {
        if ((lista_mensajes[0][i])["Emisor"] == codigo1 && (lista_mensajes[0][i])["Receptor"] == codigo2
            || (lista_mensajes[0][i])["Emisor"] == codigo2 && (lista_mensajes[0][i])["Receptor"] == codigo1){
          lista_mensajes_amistad.add(lista_mensajes[0][i]);
          j++;
        }
      }
    }
    return lista_mensajes_amistad!;
  }



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        wb_amistad.sink.close();
        return true;
      },
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: !_load
    ? const Center(child: CircularProgressIndicator())
    :Column(
        children: [
          Expanded(child: ShowMessages(len: lista_mensajes, MiCodigo: widget.MiCodigo),),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(15),
                      hintText: "Introduce tu mensaje aquí",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 0, top: 5, right: 10, bottom: 5),
                child: FloatingActionButton(
                  elevation: 0,
                  tooltip: 'Enviar mensaje',
                  onPressed: () {
                    if (_textController.text.isNotEmpty) {
                      final data = '{"emisor": "${widget.MiCodigo}","receptor": "${widget.codigo2}", "contenido": "${_textController.text}"}';
                      final jsonString = jsonEncode(data);
                      wb_amistad.sink.add(data);
                      //msgs.add(_textController.text);
                      ///msg.add(_textController.text);
                      _textController.clear();
                      if(widget.amistad) {
                        _getMensajes();
                        lista_mensajes = separarMensajesCodigo(
                            widget.MiCodigo, widget.codigo2);
                      }
                      _load = false;
                      setState(() {});
                      build(context);
                    }
                  },
                  child: const Icon(Icons.send),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
  }
}
