import 'package:flutter/material.dart';
import 'login_page.dart';
import '../services/open_snack_bar.dart';
import '../services/http_petitions.dart';
import '../main.dart';

final _registerKey = GlobalKey<FormState>();

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _passwordVisibility = true;
  Icon _passwordEye = const Icon(Icons.visibility_off);
  bool _repeatPasswordVisibility = true;
  Icon _repeatPasswordEye = const Icon(Icons.visibility_off);

  final TextEditingController _nickname = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _repeatPassword = TextEditingController();

  String _nicknameError = '';
  String _emailError = '';
  String _passwordError = '';

  void _actions(bool response, BuildContext context, String email) {
    if (response) {
      openSnackBar(context, const Text('Bienvenido'));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage(email: email)),
      );
    } else {
      openSnackBar(context, const Text('Ha habido un error'));
    }
  }

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
                          margin: const EdgeInsets.all(30),
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
                                      prefixIcon: const Icon(Icons.mail),
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
                                    obscureText: _passwordVisibility,
                                    decoration: InputDecoration(
                                      labelText: 'Contraseña',
                                      hintText: 'contraseña aquí',
                                      prefixIcon: const Icon(Icons.lock),
                                      suffixIcon: IconButton(
                                        icon: _passwordEye,
                                        onPressed: () {
                                          setState(() {
                                            if (_passwordVisibility) {
                                              _passwordVisibility = false;
                                              _passwordEye = const Icon(Icons.visibility);
                                            } else {
                                              _passwordVisibility = true;
                                              _passwordEye = const Icon(Icons.visibility_off);
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
                                      } else if (value != _repeatPassword.text) {
                                        return 'Las contraseñas no coinciden';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  TextFormField(
                                    controller: _repeatPassword,
                                    keyboardType: TextInputType.visiblePassword,
                                    obscureText: _repeatPasswordVisibility,
                                    decoration: InputDecoration(
                                      labelText: 'Confirmar contraseña',
                                      hintText: 'contraseña aquí',
                                      prefixIcon: const Icon(Icons.lock),
                                      suffixIcon: IconButton(
                                        icon: _repeatPasswordEye,
                                        onPressed: () {
                                          setState(() {
                                            if (_repeatPasswordVisibility) {
                                              _repeatPasswordVisibility = false;
                                              _repeatPasswordEye = const Icon(Icons.visibility);
                                            } else {
                                              _repeatPasswordVisibility = true;
                                              _repeatPasswordEye = const Icon(Icons.visibility_off);
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
                                      } else if (value != _password.text) {
                                        return 'Las contraseñas no coinciden';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 40),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: FilledButton(
                                      onPressed: () async {
                                        if(_registerKey.currentState!.validate()) {
                                          bool res = await register(_nickname.text, _email.text, _password.text);
                                          if (!res) {
                                            setState(() {
                                              _nicknameError = 'El email o la contraseña no coinciden';
                                              _emailError = 'El email o la contraseña no coinciden';
                                              _passwordError = 'El email o la contraseña no coinciden';
                                            });
                                          } else {
                                            if (context.mounted) {
                                              return _actions(res, context, _email.text);
                                            }
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
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: OutlinedButton(
                                      onPressed: () {},
                                      child: Image.asset(
                                        'images/logo_google.png',
                                        width: 45,
                                        height: 45,
                                      ),
                                    ),
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