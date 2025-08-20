import 'package:flutter/material.dart';

class SCLogo extends StatelessWidget {
  const SCLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'assets/images/sadece_amblem.png',
        width: 150,
        height: 150,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const Icon(Icons.music_note, size: 72),
      ),
    );
  }
}
