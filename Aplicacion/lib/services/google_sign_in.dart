import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInApi {
 static final _googleSignIn = GoogleSignIn();

 static Future<GoogleSignInAccount?> login() => _googleSignIn.signIn();

 static Future<GoogleSignInAccount?> logout() => _googleSignIn.disconnect();
}

Future<GoogleSignInAccount?> signIn() async {
  final user = await GoogleSignInApi.login();
  print(user);
  return user;
}

Future<void> logOut() async {
 final user = await GoogleSignInApi.logout();
 print(user);
}