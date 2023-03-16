import 'package:flutter/material.dart';
import 'package:untitled/main.dart';
import 'forgot_password_page.dart';
import 'login_page.dart';
import '../services/http_petitions.dart';

final _registerKey = GlobalKey<FormState>();

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool visibility = true;
  Icon ojo = const Icon(Icons.visibility_off);
  bool isChecked = false;

  final TextEditingController _nickname = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  String _nicknameError = '';
  String _emailError = '';
  String _passwordError = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: FractionalOffset.topCenter,
                        end: FractionalOffset.bottomCenter,
                        colors: [
                          Colors.indigoAccent,
                          Colors.indigo,
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Image.asset(
                            'images/logo.png',
                            height: 150,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.background,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Form(
                            key: _registerKey,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _nickname,
                                    keyboardType: TextInputType.text,
                                    decoration: InputDecoration(
                                      labelText: 'Nickname',
                                      hintText: 'Ismaber',
                                      prefixIcon: const Icon(Icons.person),
                                      errorText: (_nicknameError.isEmpty)
                                          ? null
                                          : _nicknameError,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'El campo es obligatorio';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    controller: _email,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      labelText: 'Email',
                                      hintText: 'email@gmail.com',
                                      prefixIcon: Icon(Icons.mail),
                                      errorText: (_emailError.isEmpty)
                                          ? null
                                          : _emailError,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'El campo es obligatorio';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    controller: _password,
                                    keyboardType: TextInputType.visiblePassword,
                                    obscureText: visibility,
                                    decoration: InputDecoration(
                                      labelText: 'Contraseña',
                                      hintText: 'contraseña aquí',
                                      prefixIcon: const Icon(Icons.lock),
                                      suffixIcon: IconButton(
                                        icon: ojo,
                                        onPressed: () {
                                          setState(() {
                                            if (visibility) {
                                              visibility = false;
                                              ojo = const Icon(Icons.visibility);
                                            } else {
                                              visibility = true;
                                              ojo = const Icon(Icons.visibility_off);
                                            }
                                          });
                                        },
                                      ),
                                      errorText: (_passwordError.isEmpty)
                                          ? null
                                          : _passwordError,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'El campo es obligatorio';
                                      }
                                      return null;
                                    },
                                  ),
                                  Row(
                                    children: [
                                      Checkbox(
                                        checkColor: Colors.white,
                                        value: isChecked,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            isChecked = value!;
                                          });
                                        },
                                      ),
                                      const Text('Recordarme'),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: FilledButton(
                                      onPressed: () async {
                                        if(_registerKey.currentState!.validate()) {
                                          bool res = await register(_nickname, _email, _password, context);
                                          if (!res) {
                                            setState(() {
                                              _nicknameError = 'El email o la contraseña no coinciden';
                                              _emailError = 'El email o la contraseña no coinciden';
                                              _passwordError = 'El email o la contraseña no coinciden';
                                            });
                                          }
                                        }
                                      },
                                      child: const Text('Registrarse'),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (context) => const Login()),
                                        );
                                      },
                                      child: const Text('Iniciar sesión'),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: const [
                                      Expanded(
                                        child: Divider(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      SizedBox(width: 5,),
                                      Text(
                                        'O registrarse con',
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      SizedBox(width: 5,),
                                      Expanded(
                                        child: Divider(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      SizedBox(
                                        child: OutlinedButton(
                                          onPressed: () {},
                                          child: Image.asset(
                                            'images/logo_google.png',
                                            width: 70,
                                            height: 70,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        child: OutlinedButton(
                                          onPressed: () {},
                                          child: Image.asset(
                                            'images/logo_facebook.png',
                                            width: 70,
                                            height: 70,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}