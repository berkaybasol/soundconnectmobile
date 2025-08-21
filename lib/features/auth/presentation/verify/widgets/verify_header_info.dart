import 'package:flutter/material.dart';

class VerifyHeaderInfo extends StatelessWidget {
  final String email;
  final int otpTtlSeconds;

  const VerifyHeaderInfo({
    super.key,
    required this.email,
    required this.otpTtlSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('E-posta: $email', style: theme.textTheme.bodyMedium),
        const SizedBox(height: 8),
        if (otpTtlSeconds > 0)
          Text(
            'Kodun geçerlilik süresi: ${otpTtlSeconds}s',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurface.withOpacity(.7),
            ),
          ),
      ],
    );
  }
}
