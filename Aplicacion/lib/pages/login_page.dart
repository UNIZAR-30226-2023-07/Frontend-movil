import 'package:flutter/material.dart';
import 'package:untitled/main.dart';
import '../services/open_snack_bar.dart';
import '../widgets/custom_filled_button.dart';
import '../services/http_petitions.dart';
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
  bool isChecked = false;

  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

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
                            key: _loginKey,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  TextFormField(
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
                                        bool res = await login(email, password, context);
                                        if (!res) {
                                          setState(() {
                                            _emailError = 'El email o la contraseña no coinciden';
                                            _passwordError = 'El email o la contraseña no coinciden';
                                          });
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