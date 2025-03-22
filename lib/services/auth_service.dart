import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ REGISTER METHOD (Fix missing method)
  Future<String?> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return null; // Success, walang error
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase Register Error: ${e.code} - ${e.message}");

      if (e.code == 'email-already-in-use') {
        return "Email is already in use. Try logging in.";
      } else if (e.code == 'weak-password') {
        return "Password should be at least 6 characters.";
      } else if (e.code == 'invalid-email') {
        return "Invalid email format.";
      } else {
        return "Registration failed: ${e.message}";
      }
    }
  }

  // ✅ LOGIN METHOD
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Success, walang error
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase Login Error: ${e.code} - ${e.message}");

      if (e.code == 'user-not-found') {
        return "No user found with this email.";
      } else if (e.code == 'wrong-password') {
        return "Incorrect password. Try again.";
      } else if (e.code == 'invalid-email') {
        return "Invalid email format.";
      } else {
        return "Login failed: ${e.message}";
      }
    }
  }

  // ✅ LOGOUT METHOD
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint("Logout Error: $e");
    }
  }
}
