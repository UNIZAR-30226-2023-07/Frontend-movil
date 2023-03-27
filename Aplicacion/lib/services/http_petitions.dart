import 'dart:js_util';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../main.dart';

const String _loginURL = 'http://51.103.94.220:3001/api/auth/login';
const String _registerURL = 'http://51.103.94.220:3001/api/auth/register';
const String _getUserURL = 'http://51.103.94.220:3001/api/jugador/get/:email';

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

bool _actions(http.Response response, BuildContext context,String email) {
  if (response.statusCode == 200 || response.statusCode == 202) {
    // Si el servidor devuelve una repuesta OK, parseamos el JSON
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bienvenido'),
        showCloseIcon: true,
      ),
    );
    Navigator.pushReplacement(
      context,
      // pasar el email con el que se ha registrado el usuario para luego poder hacer consultas
      MaterialPageRoute(builder: (context) => MyHomePage(email: email)),
    );
    return true;
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ha habido un error'),
        showCloseIcon: true,
      ),
    );
    return false;
  }
}

Future<bool> login(final String email, String password, BuildContext context) async {
  if (email == 'admin') {
    Navigator.pushReplacement(
      context,
      //pasar el email para saber con cual esta registrado
      MaterialPageRoute(builder: (context) => MyHomePage(email: email)),
    );
    return true;
  }
  final json = '{"email": "$email", "contra": "$password"}';

  final response = await http.post(Uri.parse(_loginURL), body: json);

  //print(response.statusCode);

  if (context.mounted) {
    return _actions(response, context, email);
  } else {
    return false;
  }
}

Future<bool> register(String nickname, String email, String password, BuildContext context) async {
  final json = '{"nombre": $nickname, "email": $email, "contra": $password}';

  final response = await http.post(Uri.parse(_registerURL), body: json);

  //print(response.statusCode);

  if (context.mounted) {
    return _actions(response, context, email);
  } else {
    return false;
  }
}

class Pendientes{
  final int codigo;
  final String creador;
    Pendientes({required this.codigo, required this.creador});
  factory Pendientes.fromJson(Map<String, dynamic> json) {
    return Pendientes(
      codigo: json['codigo'],
      creador: json['creador']
    );
  }
}

class UserApp {
  final String nickname;
  final int foto;
  final String descripcion;
  final int pganadas;
  final int pjugadas;
  final String codigo;
  final int puntos;

  UserApp({required this.nickname, required this.foto, required this.descripcion,
  required this.pganadas, required this.pjugadas, required this.codigo, required this.puntos});

  factory UserApp.fromJson(Map<String, dynamic> json) {
    return UserApp(
      nickname: json['nickname'],
      foto: json['foto'],
      descripcion: json['descripcion'],
      pganadas: json['pganadas'],
      pjugadas: json['pjugadas'],
      codigo: json['codigo'],
      puntos: json['puntos']
    );
  }
}


Future<Map<String, dynamic>?> getUser(String email, BuildContext context) async {
  String uri = "$_getUserURL?email=$email";

  final response = await http.get(Uri.parse(uri));

  //print(response.statusCode);

  Map<String, dynamic>? datos = null;
  if (response.statusCode == 200) {
    datos = jsonDecode(response.body);
  } else {
    print('Error al hacer la solicitud: ${response.statusCode}');
  }
  return datos;
}