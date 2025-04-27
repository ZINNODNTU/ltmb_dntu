// auth_methods.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:my_note/view/NoteListScreen.dart'; // Ensure this path is correct

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<User?> getCurrentUser() async {
    return auth.currentUser;
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken,
        );

        UserCredential result = await firebaseAuth.signInWithCredential(credential);
        User? userDetails = result.user;

        if (userDetails != null) {
          // Đăng nhập thành công -> chuyển sang Home (NoteListScreen)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => NoteListScreen()),
          );
        }
      }
    } catch (e) {
      print("Error signing in with Google: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đăng nhập thất bại: $e")),
      );
    }
  }
}
