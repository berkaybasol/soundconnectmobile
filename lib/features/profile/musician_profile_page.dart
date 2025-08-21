// lib/features/profile/musician_profile_page.dart
import 'dart:async';
import 'dart:ui';
import 'package:characters/characters.dart'; // marquee initial için
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Bearer token (RAM)
import 'package:soundconnectmobile/core/network/dio_client.dart';

// App içi sayfalar
import 'package:soundconnectmobile/features/auth/presentation/login/login_page.dart';
import 'package:soundconnectmobile/features/onboarding/presentation/pages/musician_onboarding_page.dart';

/// Basit hata tipleri
class _AuthException implements Exception {
  final String message;
  _AuthException(this.message);
  @override
  String toString() => message;
}

class _NotFoundException implements Exception {
  final String message;
  _NotFoundException(this.message);
  @override
  String toString() => message;
}

/// --- DTO --------------------------------------------------------------------
class MusicianProfileDto {
  final String? id;
  final String? stageName;
  final String? bio;
  final String? profilePicture;
  final String? instagramUrl;
  final String? youtubeUrl;
  final String? soundcloudUrl;
  final String? spotifyEmbedUrl;
  final List<String> instruments;
  final List<String> activeVenues;

  MusicianProfileDto({
    this.id,
    this.stageName,
    this.bio,
    this.profilePicture,
    this.instagramUrl,
    this.youtubeUrl,
    this.soundcloudUrl,
    this.spotifyEmbedUrl,
    this.instruments = const [],
    this.activeVenues = const [],
  });

  factory MusicianProfileDto.fromJson(Map<String, dynamic> j) {
    List<String> _list(dynamic v) =>
        (v is List) ? v.map((e) => e.toString()).toList() : const [];
    return MusicianProfileDto(
      id: j['id']?.toString(),
      stageName: j['stageName']?.toString(),
      bio: j['bio']?.toString(),
      profilePicture: j['profilePicture']?.toString(),
      instagramUrl: j['instagramUrl']?.toString(),
      youtubeUrl: j['youtubeUrl']?.toString(),
      soundcloudUrl: j['soundcloudUrl']?.toString(),
      spotifyEmbedUrl: j['spotifyEmbedUrl']?.toString(),
      instruments: _list(j['instruments']),
      activeVenues: _list(j['activeVenues']),
    );
  }
}

/// --- Data Provider -----------------------------------------------------------
final _musicianProfileProvider =
FutureProvider.autoDispose<MusicianProfileDto>((ref) async {
  // token değişince provider yeniden çalışsın
  final _ = ref.watch(authTokenProvider);

  final dio = ref.read(dioProvider);
  final res = await dio.get('/api/v1/user/musician-profiles/me');
  final status = res.statusCode ?? 0;
  final body = (res.data is Map) ? res.data as Map : const {};

  String? apiMessage;
  if (body['message'] != null) apiMessage = body['message'].toString();

  if (status == 401 || status == 403) {
    throw _AuthException(apiMessage ?? 'Oturum gerekli');
  }
  if (status == 404) {
    throw _NotFoundException(apiMessage ?? 'Müzisyen profili bulunamadı');
  }
  if (status != 200) {
    throw Exception(apiMessage ?? 'Profil getirilemedi ($status)');
  }

  if (body['data'] == null || body['data'] is! Map) {
    throw Exception('Profil verisi bulunamadı');
  }
  return MusicianProfileDto.fromJson(
    Map<String, dynamic>.from(body['data'] as Map),
  );
});

/// --- Sayfa -------------------------------------------------------------------
class MusicianProfilePage extends ConsumerWidget {
  const MusicianProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(authTokenProvider);
    final async = ref.watch(_musicianProfileProvider);
    final cs = Theme.of(context).colorScheme;

