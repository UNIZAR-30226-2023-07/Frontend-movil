import 'package:flutter/material.dart';
import '../services/http_petitions.dart';
import 'edit_profile.dart';

class ProfilePage extends StatefulWidget {
  final String email;
  Map<String, dynamic>? user;

  ProfilePage({required this.email, required this.user});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _load = false;
  @override
  void initState() {
    super.initState();
    _getUser();
  }

  Future<void> _getUser() async {
    if (widget.email == "#admin") {
      _load = true;
      setState(() {});
    }
    widget.user = await getUser(widget.email);
    _load = true;
    setState(() { });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !_load
          ? Center(child: CircularProgressIndicator())
      :SingleChildScrollView(
        child: Column(
          children: [
            EditProfilePage(nombre: widget.user!["nombre"], foto: widget.user!["foto"], desc: widget.user!["descrp"], email: widget.email, codigo: widget.user!["codigo"]),
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        'PARTIDAS JUGADAS',
                        style: TextStyle(
                            color: Colors.blueGrey[700],
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${widget.user!["pjugadas"]}',
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    color: Colors.indigoAccent,
                  ),
                  Column(
                    children: [
                      Text(
                        'WINRATE',
                        style: TextStyle(
                            color: Colors.blueGrey[700],
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      Text(
                        widget.user!["pjugadas"] == 0 ?
                        '0%':
                        '${widget.user!["pganadas"]*100~/widget.user!["pjugadas"]}%',
                        style: const TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    color: Colors.indigoAccent,
                  ),
                  Column(
                    children: [
                      Text(
                        'PUNTOS',
                        style: TextStyle(
                            color: Colors.blueGrey[700],
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      Text(
                        '${widget.user!["puntos"]}',
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 20,
              itemBuilder: (_, index) {
                return ListTile(
                  title: const Text(
                    '1º Puesto',
                    style: TextStyle(
                      color: Colors.lightBlue,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Text('Torneo de fulanito'),
                  trailing: const Text(
                    '+100',
                    style: TextStyle(
                      color: Colors.lightBlue,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: (){},
                );
              },
              separatorBuilder: (context, index) => const Divider(),
            ),
          ],
        ),
      ),
    );
  }
}