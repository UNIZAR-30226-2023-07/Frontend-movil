import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:untitled/pages/board_page.dart';
import 'package:untitled/services/audio_manager.dart';
import 'package:untitled/services/http_petitions.dart';
import 'package:untitled/services/local_notifications.dart';
import 'package:untitled/services/profile_image.dart';
import 'dialogs/close_session_dialog.dart';
import 'package:untitled/services/open_dialog.dart';
import 'pages/main_page.dart';
import 'pages/friend_list_page.dart';
import 'pages/settings_page.dart';
import 'pages/login_page.dart';
import 'pages/profile_page.dart';
import 'services/local_storage.dart';
import 'services/app_state.dart';
import 'themes/light_theme.dart';
import 'themes/dark_theme.dart';
import 'themes/theme_manager.dart';

// 0 - nombre
// 1 - foto;
// 2 - descripcion;
// 3 - pganadas;
// 4 - pjugadas;
// 5 - codigo;
// 6 - puntos;
Map<String, dynamic>? user;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<bool> _startPage() async {
  bool existsRememberMe = LocalStorage.prefs.getBool('rememberMe') != null;
  bool rememberMe;
  if (existsRememberMe) {
    rememberMe = LocalStorage.prefs.getBool('rememberMe') as bool;
    bool existsEmail = LocalStorage.prefs.getString('email') != null;
    bool existsPassword = LocalStorage.prefs.getString('password') != null;
    if (rememberMe && existsEmail && existsPassword) {
      String emailAux = LocalStorage.prefs.getString('email') as String;
      String passwordAux = LocalStorage.prefs.getString('password') as String;
      bool res = await login(emailAux, passwordAux);
      return res;
    }
  }
  return false;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorage.configurePrefs();
  AudioManager.startAudio();
  ProfileImage.prepImages();
  bool res = await _startPage();
  NotificationService().initNotification();
  NotificationService().showDailyNotificationAtTime(id: 1, title: 'Recordatorio', body: '¡Echate una partida!', hour: 12, minute: 0);


  runApp(MyApp(res: res));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.res});

  final bool res;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    themeManager.addListener(themeListener);
    WidgetsBinding.instance.addObserver(AppStateListener());
  }

  @override
  void dispose() {
    themeManager.removeListener(themeListener);
    WidgetsBinding.instance.removeObserver(AppStateListener());
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
      home: (widget.res)
        ? MyHomePage(email: LocalStorage.prefs.getString('email') as String)
        : const Login(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String email;

  const MyHomePage({super.key, required this.email});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  late List<Widget> _widgetOptions;
  bool _load = false;
  @override
  void initState() {
    super.initState();
    _getUser();
  }

  Future<void> _getUser() async {
    // saber el email con el que ha entrado el usuario, no se si pasandolo entre clases
    // o se puede de otra manera
    // Si no se puede pasar entre clases, tiramos de variable global y ya
    if(widget.email == "#admin"){
      _load = true;
      setState(() { });
    }
    user = await getUser(widget.email);
    // if (user == null){
    //     user = {
    //       "nombre": "Ismaber",
    //       "codigo": "#admin",
    //       "puntos": 200,
    //       "pganadas": 100,
    //       "pjugadas": 200,
    //       "foto": 0,
    //       "descrp": "hola"
    //     };
    // }
      print(user);
    _widgetOptions = getWidgetOptions(user!, widget.email);
    _load = true;
    setState(() { });
  }

  List<Widget> getWidgetOptions(Map<String, dynamic> user, String email) {
    return [
      MainPage(user: user, email: email),
      FriendsPage(codigo: user["codigo"]),
      ProfilePage(user: user, email: email, editActive: true,),
    ];
  }

  void onItemTapped(int index) {
    _getUser();
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      body: !_load
      ? const Center(child: CircularProgressIndicator())
      : Center(
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
        landscapeLayout: BottomNavigationBarLandscapeLayout.linear,
        onTap: onItemTapped,
        currentIndex: _selectedIndex,
      ),
    );
  }
}