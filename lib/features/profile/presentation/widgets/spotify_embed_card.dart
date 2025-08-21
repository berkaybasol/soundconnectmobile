// lib/features/profile/presentation/widgets/spotify_embed_card.dart
import 'dart:ui';
import 'package:flutter/material.dart';

class SpotifyEmbedCard extends StatelessWidget {
  final String? url;
  const SpotifyEmbedCard({super.key, this.url});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final borderColor =
        Color.lerp(cs.primary, cs.tertiary, .5) ?? cs.outlineVariant;

    return SizedBox(
      height: 86,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor.withOpacity(.35)),
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  cs.primary.withOpacity(.06),
                  cs.tertiary.withOpacity(.06),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withOpacity(.10),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      colors: [
                        cs.tertiary.withOpacity(.8),
                        cs.primary.withOpacity(.8),
                        cs.tertiary.withOpacity(.8),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(color: cs.tertiary.withOpacity(.25), blurRadius: 10),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: cs.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: cs.outlineVariant),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Spotify Bağlantısı',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: cs.onSurface,
                          )),
                      const SizedBox(height: 4),
                      Text(
                        (url?.isNotEmpty ?? false)
                            ? url!
                            : 'Sanatçı bağlantısını ekle',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: cs.onSurface.withOpacity(.7)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: (url?.isNotEmpty ?? false)
                      ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Aç: $url (TODO)')),
                    );
                  }
                      : null,
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: const Text('Aç'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
