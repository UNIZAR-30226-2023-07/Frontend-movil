import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ConfirmPage extends StatefulWidget {
  @override
  State<ConfirmPage> createState() => _ConfirmPageState();
}

class _ConfirmPageState extends State<ConfirmPage> {
  void sendEmail() async {

    // To create email with params
    final Uri _emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'example@gmail.com',
      queryParameters: {'subject': "This is my subject", 'body': "Hey Kashish here goes the body"},
    );

    await launchUrl(_emailLaunchUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enviar correo electrónico')),
      body: Center(
        child: ElevatedButton(
          onPressed: sendEmail,
          child: Text('Enviar correo'),
        ),
      ),
    );
  }
}
