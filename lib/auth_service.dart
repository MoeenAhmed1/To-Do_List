import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  Future<User> signInUser({String email, String password}) async {
    try {
      UserCredential userInfo = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return userInfo.user;
    } catch (e) {
      print(e);
    }
  }

  Future<User> signUpUser({String email, String password}) async {
    try {
      UserCredential userInfo = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userInfo.user;
    } catch (e) {
      print(e);
    }
  }
}
