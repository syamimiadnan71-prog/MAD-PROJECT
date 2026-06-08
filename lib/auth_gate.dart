import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'dashboard_screen.dart';
import 'welcome_screen.dart'; // tambahkan baris ini

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        // Sudah login → Dashboard. Belum → Login. Otomatis, tanpa Navigator manual.
        return snapshot.hasData
            ? const DashboardScreen()
            : const WelcomeScreen();
      },
    );
  }
}
