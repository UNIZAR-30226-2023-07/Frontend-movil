import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:untitled/services/open_snack_bar.dart';
import '../services/encrypt_password.dart';

const String _loginURL = 'http://51.103.94.220:3001/api/auth/login';
const String _registerURL = 'http://51.103.94.220:3001/api/auth/register';
const String _getUserURL = 'http://51.103.94.220:3001/api/jugador/get/';
const String _getPartidasPendientesURL = 'http://51.103.94.220:3001/api/partidas/pendientes/get/';
const String _getAmistadesURL = 'http://51.103.94.220:3001/api/amistad/get/';
const String _nuevoAmigoURL = 'http://51.103.94.220:3001/api/amistad/add';
const String _editProfileURL = 'http://51.103.94.220:3001/api/jugador/mod';
const String _changePasswordURL = 'http://51.103.94.220:3001/api/auth/mod-login';

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
  final json = '{"nombre": $nickname, "email": $email, "contra": $encryptedPassword}';

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

Future<List<Map<String, dynamic>>?> getPartidasPendientes(String codigo) async {
  String uri = "$_getPartidasPendientesURL$codigo";

  final response = await http.get(Uri.parse(uri));

  //print(response.statusCode);

  List<Map<String, dynamic>>? datos = null;
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

Future<bool> nuevoAmigo(String codigo1, String codigo2) async {
  final json = '{"emisor": $codigo1, "receptor": $codigo2}';

  final response = await http.post(Uri.parse(_nuevoAmigoURL), body: json);

  //print(response.statusCode);

  return response.statusCode == 200 || response.statusCode == 202;
}

Future<bool> editProfile(String email, String nombre, String desc, String foto) async {
  final json = '{"email": $email, "nombre": $nombre, "foto": $foto, "descripcion": $desc}';

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