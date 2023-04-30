import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/encrypt_password.dart';

const String _IP = '52.166.36.105';
const String _PUERTO = '3001';

const String _loginURL = 'http://$_IP:$_PUERTO/api/auth/login';
const String _registerURL = 'http://$_IP:$_PUERTO/api/auth/register';
const String _getUserURL = 'http://$_IP:$_PUERTO/api/jugador/get/';
const String _getUserCodeURL = 'http://$_IP:$_PUERTO/api/jugador/get2/';
const String _getPartidasPendientesURL = 'http://$_IP:$_PUERTO/api/partidas/pausadas/get/';
const String _getAmistadesURL = 'http://$_IP:$_PUERTO/api/amistad/get/';
const String _getSolicitudesURL = 'http://$_IP:$_PUERTO/api/amistad/get/pendientes/';
const String _nuevoAmigoURL = 'http://$_IP:$_PUERTO/api/amistad/add';
const String _editProfileURL = 'http://$_IP:$_PUERTO/api/jugador/mod';
const String _changePasswordURL = 'http://$_IP:$_PUERTO/api/auth/mod-login';
const String _aceptarAmigoURL = 'http://$_IP:$_PUERTO/api/amistad/accept';
const String _denegarAmigoURL = 'http://$_IP:$_PUERTO/api/amistad/remove';
const String _getMensajesURL = 'http://$_IP:$_PUERTO/api/msg/get/';
const String _leerMensajesURL = 'http://$_IP:$_PUERTO/api/msg/leer';
const String _crearPartidaURL = 'http://$_IP:$_PUERTO/api/partida/crear';
const String _unirPartidaURL = 'http://$_IP:$_PUERTO/api/partida/join';
const String _iniciarPartidaURL = 'http://$_IP:$_PUERTO/api/partida/iniciar';

class User {
  final String nickname;
  final String email;
  final String password;

  User({required this.nickname, required this.email, required this.password});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      nickname: json['nickname'],
      email: json['email'],
      password: json['password'],
    );
  }
}

class Prueba extends StatelessWidget {
  const Prueba({super.key, required this.post});

  final Future<User> post;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fetch Data Example'),
      ),
      body: Center(
        child: FutureBuilder<User>(
          future: post,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data!.nickname);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }

            // Por defecto, muestra un loading spinner
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}



Future<bool> login(String email, String password) async {
  String encryptedPassword = encryptPassword(password);
  final json = '{"email": "$email", "contra": "$encryptedPassword"}';

  final response = await http.post(Uri.parse(_loginURL), body: json);

  print(response.statusCode);
  print(response.body);

  return response.statusCode == 200 || response.statusCode == 202;
}

Future<bool> register(String nickname, String email, String password) async {
  String encryptedPassword = encryptPassword(password);
  final json = '{"nombre": "$nickname", "email": "$email", "contra": "$encryptedPassword"}';

  final response = await http.post(Uri.parse(_registerURL), body: json);

  //print(response.statusCode);

  return response.statusCode == 200 || response.statusCode == 202;
}

Future<Map<String, dynamic>?> getUser(String email) async {
  String uri = "$_getUserURL$email";

  final response = await http.get(Uri.parse(uri));

  //print(response.statusCode);

  Map<String, dynamic>? datos = null;
  if (response.statusCode == 200 || response.statusCode == 202) {
    datos = jsonDecode(response.body);
  } else {
    print('Error al hacer la solicitud: ${response.statusCode}');
  }
  if(email == "admin") {
    datos = {
      "nombre": "Ismaber",
      "codigo": "#admin",
      "puntos": 200,
      "pganadas": 100,
      "pjugadas": 200,
      "foto": 0,
      "descrp": "hola"
    };
  }
  //datos!['0'] = 'ismaber';
  return datos;
}

Future<Map<String, dynamic>?> getUserCode(String codigo) async {
  String uri = "$_getUserCodeURL$codigo";

  final response = await http.get(Uri.parse(uri));

  //print(response.statusCode);

  Map<String, dynamic>? datos;
  if (response.statusCode == 200 || response.statusCode == 202) {
    datos = jsonDecode(response.body);
  } else {
    print('Error al hacer la solicitud: ${response.statusCode}');
  }
  //datos!['0'] = 'ismaber';
  return datos;
}

Future<Map<String, dynamic>?> getPartidasPendientes(String codigo) async {
  String uri = "$_getPartidasPendientesURL$codigo";

  final response = await http.get(Uri.parse(uri));

  //print(response.statusCode);

  Map<String, dynamic>? datos = null;
  if (response.statusCode == 200 || response.statusCode == 202) {
    datos = jsonDecode(response.body);
  } else {
    print('Error al hacer la solicitud: ${response.statusCode}');
  }
  return datos;
}

Future <Map<String, dynamic>?> getAmistades(String codigo) async {
  String uri = "$_getAmistadesURL$codigo";

  final response = await http.get(Uri.parse(uri));

  //print(response.statusCode);

  Map<String, dynamic>? datos = null;
  if (response.statusCode == 200 || response.statusCode == 202) {
    datos = jsonDecode(response.body);
  } else {
    print('Error al hacer la solicitud: ${response.statusCode}');
  }
  return datos;
}

