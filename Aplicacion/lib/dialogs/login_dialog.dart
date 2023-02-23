import 'package:flutter/material.dart';

final _formkey = GlobalKey<FormState>();

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool visibility = true;
  Icon ojo = const Icon(Icons.visibility_off);
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    /*
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.red;
    }
    */
    return Form(
      key: _formkey,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  hintText: 'email@gmail.com',
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
                  labelText: 'Contraseña',
                  border: const OutlineInputBorder(),
                  hintText: 'contraseña aquí',
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
                onPressed: () {},
                child: const Text('¿Olvidaste la contraseña?'),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: () {
                    if(_formkey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Bienvenido'),
                          showCloseIcon: true,
                          closeIconColor: Colors.white,
                        ),
                      );
                      Navigator.pop(context);
                    }
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
    );
  }
}