import 'package:flutter/material.dart';
 
import 'login_screen.dart';
 
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
 
  static const Color primary = Color(0xFF4F46E5);
  static const Color background = Color(0xFFEDE9FF);
  static const Color darkText = Color(0xFF30216F);
  static const Color mutedText = Color(0xFF7776AD);
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: const Icon(Icons.auto_awesome,
                    color: Colors.white, size: 56),
              ),
              const SizedBox(height: 32),
              const Text(
                'ImageEDT',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: darkText,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Crop, rotate and enhance your photos in a few taps.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: mutedText, height: 1.4),
              ),
              const Spacer(),
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
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  child: const Text(
                    'Get Started',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
 