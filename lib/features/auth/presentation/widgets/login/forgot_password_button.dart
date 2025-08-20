import 'package:flutter/material.dart';

class ForgotPasswordButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const ForgotPasswordButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/icons/fish.png',
            width: 18,
            height: 18,
            errorBuilder: (_, __, ___) => const Text('🐟', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(width: 6),
          const Text('Şifreni mi unuttun?'),
        ],
      ),
    );
  }
}
