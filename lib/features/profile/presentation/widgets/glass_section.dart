// lib/features/profile/presentation/widgets/glass_section.dart
import 'dart:ui';
import 'package:flutter/material.dart';

class GlassSection extends StatelessWidget {
  final String title;
  final Widget child;
  const GlassSection({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final borderColor =
        Color.lerp(cs.primary, cs.tertiary, .5) ?? cs.outlineVariant;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: cs.surface.withOpacity(.75),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor.withOpacity(.35)),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withOpacity(.08),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
