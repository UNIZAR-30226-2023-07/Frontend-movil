import 'package:flutter/material.dart';
import '../main.dart';
import '../services/google_sign_in.dart';
import '../widgets/custom_filled_button.dart';
import '../services/open_snack_bar.dart';
import '../services/http_petitions.dart';
import '../services/local_storage.dart';
import 'forgot_password_page.dart';
import 'register_page.dart';

final _loginKey = GlobalKey<FormState>();

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool visibility = true;
  Icon ojo = const Icon(Icons.visibility_off);
  bool rememberMe = false;

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  String _emailError = '';
  String _passwordError = '';

  @override
  void initState() {
    super.initState();

    if(LocalStorage.prefs.getBool('rememberMe') != null) {
      rememberMe = LocalStorage.prefs.getBool('rememberMe') as bool;
    }
  }

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
                            key: _loginKey,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _email,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      label: const Text('Email'),
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
                                    obscureText: visibility,
                                    decoration: InputDecoration(
                                      label: const Text('Contraseña'),
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
                                        value: rememberMe,
                                        onChanged: (bool? value) {
                                          setState(() {
                                            rememberMe = value!;
                                            LocalStorage.prefs.setBool('rememberMe', rememberMe);
                                          });
                                        },
                                      ),
                                      const Text('Recordarme'),
                                    ],
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const ForgotPasswordPage(),
                                        ),
                                      );
                                    },
                                    child: const Text('¿Olvidaste la contraseña?'),
                                  ),
                                  const SizedBox(height: 10),
                                  CustomFilledButton(
                                    onPressed: () async {
                                      if(_loginKey.currentState!.validate()) {
                                        if (_email.text == 'admin') {
                                          Navigator.pushReplacement(
                                            context,
                                            //pasar el email para saber con cual esta registrado
                                            MaterialPageRoute(builder: (context) => MyHomePage(email: _email.text)),
                                          );
                                        } else {
                                          final bool res = await login(_email.text, _password.text);
                                          if (!res) {
                                            setState(() {
                                              _emailError = 'El email o la contraseña no coinciden';
                                              _passwordError = 'El email o la contraseña no coinciden';
                                            });
                                          } else {
                                            LocalStorage.prefs.setString('email', _email.text);
                                            LocalStorage.prefs.setString('password', _password.text);
                                            if (context.mounted) {
                                              return _actions(res, context, _email.text);
                                            }
                                          }
                                        }
                                      }
                                    },
                                    content: const Text('Iniciar sesión'),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(builder: (context) => const RegisterPage()),
                                        );
                                      },
                                      child: const Text('Registrarse'),
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
                                        'O iniciar sesión con',
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
                                      onPressed: () async {
                                        final user = await GoogleSignInApi().signIn();
                                        if (user != null) {
                                          final bool res = await login(user.email, '1234');
                                          if (!res) {
                                            setState(() {
                                              _emailError = 'El email o la contraseña no coinciden';
                                              _passwordError = 'El email o la contraseña no coinciden';
                                            });
                                          } else {
                                            LocalStorage.prefs.setString('email', user.email);
                                            LocalStorage.prefs.setString('password', '1234');
                                            if (context.mounted) {
                                              return _actions(res, context, user.email);
                                            }
                                          }
                                        } else {
                                          if(context.mounted) {
                                            openSnackBar(context, const Text('No se puedo iniciar sesión con google'));
                                          }
                                        }
                                      },
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