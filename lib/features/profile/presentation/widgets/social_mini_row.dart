// lib/features/profile/presentation/widgets/social_mini_row.dart
import 'package:flutter/material.dart';

class SocialMiniRow extends StatelessWidget {
  final String? instagram;
  final String? youtube;
  final String? soundcloud;

  const SocialMiniRow({
    super.key,
    this.instagram,
    this.youtube,
    this.soundcloud,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final borderColor =
        Color.lerp(cs.primary, cs.tertiary, .5) ?? cs.outlineVariant;

    Widget btn(IconData icon, String? url, String label) {
      final enabled = (url?.trim().isNotEmpty ?? false);
      return Tooltip(
        message: enabled ? url! : '$label ekli değil',
        child: InkWell(
          onTap: enabled
              ? () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Aç: $url (TODO)')),
            );
          }
              : null,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: borderColor.withOpacity(.35)),
              gradient: LinearGradient(
                colors: [
                  cs.surface,
                  cs.surface.withOpacity(.92),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withOpacity(.08),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 18,
              color: enabled ? cs.onSurface : cs.onSurface.withOpacity(.35),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        btn(Icons.camera_alt_outlined, instagram, 'Instagram'),
        const SizedBox(width: 8),
        btn(Icons.ondemand_video_outlined, youtube, 'YouTube'),
        const SizedBox(width: 8),
        btn(Icons.cloud_outlined, soundcloud, 'SoundCloud'),
      ],
    );
  }
}
