import 'package:flutter/material.dart';

class GoogleButton extends StatelessWidget {
  final bool loading;
  final VoidCallback? onPressed;

  const GoogleButton({super.key, required this.loading, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: loading ? null : onPressed,
        icon: Image.asset(
          'assets/icons/google.png',
          width: 18,
          height: 18,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(Icons.login, size: 18),
        ),
        label: const Text('Google ile devam et'),
      ),
    );
  }
}
