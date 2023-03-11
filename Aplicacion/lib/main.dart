import 'package:flutter/material.dart';
import 'dialogs/close_session_dialog.dart';
import 'package:untitled/services/open_dialog.dart';
import 'pages/main_page.dart';
import 'pages/friend_list_page.dart';
import 'pages/settings_page.dart';
import 'pages/login_page.dart';
import 'pages/profile_page.dart';
import 'services/local_storage.dart';
import 'themes/light_theme.dart';
import 'themes/dark_theme.dart';
import 'themes/theme_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.configurePrefs();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    themeManager.addListener(themeListener);
    super.initState();
  }

  @override
  void dispose() {
    themeManager.removeListener(themeListener);
    super.dispose();
  }

  themeListener() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rabino 7 reinas',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeManager.themeMode,
      home: const Login(),
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
                    builder: (context) => const SettingsPage(),
                  ),
                );
              } else if (menu == 1) {
                openDialog(context, const CloseSessionDialog());
              }
            },
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            tooltip: 'Jugar',
            icon: Icon(Icons.games_rounded),
            label: 'Jugar',
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
      /*
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
      */
    );
  }
}