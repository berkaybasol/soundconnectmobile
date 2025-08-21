// lib/features/profile/presentation/widgets/auth_required_view.dart
import 'package:flutter/material.dart';

class AuthRequiredView extends StatelessWidget {
  final VoidCallback onLogin;
  const AuthRequiredView({super.key, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline_rounded,
                size: 40, color: cs.onSurface.withOpacity(.9)),
            const SizedBox(height: 10),
            const Text('Bu sayfayı görmek için giriş yapmalısın.'),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onLogin,
              icon: const Icon(Icons.login_rounded),
              label: const Text('Giriş yap'),
            ),
          ],
        ),
      ),
    );
  }
}
