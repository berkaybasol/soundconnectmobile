import 'package:flutter/material.dart';

class RegisterHeaderLogo extends StatelessWidget {
  const RegisterHeaderLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Center(
          child: Image.asset(
            'assets/images/sadece_amblem.png',
            width: 150,
            height: 150,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(Icons.music_note, size: 72),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}
