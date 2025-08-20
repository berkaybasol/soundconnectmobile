// lib/features/home/home_shell.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// RAM’deki token
import 'package:soundconnectmobile/core/network/dio_client.dart';

/// ------------------------------------------------------------
/// HomeGate: JWT -> MainStage (listener) / Backstage (actor)
/// ------------------------------------------------------------
class HomeGate extends ConsumerWidget {
  const HomeGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(authTokenProvider);
    final roles = _rolesFromJwt(token);

    final isListener = roles.contains('ROLE_LISTENER');
    return isListener ? const MainStageHomePage() : BackstageHomePage(roles: roles);
  }

  Set<String> _rolesFromJwt(String? token) {
    try {
      if (token == null || token.isEmpty) return {};
      final parts = token.split('.');
      if (parts.length < 2) return {};
      final payload = _decodeBase64(parts[1]);
      final map = jsonDecode(payload) as Map<String, dynamic>;
      final raw = map['roles'];
      if (raw is List) return raw.map((e) => e.toString()).toSet();
      return {};
    } catch (_) {
      return {};
    }
  }

  String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');
    switch (output.length % 4) {
      case 0: break;
      case 2: output += '=='; break;
      case 3: output += '='; break;
      default: break;
    }
    return utf8.decode(base64.decode(output));
  }
}

/// ------------------------------------------------------------
/// MainStage (Listener) — örnek scroll içerik
/// ------------------------------------------------------------
class MainStageHomePage extends StatelessWidget {
  const MainStageHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final pal = _NeutralPalette.of(context);
    return Scaffold(
      appBar: SCAppBar(
        centerChild: const _TopSearchField(),
        rightActions: const [
          _IconAction(icon: Icons.grid_view_rounded, tooltip: 'Menü'),
          _IconAction(icon: Icons.notifications_none_rounded, tooltip: 'Bildirimler'),
          _LogoAmblem(),
        ],
      ),
      body: _ContentArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('MainStage — Dinleyici akışı burada',
                style: TextStyle(color: pal.on)),
            const SizedBox(height: 800),
            Text('Scroll örneği bitti', style: TextStyle(color: pal.onMuted)),
          ],
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// Backstage (Actor’lar: musician/organizer/producer/studio/venue)
/// ------------------------------------------------------------
class BackstageHomePage extends StatelessWidget {
  final Set<String> roles;
  const BackstageHomePage({super.key, required this.roles});

  bool get isMusician => roles.contains('ROLE_MUSICIAN');

  @override
  Widget build(BuildContext context) {
    if (roles.length == 1 && roles.contains('ROLE_LISTENER')) {
      return const MainStageHomePage();
    }

    final pal = _NeutralPalette.of(context);

    return Scaffold(
      appBar: SCAppBar(
        centerChild: const _TopSearchField(),
        rightActions: const [
          _SecondHandAction(), // gavel_outlined
          _IconAction(icon: Icons.notifications_none_rounded, tooltip: 'Bildirimler'),
          _LogoMenuAction(), // logoya tıklayınca menü
        ],
      ),
      body: _ContentArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isMusician
                  ? 'Backstage — LOADING..'
                  : 'Backstage — Aktör ana görünüm',
              style: TextStyle(color: pal.on),
            ),
            const SizedBox(height: 800),
            Text('LOADING..', style: TextStyle(color: pal.onMuted)),
          ],
        ),
      ),
      bottomNavigationBar: const _BackstageBottomBar(),
    );
  }
}

