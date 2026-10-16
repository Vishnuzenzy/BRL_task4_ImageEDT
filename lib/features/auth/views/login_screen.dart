import 'package:flutter/material.dart';

import '../../picker/views/image_picker_screen.dart';
import '../data/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color primary = Color(0xFF4F46E5);
  static const Color background = Color(0xFFEDE9FF);
  static const Color darkText = Color(0xFF30216F);
  static const Color mutedText = Color(0xFF7776AD);

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _auth = AuthService();

  bool _loading = false;
  bool _hidePassword = true;
  bool _isSignUp = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _goToApp() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ImagePickerScreen()),
      (route) => false,
    );
  }

  Future<void> _run(Future<bool> Function() action) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final ok = await action();
      if (!mounted) return;
      if (ok) _goToApp();
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Something went wrong. Try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    await _run(() async {
      if (_isSignUp) {
        await _auth.signUp(email: email, password: password);
      } else {
        await _auth.signIn(email: email, password: password);
      }
      return true;
    });
  }

  Future<void> _google() => _run(_auth.signInWithGoogle);

  void _toggleMode() {
    setState(() {
      _isSignUp = !_isSignUp;
      _error = null;
      _formKey.currentState?.reset();
    });
  }

  InputDecoration _decoration(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: mutedText),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        foregroundColor: darkText,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isSignUp ? 'Create account' : 'Welcome back',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _isSignUp
                      ? 'Sign up to start editing'
                      : 'Log in to continue editing',
                  style: const TextStyle(color: mutedText, fontSize: 15),
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: _decoration('Email', Icons.mail_outline),
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    if (value.isEmpty) return 'Enter your email';
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _hidePassword,
                  decoration: _decoration(
                    'Password',
                    Icons.lock_outline,
                    suffix: IconButton(
                      icon: Icon(
                        _hidePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: mutedText,
                      ),
                      onPressed: () =>
                          setState(() => _hidePassword = !_hidePassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Enter your password';
                    if (v.length < 6) return 'At least 6 characters';
                    return null;
                  },
                ),
                if (_isSignUp) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmController,
                    obscureText: _hidePassword,
                    decoration: _decoration(
                      'Confirm password',
                      Icons.lock_outline,
                    ),
                    validator: (v) {
                      if (v != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    _error!,
                    style: const TextStyle(color: Color(0xFFD32F2F)),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            _isSignUp ? 'Create account' : 'Log in',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Expanded(child: Divider(color: mutedText)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('or', style: TextStyle(color: mutedText)),
                    ),
                    Expanded(child: Divider(color: mutedText)),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: darkText,
                      side: BorderSide.none,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: _loading ? null : _google,
                    icon: Image.asset(
                      'assets/icons/google.png',
                      height: 24,
                      width: 24,
                      errorBuilder: (context, error, stackTrace) =>
                          Image.network(
                            'https://developers.google.com/identity/images/g-logo.png',
                            height: 24,
                            width: 24,
                          ),
                    ),
                    label: const Text(
                      'Continue with Google',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: _loading ? null : _toggleMode,
                    child: Text(
                      _isSignUp
                          ? 'Already have an account? Log in'
                          : "Don't have an account? Create one",
                      style: const TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
