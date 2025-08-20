import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  final bool loading;
  final VoidCallback? onPressed;

  const LoginButton({super.key, required this.loading, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 52,
      child: FilledButton(
        onPressed: onPressed,
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          textStyle: WidgetStatePropertyAll(
            theme.textTheme.labelLarge?.copyWith(fontSize: 16),
          ),
        ),
        child: loading
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : const Text('Giriş yap'),
      ),
    );
  }
}
