import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:web_socket_channel/io.dart';
import '../services/http_petitions.dart';
import '../services/open_snack_bar.dart';
import '../services/profile_image.dart';
import '../widgets/circular_border_picture.dart';

const String _IP = '52.174.124.24';
const String _PUERTO = '3001';

class ShowMessages extends StatefulWidget {
  const ShowMessages({
    super.key,
    required this.len,
    required this.MiCodigo,
    required this.amistad,
    required this.codigo2,
    this.MiFoto = -1,
    this.fotoAmigo = -1,
  });

  final List<dynamic> len;
  final String MiCodigo;
  final String codigo2;
  final bool amistad;
  final int MiFoto;
  final int fotoAmigo;

  @override
  State<ShowMessages> createState() => _ShowMessagesState();
}

class _ShowMessagesState extends State<ShowMessages> {
  late ScrollController _scrollController;
  late List<int> fotos = <int>[];
  bool _load= false;

  @override
  void initState() {
    super.initState();
    _load = false;
    if (widget.amistad) {
      procesarMensajes();
    }
    _scrollController = ScrollController();
    _load = true;

    _scrollToBottom();

    setState(() {});
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
    if (widget.amistad) {
      procesarMensajes();
    }
    _load = true;
    _scrollToBottom();
    setState(() {});
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
        //_scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void procesarMensajes() async {
    for (int i = 0; i < widget.len.length; i++) {
      Map<String, dynamic>? user = await getUserCode(widget.len[i]["Emisor"]);
      if (widget.len[i]["Receptor"] == widget.MiCodigo) {
        bool res = await leerMensajes(
            widget.len[i]["Emisor"], widget.len[i]["Receptor"]);
      }
    }
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
                  itemBuilder: (context, index) {
                    final esMio = widget.amistad
                        ? widget.len[index]["Emisor"] == widget.MiCodigo
                        : widget.len[index]["codigo"] == widget.MiCodigo;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 5),
                      child: Container(
                        child: esMio
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.60),
                                    child: Container(
                                      padding: const EdgeInsets.all(15.0),
                                      decoration: BoxDecoration(
                                        color: Colors.indigoAccent[100],
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                      ),
                                      child: widget.amistad
                                          ? Text(widget.len[index]["Contenido"])
                                          : Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  widget.len[index]["nombre"] +
                                                      ":",
                                                  style:
                                                      TextStyle(fontSize: 11.0),
                                                ),
                                                Text(widget.len[index]
                                                    ["mensaje"]),
                                              ],
                                            ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 0, horizontal: 5),
                                    child: CircularBorderPicture(
                                        width: 52,
                                        height: 52,
                                        image: widget.amistad
                                            ? ProfileImage
                                                .urls[widget.MiFoto % 9]!
                                            : ProfileImage.urls[
                                                widget.len[index]["foto"] %
                                                    9]!),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 0, horizontal: 5),
                                    child: CircularBorderPicture(
                                        width: 52,
                                        height: 52,
                                        image: widget.amistad
                                            ? ProfileImage
                                                .urls[widget.fotoAmigo % 9]!
                                            : ProfileImage.urls[
                                                widget.len[index]["foto"] %
                                                    9]!),
                                  ),
                                  ConstrainedBox(
                                    constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.6),
                                    child: Container(
                                      padding: const EdgeInsets.all(15.0),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondaryContainer,
                                        borderRadius:
                                            BorderRadius.circular(30.0),
                                      ),
                                      child: widget.amistad
                                          ? Text(widget.len[index]["Contenido"])
                                          : Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  widget.len[index]["nombre"] +
                                                      ":",
                                                  style:
                                                      TextStyle(fontSize: 11.0),
                                                ),
                                                Text(widget.len[index]
                                                    ["mensaje"]),
                                              ],
                                            ),
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
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.7),
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

String id_ant = "";

class ChatPage extends StatefulWidget {
  const ChatPage(
      {super.key,
      this.MiCodigo = "",
      this.codigo2 = "",
      this.amistad = false,
      this.idPartida = "",
      this.msg = const [],
      this.fotoAmigo = -1,
      this.MiFoto = -1,
      this.nombreAmigo = ''});

  final String MiCodigo, codigo2;
  final bool amistad;
  final String idPartida;
  final List<Map<String, dynamic>> msg;
  final int fotoAmigo;
  final int MiFoto;
  final String nombreAmigo;

  @override
  State<ChatPage> createState() => _ChatPage();
}

List<dynamic> lista_mensajes = [];

class _ChatPage extends State<ChatPage> {
  final TextEditingController _textController = TextEditingController();

