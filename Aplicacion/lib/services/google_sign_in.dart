import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:untitled/services/open_snack_bar.dart';

class GoogleSignInApi {
 static final _googleSignIn = GoogleSignIn();

 static Future<GoogleSignInAccount?> login() => _googleSignIn.signIn();
}

Future signIn(BuildContext context) async {
 final user = await GoogleSignInApi.login();
 if(user == null) {
  if(context.mounted) {
   openSnackBar(context, const Text('No se puedo iniciar sesión con google'));
  }
 } else {

 }
 print(user);
}