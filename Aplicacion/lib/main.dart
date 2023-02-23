import 'dart:io';
import 'package:flutter/material.dart';
import 'dialogs/join_game_dialog.dart';
import 'dialogs/add_friend_dialog.dart';
import 'pages/settings_page.dart';
import 'pages/login_page.dart';
import 'pages/tournament_page.dart';
import 'services/local_storage.dart';
import 'themes/light_theme.dart';
import 'themes/dark_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.configurePrefs();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: SettingsPage.themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'Rabino 7 reinas',
          debugShowCheckedModeBanner: false,
          theme: LightTheme.lightTheme,
          darkTheme: DarkTheme.darkTheme,
          themeMode: currentMode,
          home: const Login(),
        );
      }
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const MainPage(),
    const FriendsPage(),
    const ProfilePage(),
  ];

  void onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App medio mierdosa'),
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
                    builder: (context) => SettingsPage(),
                  ),
                );
              } else if (menu == 1) {

              }
            },
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar:
      /* TODO
      CurvedNavigationBar(
        index: _selectedIndex,
        height: 50,
        color: Colors.indigo,
        backgroundColor: Colors.transparent,
        buttonBackgroundColor: Colors.amber,
        items: const [
          Icon(Icons.games_rounded, color: Colors.white,),
          Icon(Icons.people_alt, color: Colors.white,),
          Icon(Icons.account_circle, color: Colors.white,),
        ],
        onTap: onItemTapped,
      ),
      */
      BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            tooltip: 'Juegos',
            icon: Icon(Icons.games_rounded),
            label: 'Juegos',
          ),
          BottomNavigationBarItem(
            tooltip: 'Amigos',
            icon: Icon(Icons.people_alt),
            label: 'Amigos',
          ),
          BottomNavigationBarItem(
            tooltip: 'Perfil',
            icon: Icon(Icons.account_circle),
            label: 'Perfil',
          ),
        ],
        iconSize: 30,
        onTap: onItemTapped,
        currentIndex: _selectedIndex,
      ),
      drawer: Drawer(
        width: 80,
        child: NavigationRail(
          leading: FloatingActionButton(
            shape: const CircleBorder(
                side: BorderSide.none,
            ),
            onPressed: (){},
            child: const Icon(Icons.add),
          ),
          selectedIndex: _selectedIndex,
          onDestinationSelected: onItemTapped,
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.games_outlined),
              selectedIcon: Icon(Icons.games_rounded),
              label: Text('Juegos'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.people_alt_outlined),
              selectedIcon: Icon(Icons.people_alt),
              label: Text('Amigos'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.account_circle_outlined),
              selectedIcon: Icon(Icons.account_circle),
              label: Text('Perfil'),
            ),
          ],
        ),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body:
        Column(
          children: [
            SizedBox(
              height: 220,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Image.network(
                    "https://crehana-blog.imgix.net/media/filer_public/8c/a4/8ca49656-e762-45fc-81e0-948f1e7bc9c3/as-poker.jpeg?auto=format&q=50",
                    fit: BoxFit.fill,
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
                        decoration: BoxDecoration(
                          color: Colors.white,
                          gradient: LinearGradient(
                            begin: FractionalOffset.topCenter,
                            end: FractionalOffset.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.0),
                              Colors.black,
                            ],
                          ),
                        ),
                      ),
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
                      const Text(
                        'Ismaber',
                        style: TextStyle(
                          color: Colors.indigoAccent,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Puntos: 9000',
                        style: TextStyle(
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
                              onPressed: (){
                                showDialog(
                                  context: context,
                                  builder: (context) => const JoinGameDialog()
                                );
                              },
                              child: Text('Unirse a partida'),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: FilledButton(
                              onPressed: (){},
                              child: Text('Crear partida'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
                  ListView.separated(
                    itemCount: 20,
                    itemBuilder: (_, index) {
                      return ListTile(
                        leading: Hero(
                          tag: index,
                          child: Icon(
                            Icons.wine_bar,
                            size: 35,
                            color: Colors.amber,
                          ),
                        ),
                        title: const Text('Torneo de fulanito'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => GamePage(id: index))
                          );
                        },
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(),
                  ),
                  ListView.separated(
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
                                  : (index == 1)?
                              const Icon(
                                Icons.wine_bar,
                                color: Colors.grey,
                                size: 35,
                              )
                                  : (index == 2)?
                              const Icon(
                                Icons.wine_bar,
                                color: Colors.deepOrangeAccent,
                                size: 35,
                              )
                              : Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  '$index',
                                  style: const TextStyle(
                                      fontSize: 25,
                                      color: Colors.indigoAccent
                                  ),
                                ),
                              ),
                              const Spacer(),
                              const FriendListTile(),
                            ],
                          ),
                        ),
                        title: Row(
                          children: const [
                            Text(
                              'Amigo falso',
                              style: TextStyle(
                                color: Colors.blueGrey,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 5.0),
                          decoration: const BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.all(Radius.circular(50))
                          ),
                          child: const Text('8000'),
                        ),
                        onTap: () {},
                      );
                    },
                    separatorBuilder: (context, index) => const Divider(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});
  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.separated(
        itemCount: 20,
        itemBuilder: (context, index) {
          return ListTile(
            leading: FriendListTile(),
            title: Row(
              children: const [
                Text(
                  'Amigo falso',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            subtitle: Text('perro'),
            trailing: Icon(
              Icons.chat,
              size: 35,
              color: Colors.indigoAccent,
            ),
            onTap: () {},
          );
        },
        separatorBuilder: (context, index) => const Divider(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        tooltip: 'Añadir amigo',
        onPressed: () {
          openDialog();
        },
        child: const Icon(Icons.add_rounded, size: 30, color: Colors.white,),
      ),
    );
  }

  Future openDialog() => showDialog(
    context: context,
    builder: (context) => AddFriendPage()
  );
}

class FriendListTile extends StatelessWidget {
  const FriendListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Stack(
        children: [
          CircleAvatar(
            backgroundImage: ResizeImage(
              AssetImage('images/pepoclown.jpg'),
              width: 120, height: 120
            ),
            radius: 30,
          ),
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.indigoAccent,
                width: 3.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Profile(),
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
                        '420',
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
                        '100%',
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
                        'PUNTOS',
                        style: TextStyle(
                          color: Colors.blueGrey[700],
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      Text(
                        '9000',
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

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          margin: const EdgeInsets.all(10),
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.indigoAccent,
              width: 3.0,
            ),
          ),
          child: IconButton(
            padding: const EdgeInsets.all(0),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePicture()),
              );
            },
            icon: const Hero(
              tag: 'foto',
              child: CircleAvatar(
                backgroundImage: ResizeImage(
                    AssetImage('images/pepoclown.jpg'),
                    width: 200,
                    height: 200,
                ),
                radius: 50,
              ),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Ismaber#1234',
              style: TextStyle(
                color: Colors.indigoAccent,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              'El puto amo',
              style: TextStyle(
                color: Colors.blueGrey,
                fontSize: 18,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ProfilePicture extends StatefulWidget {
  const ProfilePicture({super.key});

  @override
  State<ProfilePicture> createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  File? image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 300,
              width: double.infinity,
              child: image == null
                ? IconButton(
                  padding: const EdgeInsets.all(0),
                  onPressed: () {
                    openDialog();
                  },
                  iconSize: 300,
                  icon: const Hero(
                    tag: 'foto',
                    child: CircleAvatar(
                      backgroundImage: ResizeImage(
                        AssetImage('images/pepoclown.jpg'),
                        width: 300,
                        height: 300,
                      ),
                      radius: 100,
                    ),
                  ),
                )
                : IconButton(
                  padding: const EdgeInsets.all(0),
                  onPressed: () {
                    openDialog();
                  },
                  iconSize: 300,
                  icon: Hero(
                    tag: 'foto',
                    child: CircleAvatar(
                      backgroundImage: FileImage(image!),
                      radius: 100,
                    ),
                  ),
                ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nickname',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextField(
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Ismaber',
                    ),
                  ),
                  Container(
                    color: Colors.indigoAccent,
                    height: 1,
                  ),
                  const Text(
                    'Descripción',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextField(
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Sobre mí',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future openDialog() => showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Elegir foto de perfil'),
          scrollable: true,
          actionsAlignment: MainAxisAlignment.spaceAround,
          actions: [
            FilledButton(
              onPressed: () {
                _pickImageFromGallery();
              },
              child: const Text('Galería'),
            ),
            FilledButton(
              onPressed: () {
                _pickImageFromCamera();
              },
              child: const Text('Cámara'),
            ),
          ],
        ),
      );

  _pickImageFromGallery() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
    }
    if (context.mounted) Navigator.pop(context);
  }

  /// Get from Camera
  _pickImageFromCamera() async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1800,
      maxHeight: 1800,
    );
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
    }
    if (context.mounted) Navigator.pop(context);
  }
}