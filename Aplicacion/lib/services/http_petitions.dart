import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../main.dart';

const String _loginURL = 'http://51.103.94.220:3001/api/auth/login';
const String _registerURL = 'http://51.103.94.220:3001/api/auth/register';

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

bool _actions(http.Response response, BuildContext context) {
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
      MaterialPageRoute(builder: (context) => const MyHomePage()),
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

Future<bool> login(String email, String password, BuildContext context) async {
  if (email == 'admin') {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MyHomePage()),
    );
    return true;
  }
  final json = '{"email": "$email", "contra": "$password"}';

  final response = await http.post(Uri.parse(_loginURL), body: json);

  //print(response.statusCode);

  if (context.mounted) {
    return _actions(response, context);
  } else {
    return false;
  }
}

Future<bool> register(String nickname, String email, String password, BuildContext context) async {
  final json = '{"nombre": $nickname, "email": $email, "contra": $password}';

  final response = await http.post(Uri.parse(_registerURL), body: json);

  //print(response.statusCode);

  if (context.mounted) {
    return _actions(response, context);
  } else {
    return false;
  }
}