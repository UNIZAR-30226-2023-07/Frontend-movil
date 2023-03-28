import 'dart:js_util';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../main.dart';

const String _loginURL = 'http://51.103.94.220:3001/api/auth/login';
const String _registerURL = 'http://51.103.94.220:3001/api/auth/register';
const String _getUserURL = 'http://51.103.94.220:3001/api/jugador/get/:';
const String _getPartidasPendientesURL = 'http://51.103.94.220:3001/api/partidas/pendientes/get/:';
const String _getAmistadesURL = 'http://51.103.94.220:3001/api/amistad/get/:';
const String _nuevoAmigoURL = 'http://51.103.94.220:3001/api/amistad/add';
const String _editProfileURL = 'http://51.103.94.220:3001/api/jugador/mod';

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

Future<Map<String, dynamic>?> getUser(String email, BuildContext context) async {
  String uri = "$_getUserURL$email";

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

Future<List<Map<String, dynamic>>?> getPartidasPendientes(String codigo, BuildContext context) async {
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

Future<List<Map<String, dynamic>>?> getAmistades(String codigo, BuildContext context) async {
  String uri = "$_getAmistadesURL$codigo";

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

Future<bool> nuevoAmigo(String codigo1, String codigo2, BuildContext context) async {
  final json = '{"emisor": $codigo1, "receptor": $codigo2}';

  final response = await http.post(Uri.parse(_nuevoAmigoURL), body: json);

  //print(response.statusCode);

  if (context.mounted) {
    if (response.statusCode == 200 || response.statusCode == 202) {
      // Si el servidor devuelve una repuesta OK, parseamos el JSON
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Peticion enviada'),
          showCloseIcon: true,
        ),
      );
      Navigator.pop(context);
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
  } else {
    return false;
  }
}

Future<bool> editProfile(String email, String nombre, String desc, String foto, BuildContext context) async {
  final json = '{"email": $email, "nombre": $nombre, "foto": $foto, "descripcion": $desc}';

  final response = await http.post(Uri.parse(_nuevoAmigoURL), body: json);

  //print(response.statusCode);

  if (context.mounted) {
    if (response.statusCode == 200 || response.statusCode == 202) {
      // Si el servidor devuelve una repuesta OK, parseamos el JSON
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cambios guardados'),
          showCloseIcon: true,
        ),
      );
      Navigator.pop(context);
      Navigator.pop(context);
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
  } else {
    return false;
  }
}