// lib/features/profile/presentation/pages/musician_profile_page.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:soundconnectmobile/core/network/dio_client.dart';
import 'package:soundconnectmobile/features/auth/presentation/login/login_page.dart';
import 'package:soundconnectmobile/features/onboarding/presentation/pages/musician_onboarding_page.dart';

import '../../data/models/requests/musician_profile_dto.dart';
import '../providers/profile_providers.dart';
import '../widgets/auth_required_view.dart';
import '../widgets/not_found_profile_view.dart';
import '../widgets/error_view.dart';
import '../widgets/profile_header.dart';
import '../widgets/neon_divider.dart';
import '../widgets/venues_marquee.dart';
import '../widgets/spotify_embed_card.dart';
import '../widgets/social_mini_row.dart';
import '../widgets/glass_section.dart';

class MusicianProfilePage extends ConsumerWidget {
  const MusicianProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(authTokenProvider);
    final async = ref.watch(musicianProfileProvider);
    final cs = Theme.of(context).colorScheme;

    // Token yoksa: giriş iste
    if (token == null || token.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profilim')),
        body: AuthRequiredView(
          onLogin: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
            ref.invalidate(musicianProfileProvider);
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim'),
        actions: [
          IconButton(
            tooltip: 'Yenile',
            onPressed: () => ref.invalidate(musicianProfileProvider),
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: 'Düzenle',
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => const MusicianOnboardingPage(),
              ));
            },
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: Stack(
        children: [
          // arka plan gradienti
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.7, -0.8),
                    radius: 1.2,
                    colors: [
                      cs.primary.withOpacity(.06),
                      cs.tertiary.withOpacity(.04),
                      cs.surface,
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
          ),
          async.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) {
              if (e is DioException) {
                final status = e.response?.statusCode ?? 0;
                final msg = e.error?.toString() ?? 'Hata';
                if (status == 401 || status == 403) {
                  return AuthRequiredView(
                    onLogin: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    ),
                  );
                }
                if (status == 404) {
                  return NotFoundProfileView(
                    message: msg,
                    onCreate: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => const MusicianOnboardingPage(),
                      ));
                    },
                  );
                }
                return ErrorView(
                  message: msg,
                  onRetry: () => ref.invalidate(musicianProfileProvider),
                );
              }
              return ErrorView(
                message: e.toString(),
                onRetry: () => ref.invalidate(musicianProfileProvider),
              );
            },
            data: (p) => RefreshIndicator(
              onRefresh: () async => ref.invalidate(musicianProfileProvider),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  ProfileHeader(profile: p),
                  const SizedBox(height: 14),
                  const NeonDivider(),
                  const SizedBox(height: 12),

                  GlassSection(
                    title: 'Aktif Çaldığı Mekanlar',
                    child: const SizedBox(
                      height: 44,
                      child: VenuesMarquee(venues: null), // p.activeVenues bağlamak istersen: venues: p.activeVenues
                    ),
                  ),
                  const SizedBox(height: 12),

                  GlassSection(
                    title: 'Spotify',
                    child: SpotifyEmbedCard(url: p.spotifyEmbedUrl),
                  ),
                  const SizedBox(height: 12),

                  GlassSection(
                    title: 'Sosyal',
                    child: SocialMiniRow(
                      instagram: p.instagramUrl,
                      youtube: p.youtubeUrl,
                      soundcloud: p.soundcloudUrl,
                    ),
                  ),
                  const SizedBox(height: 12),

                  GlassSection(
                    title: 'Biyografi',
                    child: Text(
                      (p.bio?.trim().isNotEmpty ?? false)
                          ? p.bio!.trim()
                          : 'Biyografi eklenmemiş.',
                      style: TextStyle(color: cs.onSurface.withOpacity(.85)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