    // Token yoksa: giriş iste
    if (token == null || token.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profilim')),
        body: _AuthRequiredView(
          onLogin: () async {
            await Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
            ref.invalidate(_musicianProfileProvider);
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
            onPressed: () => ref.invalidate(_musicianProfileProvider),
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
          // Subtle digital neon background
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
              if (e is _AuthException) {
                return _AuthRequiredView(
                  onLogin: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  ),
                );
              }
              if (e is _NotFoundException) {
                return _NotFoundProfileView(
                  message: e.message,
                  onCreate: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const MusicianOnboardingPage(),
                    ));
                  },
                );
              }
              return _ErrorView(
                message: e.toString(),
                onRetry: () => ref.invalidate(_musicianProfileProvider),
              );
            },
            data: (p) => RefreshIndicator(
              onRefresh: () async => ref.invalidate(_musicianProfileProvider),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  _ProfileHeader(profile: p),
                  const SizedBox(height: 14),
                  const _NeonDivider(),
                  const SizedBox(height: 12),

                  _GlassSection(
                    title: 'Aktif Çaldığı Mekanlar',
                    child: const SizedBox(
                      height: 44, // kesin yükseklik
                      child: _VenuesMarqueeSafe(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _GlassSection(
                    title: 'Spotify',
                    child: const _SpotifyEmbedCardSafe(),
                  ),
                  const SizedBox(height: 12),

                  _GlassSection(
                    title: 'Sosyal',
                    child: _SocialMiniRow(
                      instagram: p.instagramUrl,
                      youtube: p.youtubeUrl,
                      soundcloud: p.soundcloudUrl,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _GlassSection(
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

/// --- “Giriş yap” ekranı ------------------------------------------------------
class _AuthRequiredView extends StatelessWidget {
  final VoidCallback onLogin;
  const _AuthRequiredView({required this.onLogin});

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

/// --- “Profil bulunamadı” ekranı ---------------------------------------------
class _NotFoundProfileView extends StatelessWidget {
  final String message;
  final VoidCallback onCreate;
  const _NotFoundProfileView({required this.message, required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_off_outlined,
                size: 40, color: cs.onSurface.withOpacity(.9)),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.edit_note_rounded),
              label: const Text('Profilini oluştur / düzenle'),
            ),
          ],
        ),
      ),
    );
  }
}

/// --- Header: avatar + counters ------------------------------------------------
class _ProfileHeader extends StatelessWidget {
  final MusicianProfileDto profile;
  const _ProfileHeader({required this.profile});

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

              // Sayaçlar
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

/// --- İnce neon çizgi ---------------------------------------------------------
class _NeonDivider extends StatelessWidget {
  const _NeonDivider();

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

/// --- Aktif Mekanlar: güvenli marquee (layout sonrası başlar) -----------------
class _VenuesMarqueeSafe extends StatefulWidget {
  const _VenuesMarqueeSafe();

  @override
  State<_VenuesMarqueeSafe> createState() => _VenuesMarqueeSafeState();
}

class _VenuesMarqueeSafeState extends State<_VenuesMarqueeSafe> {
  final _controller = ScrollController();
  Timer? _timer;
  double _offset = 0;

  // Demo: veri UI'dan gelsin istemiyorsan buraya bağlayabilirsin
  List<String> get _venues => _providedVenues ?? const [];
  List<String>? _providedVenues;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Yukarıdaki Section, child olarak bizi sabit yükseklikte çağırıyor.
    // Dışarıdan venue listesi vermek istersen widget parametresiyle geçebilirsin.
    // Şimdilik parent'tan geleni almıyoruz; örnek akışı güvenli kalsın diye sabit bırakıyorum.
  }

  @override
  void initState() {
    super.initState();
    // Başlangıçta boş olmasın diye "eklenmemiş" yazısı göster.
    _providedVenues = const ['Henüz eklenmemiş'];

    // İlk layout bittikten sonra timer'ı başlat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _timer = Timer.periodic(const Duration(milliseconds: 40), (_) {
        if (!_controller.hasClients) return;
        final max = _controller.position.maxScrollExtent;
        if (max <= 0) return;
        _offset = (_offset + 1.0);
        if (_offset >= max) _offset = 0;
        _controller.jumpTo(_offset);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final items = (_venues.isEmpty) ? const ['Henüz eklenmemiş'] : _venues;
    final doubled = [...items, ...items];

    final borderColor =
        Color.lerp(cs.primary, cs.tertiary, .5) ?? cs.outlineVariant;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          width: double.infinity,
          height: double.infinity, // parent SizedBox(44) belirliyor
          decoration: BoxDecoration(
            color: cs.surface.withOpacity(.72),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor.withOpacity(.35)),
            boxShadow: [
              BoxShadow(
                color: cs.tertiary.withOpacity(.12),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: ListView.separated(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            primary: false,
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            itemCount: doubled.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, i) => _VenueChip(name: doubled[i]),
          ),
        ),
      ),
    );
  }
}

class _VenueChip extends StatelessWidget {
  final String name;
  const _VenueChip({required this.name});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final initial = (name.isNotEmpty) ? name.characters.first.toUpperCase() : '?';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant),
        color: cs.surface.withOpacity(.95),
        boxShadow: [
          BoxShadow(color: cs.primary.withOpacity(.08), blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: cs.primary.withOpacity(.15),
            child: Text(
              initial,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: cs.onSurface.withOpacity(.85),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              color: cs.onSurface.withOpacity(.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// --- Spotify Embed Card (güvenli sürüm) --------------------------------------
class _SpotifyEmbedCardSafe extends StatelessWidget {
  const _SpotifyEmbedCardSafe();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Gerçek URL’yi provider’dan oku istiyorsan buraya parametre ekleyip geçir.
    final String? url = null;

    final borderColor =
        Color.lerp(cs.primary, cs.tertiary, .5) ?? cs.outlineVariant;

    return SizedBox(
      height: 86, // sabit yükseklik
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            width: double.infinity,
            height: double.infinity,
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
                // Albüm diski (placeholder)
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
                // Bilgi
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

/// --- Sosyal linkler: ufak neon ghost butonlar -------------------------------
class _SocialMiniRow extends StatelessWidget {
  final String? instagram;
  final String? youtube;
  final String? soundcloud;

  const _SocialMiniRow({
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

/// --- Glassy Section ----------------------------------------------------------
class _GlassSection extends StatelessWidget {
  final String title;
  final Widget child;
  const _GlassSection({required this.title, required this.child});

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
          width: double.infinity, // 👈 genişlik garanti
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
            mainAxisSize: MainAxisSize.min, // 👈 yükseklik içerik kadar
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

/// --- Generic Error View ------------------------------------------------------
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 40, color: cs.error.withOpacity(.9)),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tekrar dene'),
            ),
          ],
        ),
      ),
    );
  }
}
