import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'app_theme.dart';
import 'validators.dart';
import 'auth_service.dart';
import 'login_screen.dart';
import 'ui_helper.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _auth = AuthService();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _snack(String m, {bool error = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(m),
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

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    await _run(() => _auth.signUp(
        email: _email.text, password: _password.text, name: _name.text.trim()));
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
                  Text('Sign up now',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkBlue)),
                  const SizedBox(height: 6),
                  const Text('Buat akun UTHM Hub gratis',
                      style: TextStyle(color: AppColors.grey)),
                  const SizedBox(height: 28),
                  GoogleSignInButton(
                    onPressed:
                        _loading ? null : () => _run(_auth.signInWithGoogle),
                    label: 'Sign up with Google',
                  ),
                  _orDivider(),
                  _label('Nama Lengkap'),
                  TextFormField(
                    controller: _name,
                    validator: (v) => Validators.notEmpty(v, 'Nama'),
                    decoration: const InputDecoration(
                        hintText: 'Ahmad bin Ali',
                        prefixIcon: Icon(Iconsax.user)),
                  ),
                  const SizedBox(height: 18),
                  _label('Email'),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                    decoration: const InputDecoration(
                        hintText: 'nama@student.uthm.edu.my',
                        prefixIcon: Icon(Iconsax.sms)),
                  ),
                  const SizedBox(height: 18),
                  _label('Password'),
                  TextFormField(
                    controller: _password,
                    obscureText: _obscure,
                    validator: Validators.password,
                    decoration: InputDecoration(
                      hintText: 'Minimal 6 karakter',
                      prefixIcon: const Icon(Iconsax.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Iconsax.eye_slash : Iconsax.eye),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: _loading ? null : _signup,
                    child: _loading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('Create Account'),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                          context, fadeRoute(const LoginScreen())),
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(color: AppColors.grey, fontSize: 14),
                          children: [
                            TextSpan(text: 'Sudah punya akun? '),
                            TextSpan(
                                text: 'Sign In',
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
