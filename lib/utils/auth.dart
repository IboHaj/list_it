import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  static final auth = FirebaseAuth.instance;

  static User? user;

  static Future<User?> loginUserWithEmailAndPassword(String email, String password, FirebaseAuth auth) async {
    try {
      final credentials = await auth.signInWithEmailAndPassword(email: email, password: password);
      return credentials.user;
    } catch (e) {
      log('something went wrong');
    }
    return null;
  }
}