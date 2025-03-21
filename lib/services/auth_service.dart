import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true; // Success
    } catch (e) {
      debugPrint("Login Error: $e");
      return false; // Failed
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return true; // Success
    } catch (e) {
      debugPrint("Registration Error: $e");
      return false; // Failed
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint("Logout Error: $e");
    }
  }
}
