import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInApi {
  static final _googleSignIn = GoogleSignIn();

  Future<GoogleSignInAccount?> signIn() async {
    final user = await _googleSignIn.signIn();
    print(user);
    return user;
  }

  Future<void> signOut() async {
    bool signedIn = await _googleSignIn.isSignedIn();
    if (signedIn) {
      final user = await _googleSignIn.disconnect();
      print(user);
    }
  }
}