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
  const ShowMessages({super.key, required this.len, required this.MiCodigo, required this.codigo2, required this.amistad});

  final List<dynamic> len;
  final String MiCodigo;
  final String codigo2;
  final bool amistad;

  @override
  State<ShowMessages> createState() => _ShowMessagesState();
}

class _ShowMessagesState extends State<ShowMessages> {
  late ScrollController _scrollController;
  late List<int> fotos = <int>[];
  bool _load = false;

  @override
  void initState(){
    super.initState();
    _load = false;
    fotos = <int>[];
    procesarMensajes();
    _scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ShowMessages oldWidget) {
    super.didUpdateWidget(oldWidget);
    _load = false;
    fotos = <int>[];
    procesarMensajes();
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  void procesarMensajes() async{
    fotos.clear();
    Map<String, dynamic>? user1 = await getUserCode(widget.MiCodigo);
    Map<String, dynamic>? user2 = await getUserCode(widget.codigo2);

    for(int i = 0; i < widget.len.length; i++){
      int foto = (widget.len[i]["Emisor"] == user1!["codigo"])? user1["foto"] : user2!["foto"];
      fotos.add(foto);
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
    : Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      child: Stack(
        children: [
          ListView.builder(
            controller: _scrollController,
            itemCount: widget.len.length,
            addAutomaticKeepAlives: true,
            itemBuilder: (context, index){
              final esMio = widget.len[index]["Emisor"] == widget.MiCodigo;
              return Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Container(
                  child: esMio
                  ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.60),
                        child: Container(
                          padding: const EdgeInsets.all(15.0),
                          decoration: BoxDecoration(
                            color: Colors.indigoAccent[100],
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: Text(widget.len[index]["Contenido"]),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                        child: CircularBorderPicture(
                          width: 52,
                          height: 52,
                          image: ProfileImage.urls[fotos[index] % 6]!
                        ),
                      ),
                    ],
                  )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),
                        child: CircularBorderPicture(
                            width: 52,
                            height: 52,
                            image: ProfileImage.urls[fotos[index] % 6]!
                        ),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
                        child: Container(
                          padding: const EdgeInsets.all(15.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          child: Text(widget.len[index]["Contenido"]),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 10,
            right: 5,
            child: SizedBox(
              height: 40,
              child: FloatingActionButton(
                onPressed: _scrollToBottom,
                elevation: 0,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7),
                tooltip: 'Mover hacia el final',
                child: const Icon(Icons.arrow_downward_rounded),
              ),
            ),
          ),
        ],
      ),
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
        Map<String, dynamic> datos = jsonDecode(message);
        if(datos["emisor"] == widget.codigo2){
          _load = false;
          _getMensajes();
          build(context);
        }
      });
    } else{
      _load = true;
      setState(() {

      });
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
    List<dynamic>? lista_mensajes_amistad = <dynamic>[];
    if(lista_mensajes[0] != null) {
      for (int i = 0; i < lista_mensajes[0].length; i++) {
        //if ((lista_mensajes[0][i])["Emisor"] == codigo1 && (lista_mensajes[0][i])["Receptor"] == codigo2
          //  || (lista_mensajes[0][i])["Emisor"] == codigo2 && (lista_mensajes[0][i])["Receptor"] == codigo1){
        lista_mensajes_amistad.add(lista_mensajes[0][i]);
        //}
      }
    }
    return lista_mensajes_amistad!;
  }



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if(widget.amistad){wb_amistad.sink.close();}
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
            Expanded(child: ShowMessages(len: lista_mensajes, MiCodigo: widget.MiCodigo, codigo2: widget.codigo2, amistad: widget.amistad),),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(15),
                        hintText: "Mensaje",
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
                  padding: const EdgeInsets.fromLTRB(0, 0,10, 10),
                  child: FloatingActionButton(
                    elevation: 0,
                    tooltip: 'Enviar mensaje',
                    onPressed: () {
                      if (_textController.text.isNotEmpty) {
                        final data = '{"emisor": "${widget.MiCodigo}","receptor": "${widget.codigo2}", "contenido": "${_textController.text}"}';
                        //msgs.add(_textController.text);
                        ///msg.add(_textController.text);
                        _textController.clear();
                        if(widget.amistad) {
                          wb_amistad.sink.add(data);
                          _getMensajes();
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
