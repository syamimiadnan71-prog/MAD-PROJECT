import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'app_theme.dart';
import 'validators.dart';
import 'auth_gate.dart';
import 'auth_service.dart';
import 'sign_up_screen.dart';
import 'forgot_password_screen.dart';
import 'ui_helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = AuthService();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _snack(String msg, {bool error = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? AppColors.danger : AppColors.accent,
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _loading = true);
    try {
      await action();
      if (mounted) Navigator.popUntil(context, (r) => r.isFirst);
    } on AuthException catch (e) {
      _snack(e.message);
    } catch (_) {
      _snack('Terjadi kesalahan. Coba lagi.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    await _run(
        () => _auth.signIn(email: _email.text, password: _password.text));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.darkBlue,
        elevation: 0,
      ),
      body: SafeArea(
        child: FadeSlideIn(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 8, 28, 28),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const BrandHeader(),
                  const SizedBox(height: 32),
                  Text('Welcome back',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkBlue)),
                  const SizedBox(height: 6),
                  const Text('Sign in to your UTHM account',
                      style: TextStyle(color: AppColors.grey)),
                  const SizedBox(height: 28),
                  GoogleSignInButton(
                    onPressed:
                        _loading ? null : () => _run(_auth.signInWithGoogle),
                    label: 'Sign in with Google',
                  ),
                  _orDivider(),
                  _label('Email'),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                    decoration: const InputDecoration(
                      hintText: 'nama@student.uthm.edu.my',
                      prefixIcon: Icon(Iconsax.sms),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _label('Password'),
                  TextFormField(
                    controller: _password,
                    obscureText: _obscure,
                    validator: Validators.password,
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      prefixIcon: const Icon(Iconsax.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Iconsax.eye_slash : Iconsax.eye),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.push(
                          context, fadeRoute(const ForgotPasswordScreen())),
                      child: const Text('Forgot Password?'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loading ? null : _login,
                    child: _loading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Log In'),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                          context, fadeRoute(const SignupScreen())),
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(color: AppColors.grey, fontSize: 14),
                          children: [
                            TextSpan(text: 'Belum punya akun? '),
                            TextSpan(
                                text: 'Sign Up',
                                style: TextStyle(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _orDivider() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 22),
        child: Row(children: [
          Expanded(child: Divider()),
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('atau', style: TextStyle(color: AppColors.grey))),
          Expanded(child: Divider()),
        ]),
      );

  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(t,
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: AppColors.text)),
      );
}
