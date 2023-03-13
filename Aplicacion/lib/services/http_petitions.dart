import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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

Future<void> login(TextEditingController email, TextEditingController password, BuildContext context) async {
  final response = await http.post(Uri.parse('http://nuestradireccion'),
    body: ({
      'email': email.text,
      'password': password.text
    })
  );

  if (response.statusCode == 200) {
    // Si el servidor devuelve una repuesta OK, parseamos el JSON
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bienvenido'),
        showCloseIcon: true,
      ),
    );
    /*
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MyHomePage()),
    );
    */
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('mal'),
        showCloseIcon: true,
      ),
    );
    // Si esta respuesta no fue OK, lanza un error.
    throw Exception('Failed to load post');
  }
}