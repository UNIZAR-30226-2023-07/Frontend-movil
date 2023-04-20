import 'package:flutter/material.dart';
import 'package:untitled/services/http_petitions.dart';
import '../services/open_snack_bar.dart';
import 'login_page.dart';

final _passwordKey = GlobalKey<FormState>();


class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {

  bool _passwordVisibility = true;
  Icon _passwordEye = const Icon(Icons.visibility_off);
  bool _repeatPasswordVisibility = true;
  Icon _repeatPasswordEye = const Icon(Icons.visibility_off);
  bool isChecked = false;

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _repeatPassword = TextEditingController();

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
                          margin: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.background,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Form(
                            key: _passwordKey,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  const Text('Introduce el correo asociado a la cuenta en la que quieres cambiar la contraseña'),
                                  const SizedBox(height: 20,),
                                  TextFormField(
                                    controller: _email,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      labelText: 'Email',
                                      hintText: 'email@gmail.com',
                                      prefixIcon: const Icon(Icons.person),
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
                                      labelText: 'Nueva contraseña',
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
                                  const SizedBox(height: 20,),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: FilledButton(
                                      onPressed: () async {
                                        if(_passwordKey.currentState!.validate()) {
                                          bool res = await changePassword(_email.text, _password.text);
                                          if (!res) {
                                            if (context.mounted) {
                                              openSnackBar(context, const Text('Ha habido un error'));
                                            }
                                            setState(() {
                                              _emailError = 'El email no existe';
                                            });
                                          } else {
                                            if (context.mounted) {
                                              openSnackBar(context, const Text('Contraseña cambiada'));
                                              Navigator.pop(context);
                                            }
                                          }
                                        }
                                      },
                                      child: const Text('Enviar'),
                                    ),
                                  ),
                                  const SizedBox(height: 15,),
                                  TextButton(onPressed: (){Navigator.pop(context);}, child: const Text('Volver atrás'))
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