Future <Map<String, dynamic>?> getSolicitudes(String codigo) async {
  String uri = "$_getSolicitudesURL$codigo";

  final response = await http.get(Uri.parse(uri));

  //print(response.statusCode);

  Map<String, dynamic>? datos = null;
  if (response.statusCode == 200 || response.statusCode == 202) {
    datos = jsonDecode(response.body);
  } else {
    print('Error al hacer la solicitud: ${response.statusCode}');
  }
  return datos;
}

Future<bool> nuevoAmigo(String codigo1, String codigo2) async {
  final json = '{"emisor": "$codigo1", "receptor": "$codigo2"}';

  final response = await http.post(Uri.parse(_nuevoAmigoURL), body: json);

  //print(response.statusCode);

  return response.statusCode == 200 || response.statusCode == 202;
}

Future<bool> editProfile(String email, String nombre, String desc, int foto) async {
  final json = '{"email": "$email", "nombre": "$nombre", "foto": $foto, "descp": "$desc"}';

  final response = await http.post(Uri.parse(_editProfileURL), body: json);

  //print(response.statusCode);

  return response.statusCode == 200 || response.statusCode == 202;
}

Future<bool> changePassword(String email, String password) async {
  String encryptedPassword = encryptPassword(password);
  final json = '{"email": "$email", "contra": "$encryptedPassword"}';

  final response = await http.post(Uri.parse(_changePasswordURL), body: json);

  //print(response.statusCode);
  //print(response.body);

  return response.statusCode == 200 || response.statusCode == 202 ;
}

Future<bool> aceptarAmigo(String codigoEm, String codigoRec) async {
  final json = '{"emisor": "$codigoEm", "receptor": "$codigoRec"}';

  final response = await http.post(Uri.parse(_aceptarAmigoURL), body: json);

  //print(response.statusCode);
  //print(response.body);

  return response.statusCode == 200 || response.statusCode == 202 ;
}

Future<bool> denegarAmigo(String codigoEm, String codigoRec) async {
  final json = '{"emisor": "$codigoRec", "receptor": "$codigoEm"}';

  final response = await http.post(Uri.parse(_denegarAmigoURL), body: json);

  //print(response.statusCode);
  //print(response.body);

  return response.statusCode == 200 || response.statusCode == 202 ;
}

Future <Map<String, dynamic>?> getMensajes(String codigo) async {
  String uri = "$_getMensajesURL$codigo";

  final response = await http.get(Uri.parse(uri));

  //print(response.statusCode);

  Map<String, dynamic>? datos = null;
  if (response.statusCode == 200 || response.statusCode == 202) {
    datos = jsonDecode(response.body);
  } else {
    print('Error al hacer la solicitud: ${response.statusCode}');
  }
  return datos;
}

Future<bool> leerMensajes(String codigo1, String codigo2) async {
  final json = '{"emisor": "$codigo1", "receptor": "$codigo2"}';

  final response = await http.post(Uri.parse(_leerMensajesURL), body: json);

  //print(response.statusCode);

  return response.statusCode == 200 || response.statusCode == 202;
}

Future <Map<String, dynamic>?> crearPartida(String codigo, String tipo) async {
  final json = '{"tipo": "$tipo", "anfitrion": "$codigo"}';

  final response = await http.post(Uri.parse(_crearPartidaURL), body: json);

  //print(response.statusCode);

  Map<String, dynamic>? datos = null;
  if (response.statusCode == 200 || response.statusCode == 202) {
    datos = jsonDecode(response.body);
  } else {
    print('Error al hacer la solicitud: ${response.statusCode}');
  }
  return datos;
}

Future<Map<String, dynamic>?> unirPartida(String codigo, String partida) async {
  final json = '{"codigo": "$codigo", "clave": "$partida"}';

  final response = await http.post(Uri.parse(_unirPartidaURL), body: json);

  //print(response.statusCode);

  Map<String, dynamic>? datos = null;
  if (response.statusCode == 200 || response.statusCode == 202) {
    datos = jsonDecode(response.body);
  } else {
    print('Error al hacer la solicitud: ${response.statusCode}');
  }
  return datos;
}

Future<bool> iniciarPartida(String jugador, String codigo) async {
  final json = '{"codigo": "$jugador", "clave": "$codigo"}';

  final response = await http.post(Uri.parse(_iniciarPartidaURL), body: json);

  print(response.statusCode);
  print(response.body);

  return response.statusCode == 200 || response.statusCode == 202;
}

Future<bool> pausarPartida(String codigo, String partida) async {
  final json = '{"codigo": "$codigo", "clave": "$partida"}';

  final response = await http.post(Uri.parse(_unirPartidaURL), body: json);

  //print(response.statusCode);

  return response.statusCode == 200 || response.statusCode == 202;
}