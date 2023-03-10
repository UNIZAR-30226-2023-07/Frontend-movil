import 'package:flutter/material.dart';
import '../widgets/circular_border_picture.dart';

List<String> msg = [];

class mostrarMensajes extends StatefulWidget {
  @override
  _mostrarMensajesState createState() => _mostrarMensajesState();
}

class _mostrarMensajesState extends State<mostrarMensajes> {
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

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      ///controller: _scrollController,
      itemCount: msg.length,
      addAutomaticKeepAlives: true,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                child: CircularBorderPicture(width: 52, height: 52,),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(15.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Text(msg[index]),
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
      appBar: AppBar(
        title: const Text('Chat'),
      ),
      body: Column(
        children: [
          Expanded(child: mostrarMensajes(),),
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
                  child: const Icon(Icons.send),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
