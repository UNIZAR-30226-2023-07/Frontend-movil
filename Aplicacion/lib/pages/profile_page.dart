import 'package:flutter/material.dart';
import 'package:untitled/pages/settings_page.dart';
import 'package:untitled/widgets/points.dart';
import '../dialogs/close_session_dialog.dart';
import '../services/http_petitions.dart';
import '../services/open_dialog.dart';
import 'edit_profile.dart';

class ProfilePage extends StatefulWidget {
  final String email;
  Map<String, dynamic>? user;
  final bool editActive;

  ProfilePage({super.key, required this.email, required this.user, required this.editActive});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _load = false;
  Map<String, dynamic>? historial;


  @override
  void initState() {
    super.initState();
    _getUser();
    _getHistorial();
  }

  Future<void> _getHistorial() async {
    historial = await getHistorial(widget.user!["codigo"]);
    //_load = true;
    setState(() {
      _load = true;
    });
  }

  Future<void> _getUser() async {
    if (widget.email == "#admin") {
      _load = true;
      //setState(() {});
    }
    widget.user = await getUserCode(widget.user!["codigo"]);
    _load = true;
    if(mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> partidas;
    if (historial == null || historial!['partidas'] == null) {
      partidas = [];
    } else {
      partidas = historial!['partidas'];
    }
    return Scaffold(
      appBar: !widget.editActive
      ? AppBar(
        title: const Text('Rabino 7 Reinas'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return const [
                PopupMenuItem(
                  value: 0,
                  child: Text("Ajustes"),
                ),
                PopupMenuItem(
                  value: 1,
                  child: Text("Cerrar sesión"),
                ),
              ];
            },
            onSelected: (menu) {
              if (menu == 0) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsPage(code: widget.user!["codigo"],),
                  ),
                );
              } else if (menu == 1) {
                openDialog(context, const CloseSessionDialog());
              }
            },
          ),
        ],
      )
      : null,
      body: !_load
      ? const Center(child: CircularProgressIndicator())
      : SingleChildScrollView(
        child: Column(
          children: [
            EditProfilePage(nombre: widget.user!["nombre"], foto: widget.user!["foto"], desc: widget.user!["descrp"], email: widget.email, codigo: widget.user!["codigo"], editActive: widget.editActive),
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Stat(title: 'PARTIDAS', value: '${widget.user!["pjugadas"]}'),
                  Container(
                    width: 1,
                    height: 50,
                    color: Colors.indigoAccent,
                  ),
                  Stat(
                    title: 'WINRATE',
                    value: widget.user!["pjugadas"] == 0
                    ? '0%'
                    : '${widget.user!["pganadas"]*100~/widget.user!["pjugadas"]}%'
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    color: Colors.indigoAccent,
                  ),
                  Stat(title: 'PUNTOS', value: '${widget.user!["puntos"]}'),
                ],
              ),
            ),
            historial!['partidas'] != null
            ? ListView.separated(
              reverse: true,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: partidas.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: partidas[index]['Ganador'] == true
                  ? const Text(
                    'VICTORIA',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 18
                    ),
                  )
                  : const Text(''
                    'DERROTA',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 18
                    ),
                  ),
                  subtitle: partidas[index]['Tipo'] == 'amistosa'
                  ? Text('Partida de ${partidas[index]['Creador']} con código: ${partidas[index]['Clave']}')
                  : Text('Torneo de ${partidas[index]['Creador']} con código: ${partidas[index]['Clave']}'),
                  trailing: partidas[index]['Tipo'] == 'amistosa'
                  ? const SizedBox()
                  : Points(value: partidas[index]['Puntos'],),
                );
              },
              separatorBuilder: (context, index) => const Divider(),
            )
            : const SizedBox()
          ],
        ),
      ),
    );
  }
}

class Stat extends StatelessWidget {
  final String title;
  final String value;

  const Stat({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.blueGrey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.blueGrey,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      )
    );
  }
}
