import 'package:flutter/material.dart';
import '../dialogs/join_game_dialog.dart';
import '../pages/tournament_page.dart';
import '../dialogs/create_game_dialog.dart';
import '../services/http_petitions.dart';
import '../widgets/circular_border_picture.dart';
import '../services/open_dialog.dart';
import '../services/profile_image.dart';

class MainPage extends StatefulWidget {
  final Map<String, dynamic>? user;

  const MainPage({super.key, required this.user});

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
            TopSection(user: widget.user!),
            const Material(
              color: Colors.indigo,
              child: TabBar(
                tabs: [
                  Tab(
                    text: 'TORNEOS',
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
                  TournamentTab(codigo: widget.user!["codigo"]),
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
  const TopSection({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    ProfileImage.changeImage(user["foto"]%6);
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
                            builder: (context) => JoinGameDialog(codigo: user["codigo"]));
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
                        openDialog(context, CreateGameDialog(codigo: user["codigo"]));
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

class TournamentTab extends StatefulWidget {
  final String codigo;

  const TournamentTab({Key? key, required this.codigo}) : super(key: key);

  @override
  State<TournamentTab> createState() => _TournamentTabState();
}

class _TournamentTabState extends State<TournamentTab> {
  // 0 - codigo partida;
  // 1 - creador;
  List<Map<String, dynamic>>? pendientes;

  @override
  void initState() {
    super.initState();
    _getPartidasPendientes();
  }

  Future<void> _getPartidasPendientes() async {
    pendientes = await getPartidasPendientes(widget.codigo);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 20,
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
              "partida de"), //Text('Partida de ' + (pendientes![index])[1]),
          subtitle:
              Text("codigo"), //Text('Codigo: ' + (pendientes![index])[0]),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TournamentPage(id: index)));
          },
        );
      },

      separatorBuilder: (context, index) => const Divider(),
    );
  }
}

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
    if(widget.codigo == "#admin"){
      _load = true;
      lista_amigos = [      [{'Nombre': 'Amigo falso', 'Descp': 'Hola', 'Foto': '2'}]
      ];
    }
    amigos = await getAmistades(widget.codigo);
    lista_amigos = amigos!.values.toList();
    _load = true;
    setState(() {});
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
                        .urls[(lista_amigos[0][index])["Foto"] % 6]!,),
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
              onTap: () {},
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

class Points extends StatelessWidget {
  const Points({super.key, required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 5.0),
      decoration: const BoxDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.all(Radius.circular(50))),
      child: Text('$value'),
    );
  }
}
