import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'login_screen.dart';
import 'sign_up_screen.dart';
import 'ui_helper.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: FadeSlideIn(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(flex: 2),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 28,
                          offset: const Offset(0, 12)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset('assets/images/logo.jpeg',
                        height: 120, width: 120, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 32),
                Text('Welcome To\nUTHM Hub',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkBlue,
                        height: 1.2)),
                const SizedBox(height: 12),
                const Text(
                  'Your campus-wide marketplace, services, and transport connection.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppColors.grey, fontSize: 14, height: 1.5),
                ),
                const Spacer(flex: 3),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.push(context, fadeRoute(const LoginScreen())),
                  child: const Text('Login with Student Email'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () =>
                      Navigator.push(context, fadeRoute(const SignupScreen())),
                  child: const Text('First time here? Sign Up'),
                ),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