/// ------------------------------------------------------------
/// Ortak AppBar — IG tarzı soft edge:
///  - Zemin içerikle aynı (surface)
///  - Alt kenarda 12px beyaz→şeffaf fade (yükseklik artmadan)
///  - Scroll’da hafif gölge
/// ------------------------------------------------------------
class SCAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? centerChild;
  final List<Widget> rightActions;

  const SCAppBar({
    super.key,
    this.centerChild,
    this.rightActions = const [],
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final pal = _NeutralPalette.of(context);
    return AppBar(
      backgroundColor: pal.surface,
      surfaceTintColor: Colors.transparent,
      foregroundColor: pal.on,
      elevation: 0,
      scrolledUnderElevation: 2,
      shadowColor: Colors.black.withOpacity(.14),
      toolbarHeight: 64,
      titleSpacing: 12,
      title: Row(
        children: [
          const SizedBox(width: 4),
          if (centerChild != null) Expanded(child: centerChild!) else const Spacer(),
          const SizedBox(width: 12),
          ...rightActions.map((w) => Padding(
            padding: const EdgeInsets.only(left: 4),
            child: w,
          )),
        ],
      ),
      // ↓↓↓ Yüksekliği artırmadan alt kenara soft fade bindiriyoruz
      flexibleSpace: IgnorePointer(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            height: 12,
            child: _SoftEdge.fadeDown(baseOnTheme: true),
          ),
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// İçerik alanı (negatif boşluk + scroll)
///  - Üstte/Altta 12px boşluk
///  - Zemin: surface (barlarla aynı)
/// ------------------------------------------------------------
class _ContentArea extends StatelessWidget {
  final Widget child;
  const _ContentArea({required this.child});

  @override
  Widget build(BuildContext context) {
    final pal = _NeutralPalette.of(context);
    return Container(
      color: pal.surface,
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(child: child),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          // ↓↓↓ IG-style: altta yumuşak ayrım
          SliverToBoxAdapter(
            child: SizedBox(
              height: 12,
              child: _SoftEdge.fadeUp(baseOnTheme: true),
            ),
          ),
        ],
      ),
    );
  }
}

/// ------------------------------------------------------------
/// Arama alanı — arkaplan logo turuncusu (şeffaf)
/// ------------------------------------------------------------
class _TopSearchField extends StatelessWidget {
  const _TopSearchField();

  static const _logoOrange = Color(0xFFF48371);

  @override
  Widget build(BuildContext context) {
    final pal = _NeutralPalette.of(context);
    return SizedBox(
      height: 40,
      child: TextField(
        style: TextStyle(color: pal.on),
        cursorColor: _logoOrange,
        decoration: InputDecoration(
          hintText: 'Ara: kullanıcı, etkinlik, parça…',
          hintStyle: TextStyle(color: pal.onMuted),
          prefixIcon: Icon(Icons.search, color: pal.on.withOpacity(.75)),
          filled: true,
          fillColor: _logoOrange.withOpacity(.0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: pal.outline, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _logoOrange, width: 1.8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        ),
      ),
    );
  }
}

class _LogoAmblem extends StatelessWidget {
  const _LogoAmblem();

  @override
  Widget build(BuildContext context) {
    final pal = _NeutralPalette.of(context);
    return Image.asset(
      'assets/images/sadece_amblem.png',
      width: 28,
      height: 28,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Icon(Icons.music_note, color: pal.on),
    );
  }
}

/// Sağ üst amblem + menü — özel gölge rengi
class _LogoMenuAction extends StatelessWidget {
  const _LogoMenuAction();

  static const _shadow = Color(0xFFF48371); // E1718DFF

  @override
  Widget build(BuildContext context) {
    final pal = _NeutralPalette.of(context);
    final themed = Theme.of(context).copyWith(
      popupMenuTheme: PopupMenuThemeData(
        color: pal.surface,
        surfaceTintColor: pal.surface,
        elevation: 8,
        shadowColor: _shadow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    return Theme(
      data: themed,
      child: PopupMenuButton<int>(
        tooltip: 'Menü',
        position: PopupMenuPosition.under,
        itemBuilder: (ctx) => [
          _menuItem(1, Icons.person_outline, 'Profilim', pal),
          _menuItem(2, Icons.settings_outlined, 'Ayarlar', pal),
          _menuItem(3, Icons.help_outline_rounded, 'Yardım', pal),
          _menuItem(4, Icons.logout_rounded, 'Çıkış', pal),
        ],
        onSelected: (v) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Seçildi: $v (TODO)')),
          );
        },
        child: const _LogoAmblem(),
      ),
    );
  }

  PopupMenuItem<int> _menuItem(
      int value, IconData icon, String title, _NeutralPalette pal) {
    return PopupMenuItem<int>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: pal.on),
          const SizedBox(width: 10),
          Text(title, style: TextStyle(color: pal.on)),
        ],
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  const _IconAction({required this.icon, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    final pal = _NeutralPalette.of(context);
    return IconButton(
      tooltip: tooltip,
      icon: Icon(icon, color: pal.on),
      onPressed: () => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$tooltip (TODO)'))),
    );
  }
}

class _SecondHandAction extends StatelessWidget {
  const _SecondHandAction();

  @override
  Widget build(BuildContext context) {
    final pal = _NeutralPalette.of(context);
    return IconButton(
      tooltip: 'İkinci El Satış',
      icon: Icon(Icons.gavel_outlined, color: pal.on, size: 22),
      visualDensity: VisualDensity.compact,
      onPressed: () => ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('İkinci El Satış (TODO)'))),
    );
  }
}

/// ------------------------------------------------------------
/// Backstage Bottom Bar — IG soft edge (üstte fade, yükseklik sabit)
/// ------------------------------------------------------------
class _BackstageBottomBar extends StatelessWidget {
  const _BackstageBottomBar();

