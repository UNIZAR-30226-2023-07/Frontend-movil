import 'package:flutter/material.dart';

List<String> msg = [

];

class mostrarMensajes extends StatefulWidget {
  @override
  _mostrarMensajesState createState() => _mostrarMensajesState();
}

class _mostrarMensajesState extends State<mostrarMensajes> {
  final ScrollController _scrollController = ScrollController();

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

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: ListView.builder(
        controller: _scrollController,
        itemCount: msg.length,
        addAutomaticKeepAlives: true,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Text(msg[index]),
          );
        },
      ),
    );
  }
}


class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);
  @override
  State<ChatPage> createState() => _ChatPage();
}

class _ChatPage extends State<ChatPage> {
  final TextEditingController _textController = TextEditingController();

  @override
  Duration get transitionDuration => Duration(milliseconds: 200);

  @override
  bool get barrierDismissible => true;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.5);

  @override
  String get barrierLabel => 'Cerrar';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: ListView.builder(
          itemCount: 1,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              height: 720,
              child: Column(
                children: [
                  mostrarMensajes(),
                  Row(
                    children: [
                      Flexible(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: TextField(
                            controller: _textController,
                            decoration: InputDecoration(
                                hintText: "Introduce tu mensaje aquí",
                                border: OutlineInputBorder()),
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (_textController.text.isNotEmpty) {
                            setState(() {
                              msg.add(_textController.text);
                              _textController.clear();
                            });
                          }
                          FocusScope.of(context).unfocus();
                          Navigator.pop(context);
                          Navigator.push(context,
                            MaterialPageRoute(
                                builder: (context) => const ChatPage()),);
                        },
                        icon: Icon(Icons.send),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
      appBar: AppBar(
        title: const Text('Chat'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}
