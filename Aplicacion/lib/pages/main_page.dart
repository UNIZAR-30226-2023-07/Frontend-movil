import 'package:flutter/material.dart';
import '../dialogs/join_game_dialog.dart';
import '../pages/tournament_page.dart';
import '../dialogs/create_game_dialog.dart';
import '../services/http_petitions.dart';
import '../widgets/circular_border_picture.dart';
import '../services/open_dialog.dart';

class MainPage extends StatefulWidget {
  final Map<String, dynamic>? user;

  MainPage({required this.user});

  @override
  State<MainPage> createState() => _MainPageState(user!);
}

class _MainPageState extends State<MainPage> {
  late final Map<String, dynamic> user;
  _MainPageState(this.user);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          children: [
            TopSection(user),
            const Material(
              color: Colors.indigo,
              child: TabBar(
                tabs: [
                  Tab(
                    /*
                    icon: Icon(
                      Icons.wine_bar,
                      size: 30,
                    ),
                    */
                    text: 'TORNEOS',
                  ),
                  Tab(
                    /*
                    icon: Icon(
                      Icons.bar_chart_outlined,
                      size: 30,
                    ),
                    */
                    text: 'RANKING',
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  TournamentTab(codigo: user!["codigo"]),
                  RankingTab(),
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
  TopSection(this.user);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Image.network(
            "https://crehana-blog.imgix.net/media/filer_public/8c/a4/8ca49656-e762-45fc-81e0-948f1e7bc9c3/as-poker.jpeg?auto=format&q=50",
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              gradient: LinearGradient(
                begin: FractionalOffset.topCenter,
                end: FractionalOffset.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.black,
                ],
              ),
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
                child: const CircleAvatar(
                  backgroundImage: ResizeImage(
                    AssetImage('images/pepoclown.jpg'),
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
                            builder: (context) => const JoinGameDialog());
                      },
                      child: Text('Unirse a partida'),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: FilledButton(
                      onPressed: () {
                        openDialog(context, const CreateGameDialog());
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
  _TournamentTabState createState() => _TournamentTabState();
}

class _TournamentTabState extends State<TournamentTab> {
  // 0 - codigo partida;
  // 1 - creador;
  List<Map<String, dynamic>>? pendientes;

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

class RankingTab extends StatelessWidget {
  const RankingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 101,
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
                const CircularBorderPicture(),
              ],
            ),
          ),
          title: Row(
            children: const [
              Text(
                'Amigo falso',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          trailing: const Points(value: 8000),
          onTap: () {},
        );
      },
      separatorBuilder: (context, index) => const Divider(),
    );
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
