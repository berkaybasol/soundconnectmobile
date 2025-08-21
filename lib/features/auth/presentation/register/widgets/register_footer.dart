import 'package:flutter/material.dart';

class RegisterFooter extends StatelessWidget {
  final VoidCallback onGoLogin;
  const RegisterFooter({super.key, required this.onGoLogin});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Hesabın var mı?",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: cs.onSurface.withOpacity(.75),
              ),
            ),
            TextButton(
              onPressed: onGoLogin,
              child: Text(
                'Giriş Yap',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
