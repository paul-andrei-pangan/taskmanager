import 'package:flutter/material.dart';
import 'package:taskmanager/services/auth_service.dart';
import 'package:taskmanager/screens/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              AuthService().logout();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
          ),
        ],
      ),
      body: const Center(child: Text("Welcome!")),
    );
  }
}