  Map<String, dynamic>? mensajes;
  bool _load = false;
  late final wb_amistad;

  @override
  void initState() {
    super.initState();
    bool primero = false;
    if (widget.amistad) {
      _getMensajes();
      wb_amistad = IOWebSocketChannel.connect(
          'ws://$_IP:$_PUERTO/api/ws/chat/${widget.MiCodigo}');
    } else {
      wb_amistad = IOWebSocketChannel.connect(
          'ws://$_IP:$_PUERTO/api/ws/chat/lobby/${widget.idPartida}');
      if (id_ant != widget.idPartida) {
        primero = true;
        id_ant = widget.idPartida;
        lista_mensajes.clear();
      }
      setState(() {
        _load = true;
      });
    }
    wb_amistad.stream.handleError((error) {
      print('Error: $error');
    });

    wb_amistad.stream.listen((message) {
      print('Received: $message');
      Map<String, dynamic> datos = jsonDecode(message);
      if (widget.amistad) {
        if (datos["Emisor"] == widget.codigo2 || datos["Emisor"] == widget.MiCodigo) {
          //_load = false;
          lista_mensajes.add(datos);
          _getMensajes();
          setState(() {
            lista_mensajes;
            _load = true;
          });
          //build(context);
        }
      } else {
        if (primero) {
          lista_mensajes.add(datos);
        }
        setState(() {
          lista_mensajes;
          _load = true;
        });
        //build(context);
      }
    });

  }

  Future<void> _getMensajes() async {
    if (widget.MiCodigo == "#admin") {
      lista_mensajes = [
        [
          {'Emisor': '1', 'Receptor': '#admin', 'Contenido': 'Hola', 'Leido': 0}
        ]
      ];
    } else {
      mensajes = await getMensajes(widget.MiCodigo);
      lista_mensajes = mensajes!.values.toList();
      lista_mensajes = separarMensajesCodigo(widget.MiCodigo, widget.codigo2);
    }
    _load = true;
    setState(() {});
    // _load = true;tion in 13.336ms.
    // E/gralloc4(16107
  }

  List<dynamic> separarMensajesCodigo(String codigo1, String codigo2) {
    List<dynamic>? lista_mensajes_amistad = <dynamic>[];
    if (lista_mensajes[0] != null) {
      for (int i = 0; i < lista_mensajes[0].length; i++) {
        if ((lista_mensajes[0][i])["Emisor"] == codigo1 && (lista_mensajes[0][i])["Receptor"] == codigo2
          || (lista_mensajes[0][i])["Emisor"] == codigo2 && (lista_mensajes[0][i])["Receptor"] == codigo1){
        lista_mensajes_amistad.add(lista_mensajes[0][i]);
        }
      }
    }
    return lista_mensajes_amistad!;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (widget.amistad) {
          wb_amistad.sink.close();
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: (widget.fotoAmigo != -1)
              ? Row(
                  children: [
                    CircularBorderPicture(
                        width: 45,
                        height: 45,
                        image: ProfileImage.getImage(widget.fotoAmigo % 9)),
                    Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(widget.nombreAmigo))
                  ],
                )
              : const Text('Chat'),
        ),
        body: !_load
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: ShowMessages(
                        len: lista_mensajes,
                        MiCodigo: widget.MiCodigo,
                        codigo2: widget.codigo2,
                        amistad: widget.amistad,
                        MiFoto: widget.MiFoto,
                        fotoAmigo: widget.fotoAmigo,),
                  ),
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
                        padding: const EdgeInsets.fromLTRB(0, 0, 10, 10),
                        child: FloatingActionButton(
                          elevation: 0,
                          tooltip: 'Enviar mensaje',
                          onPressed: () async {
                            if (_textController.text.isNotEmpty) {
                              //msgs.add(_textController.text);
                              ///msg.add(_textController.text);

                              if (widget.amistad) {
                                final data =
                                    '{"Emisor": "${widget.MiCodigo}","Receptor": "${widget.codigo2}", "Contenido": "${_textController.text}"}';
                                wb_amistad.sink.add(data);
                                lista_mensajes.add(jsonDecode(data));
                                _getMensajes();
                                _textController.clear();
                                setState(() {
                                  lista_mensajes;
                                  _load = true;
                                });
                              } else {
                                Map<String, dynamic>? user =
                                    await getUserCode(widget.MiCodigo);
                                final data =
                                    '{"codigo": "${widget.MiCodigo}","nombre": "${user!["nombre"]}", "foto": ${user!["foto"]}, "mensaje": "${_textController.text}"}';
                                print("enviado");
                                wb_amistad.sink.add(data);
                                _textController.clear();
                              }
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
