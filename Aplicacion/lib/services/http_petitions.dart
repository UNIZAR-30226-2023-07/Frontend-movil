import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../main.dart';

const String _loginURL = 'http://51.103.94.220:3001/api/auth/login';
const String _registerURL = 'https://httpbin.org/ip';
const String _comillas = "\"";

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

class Post {
  final int userId;
  final int id;
  final String title;
  final String body;

  Post({required this.userId, required this.id, required this.title, required this.body});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      userId: json['userId'],
      id: json['id'],
      title: json['title'],
      body: json['body'],
    );
  }
}

Future<Post> fetchPost() async {
  final response = await http.get(Uri.http('jsonplaceholder.typicode.com', 'posts/1'));

  if (response.statusCode == 200) {
    // Si el servidor devuelve una repuesta OK, parseamos el JSON
    return Post.fromJson(json.decode(response.body));
  } else {
    // Si esta respuesta no fue OK, lanza un error.
    throw Exception('Failed to load post');
  }
}

class Prueba extends StatelessWidget {
  const Prueba({super.key, required this.post});

  final Future<Post> post;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fetch Data Example'),
      ),
      body: Center(
        child: FutureBuilder<Post>(
          future: post,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data!.body);
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

Future<bool> login(TextEditingController email, TextEditingController password, BuildContext context) async {
  String e = _comillas + email.text + _comillas;
  String p = _comillas + password.text + _comillas;
  final json = '{"email": $e, "contra": $p}';

  final response = await http.post(Uri.parse(_loginURL), body: json);

  print(response.statusCode);

  return _actions(response, context);
}

Future<bool> register(TextEditingController nickname, TextEditingController email, TextEditingController password, BuildContext context) async {
  String n = _comillas + nickname.text + _comillas;
  String e = _comillas + email.text + _comillas;
  String p = _comillas + password.text + _comillas;
  final json = '{"nombre": $n, "email": $e, "contra": $p}';

  final response = await http.post(Uri.parse(_registerURL), body: json);

  print(response.statusCode);

  return _actions(response, context);
}