import 'package:flutter/material.dart';

class ResendButton extends StatelessWidget {
  final bool canResend;      // cooldown yok + busy değil
  final bool resending;      // spinner
  final int cooldownSeconds; // metin göstermek için
  final VoidCallback onResend;

  const ResendButton({
    super.key,
    required this.canResend,
    required this.resending,
    required this.cooldownSeconds,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (cooldownSeconds > 0) {
      return Text(
        'Yeniden gönder için bekle: ${cooldownSeconds}s',
        textAlign: TextAlign.center,
        style: theme.textTheme.bodySmall?.copyWith(
          color: cs.onSurface.withOpacity(.7),
        ),
      );
    }

    return SizedBox(
      height: 44,
      child: OutlinedButton(
        onPressed: canResend ? onResend : null,
        child: resending
            ? const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : const Text('Kodu yeniden gönder'),
      ),
    );
  }
}
