// lib/features/profile/presentation/widgets/neon_divider.dart
import 'package:flutter/material.dart';

class NeonDivider extends StatelessWidget {
  const NeonDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 3,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            cs.primary.withOpacity(.0),
            cs.primary.withOpacity(.7),
            cs.tertiary.withOpacity(.7),
            cs.tertiary.withOpacity(.0),
          ],
        ),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