  @override
  Widget build(BuildContext context) {
    final pal = _NeutralPalette.of(context);
    return BottomAppBar(
      color: pal.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      child: SizedBox(
        height: 66,
        child: Stack(
          children: [
            // ↑↑↑ Üst kenarda 12px fade (yükseklik artırmadan)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 12,
              child: _SoftEdge.fadeDown(baseOnTheme: true),
            ),
            // Asıl içerik
            Row(
              children: const [
                _BottomIconButton(
                  icon: Icons.post_add_rounded,
                  label: 'İlan',
                  onTapMessage: 'İlan (TODO)',
                ),
                Expanded(child: Center(child: _MainStageAnchorButton())),
                _BottomIconButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'Mesajlar',
                  onTapMessage: 'Mesajlar (TODO)',
                ),
                _BottomIconButton(
                  icon: Icons.person_outline_rounded,
                  label: 'Profil',
                  onTapMessage: 'Profil (TODO)',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Orta MainStage düğmesi — menü tam üzerinde + özel gölge
class _MainStageAnchorButton extends StatelessWidget {
  const _MainStageAnchorButton();

  static const _shadow = Color(0xFFF48371);
  static const double _menuYOffset = -220;

  @override
  Widget build(BuildContext context) {
    final pal = _NeutralPalette.of(context);
    final themed = Theme.of(context).copyWith(
      popupMenuTheme: PopupMenuThemeData(
        color: pal.surface,
        surfaceTintColor: pal.surface,
        elevation: 8,
        shadowColor: _shadow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

    return Theme(
      data: themed,
      child: PopupMenuButton<int>(
        tooltip: 'MainStage',
        position: PopupMenuPosition.over,
        offset: const Offset(0, _menuYOffset),
        itemBuilder: (ctx) => [
          _menuItem(1, Icons.psychology_alt_outlined, 'Overthinking', pal),
          _menuItem(2, Icons.local_fire_department_outlined, 'Trending Sets', pal),
          _menuItem(3, Icons.location_city_outlined, 'City Vibes', pal),
        ],
        onSelected: (v) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Seçildi: $v (TODO)')),
          );
        },
        child: SizedBox(
          width: 92,
          height: 66,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.rocket_launch_outlined, color: pal.on),
              const SizedBox(height: 4),
              Text('Git',
                  style: TextStyle(
                    color: pal.onMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<int> _menuItem(
      int value, IconData icon, String title, _NeutralPalette pal) {
    return PopupMenuItem<int>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: pal.on),
          const SizedBox(width: 10),
          Text(title, style: TextStyle(color: pal.on)),
        ],
      ),
    );
  }
}

class _BottomIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String onTapMessage;
  const _BottomIconButton({
    required this.icon,
    required this.label,
    required this.onTapMessage,
  });

  @override
  Widget build(BuildContext context) {
    final pal = _NeutralPalette.of(context);
    return InkWell(
      onTap: () => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(onTapMessage))),
      splashColor: pal.on.withOpacity(.08),
      highlightColor: pal.on.withOpacity(.06),
      child: SizedBox(
        width: 92,
        height: 66,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: pal.on),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: pal.onMuted, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// Soft edge helper (white/black -> transparent)
/// ------------------------------------------------------------
class _SoftEdge extends StatelessWidget {
  final bool baseOnTheme; // true: light=white, dark=black
  final double opacity;   // 0..1
  final bool up;          // true: içerikten bara doğru (aşağıdan yukarıya şeffaflıktan dolu renge)
  const _SoftEdge({
    this.baseOnTheme = true,
    this.opacity = 1,
    this.up = false,
  });

  factory _SoftEdge.fadeDown({bool baseOnTheme = true, double opacity = 1}) =>
      _SoftEdge(baseOnTheme: baseOnTheme, opacity: opacity, up: false);

  factory _SoftEdge.fadeUp({bool baseOnTheme = true, double opacity = 1}) =>
      _SoftEdge(baseOnTheme: baseOnTheme, opacity: opacity, up: true);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = baseOnTheme
        ? (isDark ? Colors.black : Colors.white)
        : Colors.white;

    // up=false: üstten alta doğru doludan şeffafa (AppBar altı için)
    // up=true : üstte şeffaf, altta dolu (BottomBar öncesi içerik altı için)
    final colors = up
        ? [base.withOpacity(0.00 * opacity), base.withOpacity(0.90 * opacity)]
        : [base.withOpacity(0.90 * opacity), base.withOpacity(0.00 * opacity)];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// Nötr renk paleti (IG’e yakın; bar & içerik aynı zemin)
// ------------------------------------------------------------
class _NeutralPalette {
  final Color on;            // metin/ikon
  final Color onMuted;       // ikincil metin
  final Color outline;       // çerçeve
  final Color surface;       // içerik ve bar zemini

  _NeutralPalette({
    required this.on,
    required this.onMuted,
    required this.outline,
    required this.surface,
  });

  factory _NeutralPalette.of(BuildContext context) {
    final t = Theme.of(context).colorScheme;
    return _NeutralPalette(
      on: Colors.black87,
      onMuted: Colors.black54,
      outline: Colors.black26,
      surface: t.surface, // içerik ve bar aynı
    );
  }
}
