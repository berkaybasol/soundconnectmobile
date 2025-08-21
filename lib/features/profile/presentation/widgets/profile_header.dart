// lib/features/profile/presentation/widgets/profile_header.dart
import 'package:flutter/material.dart';
import '../../data/models/requests/musician_profile_dto.dart';

class ProfileHeader extends StatelessWidget {
  final MusicianProfileDto profile;
  const ProfileHeader({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final stage = profile.stageName?.trim();
    final hasPic = (profile.profilePicture?.trim().isNotEmpty ?? false);

    // TODO: backend bağlayınca doldur
    final followers = 0;
    final following = 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Neon halka + avatar
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                cs.tertiary.withOpacity(.9),
                cs.primary.withOpacity(.9),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: cs.tertiary.withOpacity(.22),
                blurRadius: 16,
                spreadRadius: 1,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 36,
            backgroundColor: cs.surface,
            backgroundImage: hasPic ? NetworkImage(profile.profilePicture!) : null,
            child: hasPic
                ? null
                : Icon(Icons.person_outline_rounded,
                size: 36, color: cs.onSurface.withOpacity(.6)),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sahne adı
              Text(
                (stage?.isNotEmpty ?? false) ? stage! : 'Sahne adı eklenmemiş',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              // @username (şimdilik placeholder)
              Text(
                '@musician', // TODO: username varsa göster
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: cs.onSurface.withOpacity(.6)),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _StatPill(label: 'Takipçi', value: followers),
                  const SizedBox(width: 8),
                  _StatPill(label: 'Takip', value: following),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final int value;
  const _StatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final borderColor =
        Color.lerp(cs.primary, cs.tertiary, .5) ?? cs.outlineVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor.withOpacity(.45)),
        boxShadow: [
          BoxShadow(color: cs.primary.withOpacity(.12), blurRadius: 10, offset: const Offset(0, 2)),
        ],
        gradient: LinearGradient(
          colors: [
            cs.surface,
            cs.surface.withOpacity(.92),
          ],
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$value',
              style: TextStyle(
                  fontWeight: FontWeight.w800, color: cs.onSurface)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: cs.onSurface.withOpacity(.8))),
        ],
      ),
    );
  }
}
