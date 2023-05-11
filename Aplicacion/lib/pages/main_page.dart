import 'package:flutter/material.dart';
import 'package:untitled/pages/lobby_page.dart';
import 'package:untitled/pages/profile_page.dart';
import '../dialogs/join_game_dialog.dart';
import '../pages/tournament_page.dart';
import '../dialogs/create_game_dialog.dart';
import '../services/http_petitions.dart';
import '../services/open_snack_bar.dart';
import '../widgets/circular_border_picture.dart';
import '../services/open_dialog.dart';
import '../services/profile_image.dart';
import '../widgets/points.dart';


class MainPage extends StatefulWidget {
  final Map<String, dynamic>? user;
  final String email;

  const MainPage({super.key, required this.user, required this.email});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            TopSection(user: widget.user!, email: widget.email),
            const Material(
              color: Colors.indigo,
              child: TabBar(
                tabs: [
                  Tab(
                    text: 'PENDIENTES',
                  ),
                  Tab(
                    text: 'RANKING',
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  TournamentTab(codigo: widget.user!["codigo"], email: widget.email),
                  RankingTab(codigo: widget.user!["codigo"]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TopSection extends StatelessWidget {
  final Map<String, dynamic> user;
  final String email;
  const TopSection({super.key, required this.user, required this.email});

  @override
  Widget build(BuildContext context) {
    ProfileImage.changeImage(user["foto"]%9);
    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            color: Theme.of(context).colorScheme.secondaryContainer,
          ),
          Center(
            child: Image.asset(
              'images/logo.png',
              height: 200,
            ),
          ),
          Column(
            children: [
              Container(
                margin: const EdgeInsets.all(10),
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.indigoAccent,
                    width: 3.0,
                  ),
                ),
                child: CircleAvatar(
                  backgroundImage: ResizeImage(
                    AssetImage(ProfileImage.image),
                    width: 140,
                    height: 140,
                  ),
                  radius: 35,
                ),
              ),
              Text(
                user["nombre"],
                style: const TextStyle(
                  color: Colors.indigoAccent,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Puntos: ${user["puntos"]}',
                style: const TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: FilledButton(
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) => JoinGameDialog(codigo: user["codigo"], email: email));
                      },
                      child: const Text('Unirse a partida'),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: FilledButton(
                      onPressed: () {
                        openDialog(context, CreateGameDialog(codigo: user["codigo"], email: email));
                      },
                      child: const Text('Crear partida'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/*
class TournamentTab extends StatefulWidget {
  final String codigo;
  final String email;

  const TournamentTab({Key? key, required this.codigo, required this.email}) : super(key: key);

  @override
  State<TournamentTab> createState() => _TournamentTabState();
}

class _TournamentTabState extends State<TournamentTab> {
  // 0 - codigo partida;
  // 1 - creador;
  Map<String, dynamic>? pendientes;
  bool _load = false;
  late List<dynamic> lista_pendientes;

  @override
  void initState() {
    super.initState();
    _getPartidasPendientes();
  }

  Future<void> _getPartidasPendientes() async {
    pendientes = await getPartidasPendientes(widget.codigo);
    lista_pendientes = pendientes!.values.toList();
    _load = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return !_load
        ? const Center(child: CircularProgressIndicator())
        :  lista_pendientes[0] == null
        ? const SizedBox()
        : ListView.separated(
      itemCount: lista_pendientes[0].length,
      itemBuilder: (_, index) {
        return ListTile(
          leading: Hero(
            tag: index,
            child: const Icon(
              Icons.wine_bar,
              size: 35,
              color: Colors.amber,
            ),
          ),
          title: Text(
              "Partida de ${(lista_pendientes[0][index])["Creador"]}"), //Text('Partida de ' + (pendientes![index])[1]),
          subtitle:
              Text("Código: ${(lista_pendientes[0][index])["Clave"]}"), //Text('Codigo: ' + (pendientes![index])[0]),
          onTap: () async {
            bool torneo = true;
            if((lista_pendientes[0][index])["Tipo"] == "amistosa"){
              torneo = false;
            }
            Map<String, dynamic>? res = await unirPartida(widget.codigo, (lista_pendientes[0][index])["Clave"]);
            if (context.mounted) {
              if (res == null) {
                openSnackBar(context, const Text('No se ha podido enviar la petición'));
                Navigator.pop(context);
              } else {
                openSnackBar(context, const Text('Uniendose'));
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>
                      LobbyPage(ranked: torneo,
                          idPartida: (lista_pendientes[0][index])["Clave"],
                          MiCodigo: widget.codigo,
                          creador: (lista_pendientes[0][index])["Creador"] == widget.codigo,
                          email: widget.email,
                          jug: res["jugadores"] ?? [],
                          nueva: false)),
                );
              }
            }
          },
        );
      },
      separatorBuilder: (context, index) => const Divider(),
    );
  }
}
*/

class TournamentTab extends StatefulWidget {
  final String codigo;
  final String email;

  const TournamentTab({super.key, required this.codigo, required this.email});

  @override
  State<TournamentTab> createState() => _TournamentTabState();
}

class _TournamentTabState extends State<TournamentTab> {

  Future<dynamic> _getPartidasPendientes() async {
    var pendientes = await getPartidasPendientes(widget.codigo);
    return pendientes;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: getPartidasPendientes(widget.codigo),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Ha ocurrido un error'));
        } else {
          List<dynamic>? listaPendientes = snapshot.data?.values.toList();
          if (listaPendientes == null || listaPendientes[0] == null || listaPendientes.isEmpty) {
            return const Center(child: Text('No tienes partidas pausadas'));
          } else {
            return ListView.separated(
              itemCount: listaPendientes[0].length,
              itemBuilder: (_, index) {
                return ListTile(
                  leading: Hero(
                    tag: index,
                    child: const Icon(
                      Icons.wine_bar,
                      size: 35,
                      color: Colors.amber,
                    ),
                  ),
                  title: Text(
                      "Partida de ${(listaPendientes[0][index])["Creador"]}"),
                  subtitle: Text(
                      "Código: ${(listaPendientes[0][index])["Clave"]}"),
                  onTap: () async {
                    bool torneo = true;
                    if((listaPendientes[0][index])["Tipo"] == "amistosa"){
                      torneo = false;
                    }
                    Map<String, dynamic>? res = await unirPartida(widget.codigo, (listaPendientes[0][index])["Clave"]);
                    if (context.mounted) {
                      if (res == null) {
                        openSnackBar(context, const Text('No se ha podido enviar la petición'));
                        Navigator.pop(context);
                      } else {
                        openSnackBar(context, const Text('Uniendose'));
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>
                              LobbyPage(ranked: torneo,
                                  idPartida: (listaPendientes[0][index])["Clave"],
                                  MiCodigo: widget.codigo,
                                  creador: (listaPendientes[0][index])["Creador"] == widget.codigo,
                                  email: widget.email,
                                  jug: res["jugadores"] ?? [],
                                  nueva: false)),
                        );
                      }
                    }
                  },
                );
              },
              separatorBuilder: (context, index) => const Divider(),
            );
          }
        }
      },
    );
  }
}

/*
class RankingTab extends StatefulWidget {
  final String codigo;

  const RankingTab({Key? key, required this.codigo}) : super(key: key);

  @override
  State<RankingTab> createState() => _RankingTabState();
}

class _RankingTabState extends State<RankingTab> {

  Map<String, dynamic>? amigos;
  bool _load = false;
  late List<dynamic> lista_amigos;

  @override
  void initState() {
    super.initState();
    _getAmistades();
  }

  Future<void> _getAmistades() async {
    /*
    if(widget.codigo == "#admin"){
      //_load = true;
      setState(() {
        _load = true;
      });
      lista_amigos = [      [{'Nombre': 'Amigo falso', 'Descp': 'Hola', 'Foto': '2'}]
      ];
    }
    */
    amigos = await getAmistades(widget.codigo);
    lista_amigos = amigos!.values.toList();
    //_load = true;
    setState(() {
      _load = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(_load){
      if (lista_amigos[0] != null) {
        return ListView.separated(
          itemCount: lista_amigos[0].length,
          itemBuilder: (context, index) {
            return ListTile(
              contentPadding: const EdgeInsets.all(10),
              leading: SizedBox(
                width: 120,
                child: Row(
                  children: [
                    (index == 0)
                    ? const Icon(
                      Icons.wine_bar,
                      color: Colors.amber,
                      size: 35,
                    )
                    : (index == 1)
                    ? const Icon(
                      Icons.wine_bar,
                      color: Colors.grey,
                      size: 35,
                    )
                    : (index == 2)
                    ? const Icon(
                      Icons.wine_bar,
                      color: Colors.deepOrangeAccent,
                      size: 35,
                    )
                    : Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        '$index',
                        style: const TextStyle(
                            fontSize: 25, color: Colors.indigoAccent),
                      ),
                    ),
                    const Spacer(),
                    CircularBorderPicture(image: ProfileImage
                        .urls[(lista_amigos[0][index])["Foto"] % 9]!,),
                  ],
                ),
              ),
              title: Row(
                children: [
                  Text(
                    (lista_amigos[0][index])["Nombre"],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              trailing: Points(value: ((lista_amigos[0][index])["Puntos"])),
              onTap: () async {
                Map<String, dynamic>? user = await getUserCode((lista_amigos[0][index])["Codigo"]);
                setState(() { });
                if (context.mounted) {
                  Navigator.push(context,
                    MaterialPageRoute(builder: (
                        context) => ProfilePage(email: '', user: user, editActive: false,)),
                  );
                  print(user);
                }
              },
            );
          },
          separatorBuilder: (context, index) => const Divider(),
        );
      }
      else{
        return Container();
      }
    }
    else{
      return const Center(child: CircularProgressIndicator());
    }
  }
}
*/

class RankingTab extends StatefulWidget {
  final String codigo;

  const RankingTab({super.key, required this.codigo});

  @override
  State<RankingTab> createState() => _RankingTabState();
}

class _RankingTabState extends State<RankingTab> {
  late List<dynamic> lista_amigos;

  Future<List<dynamic>> _getAmistades() async {
    Map<String, dynamic>? amigos = await getAmistades(widget.codigo);
    return amigos!.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _getAmistades(),
      builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          lista_amigos = snapshot.data!;
          if (lista_amigos[0] == null) {
            return const Center(child: Text('Parece que no tienes amigos :('));
          } else {
            return ListView.separated(
              itemCount: lista_amigos[0].length,
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: SizedBox(
                    width: 120,
                    child: Row(
                      children: [
                        (index == 0)
                            ? const Icon(
                          Icons.wine_bar,
                          color: Colors.amber,
                          size: 35,
                        )
                            : (index == 1)
                            ? const Icon(
                          Icons.wine_bar,
                          color: Colors.grey,
                          size: 35,
                        )
                            : (index == 2)
                            ? const Icon(
                          Icons.wine_bar,
                          color: Colors.deepOrangeAccent,
                          size: 35,
                        )
                            : Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            '$index',
                            style: const TextStyle(
                                fontSize: 25, color: Colors.indigoAccent),
                          ),
                        ),
                        const Spacer(),
                        CircularBorderPicture(image: ProfileImage
                            .urls[(lista_amigos[0][index])["Foto"] % 9]!,),
                      ],
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        (lista_amigos[0][index])["Nombre"],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing: Points(value: ((lista_amigos[0][index])["Puntos"])),
                  onTap: () async {
                    Map<String, dynamic>? user = await getUserCode((lista_amigos[0][index])["Codigo"]);
                    setState(() { });
                    if (context.mounted) {
                      Navigator.push(context,
                        MaterialPageRoute(builder: (
                            context) => ProfilePage(email: '', user: user, editActive: false,)),
                      );
                      print(user);
                    }
                  },
                );
              },
              separatorBuilder: (context, index) => const Divider(),
            );
          }
        }
      },
    );
  }
}
