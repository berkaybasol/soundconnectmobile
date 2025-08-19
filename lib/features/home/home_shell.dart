// lib/features/home/home_shell.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// RAM’deki token’ı okuyacağız
import 'package:soundconnectmobile/core/network/dio_client.dart';

/// ------------------------------------------------------------
/// HomeGate: JWT'den role'leri çözüp doğru ana sayfaya indirir.
/// ------------------------------------------------------------
class HomeGate extends ConsumerWidget {
  const HomeGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final token = ref.watch(authTokenProvider);
    final roles = _rolesFromJwt(token);

    final isListener = roles.contains('ROLE_LISTENER');
    if (isListener) {
      return const MainStageHomePage(); // dinleyici
    } else {
      return BackstageHomePage(roles: roles); // aktör
    }
  }

  /// JWT payload decode (paketsiz) → roles listesi
  Set<String> _rolesFromJwt(String? token) {
    try {
      if (token == null || token.isEmpty) return {};
      final parts = token.split('.');
      if (parts.length < 2) return {};
      final payload = _decodeBase64(parts[1]);
      final map = jsonDecode(payload) as Map<String, dynamic>;
      final raw = map['roles'];
      if (raw is List) {
        return raw.map((e) => e.toString()).toSet();
      }
      return {};
    } catch (_) {
      return {};
    }
  }

  String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');
    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
      // invalid base64
        break;
    }
    return utf8.decode(base64.decode(output));
  }
}

/// ------------------------------------------------------------
/// MainStage (dinleyici ana sayfası) — sade placeholder
/// ------------------------------------------------------------
class MainStageHomePage extends StatelessWidget {
  const MainStageHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SCAppBar(
        title: 'MainStage',
        actions: const [
          // Dinleyicide minimal aksiyonlar
          _IconAction(icon: Icons.search_rounded, tooltip: 'Ara'),
          _IconAction(icon: Icons.notifications_none_rounded, tooltip: 'Bildirimler'),
        ],
      ),
      body: const Center(
        child: Text('MainStage — Dinleyici akışı burada'),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// Backstage (aktör ana sayfası) + Musician toolbar varyasyonu
/// ------------------------------------------------------------
class BackstageHomePage extends StatelessWidget {
  final Set<String> roles;
  const BackstageHomePage({super.key, required this.roles});

  bool get isMusician => roles.contains('ROLE_MUSICIAN');

  @override
  Widget build(BuildContext context) {
    // Dinleyici buraya düşerse engelle ve MainStage'e yolla (güvenlik ağı)
    if (roles.contains('ROLE_LISTENER') && !isMusician) {
      // asla olmamalı; ekstra güvenlik
      return const MainStageHomePage();
    }

    // Ortak AppBar şablonu + müzisyene özel aksiyonlar
    final actions = <Widget>[
      // Aktörler için "MainStage'e geç" butonu
      TextButton.icon(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MainStageHomePage()),
          );
        },
        icon: const Icon(Icons.theaters_rounded),
        label: const Text('MainStage'),
      ),
      ..._musicianActionsIfNeeded(isMusician),
    ];

    return Scaffold(
      appBar: SCAppBar(
        title: 'Backstage',
        actions: actions,
      ),
      body: Center(
        child: Text(
          isMusician
              ? 'Backstage — Musician ana görünüm'
              : 'Backstage — Aktör ana görünüm',
        ),
      ),
      // İstersek alt sekmeler: Feed / Keşfet / Mesajlar / Profil
      bottomNavigationBar: const _BottomTabs(),
    );
  }

  List<Widget> _musicianActionsIfNeeded(bool isMusician) {
    if (!isMusician) return const [
      _IconAction(icon: Icons.notifications_none_rounded, tooltip: 'Bildirimler'),
      _ProfileMenu(),
    ];

    // Musician varyasyonu (Instagram/LinkedIn hissi)
    return const [
      _IconAction(icon: Icons.notifications_none_rounded, tooltip: 'Bildirimler'),
      _IconAction(icon: Icons.library_music_outlined, tooltip: 'İçerik oluştur'),
      _ProfileMenu(),
    ];
  }
}

/// ------------------------------------------------------------
/// Ortak AppBar şablonu (SCAppBar)
/// ------------------------------------------------------------
class SCAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> actions;

  const SCAppBar({
    super.key,
    required this.title,
    this.actions = const [],
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AppBar(
      title: Text(title),
      centerTitle: true,
      backgroundColor: cs.surface,
      foregroundColor: cs.onSurface,
      elevation: 0,
      actions: actions,
    );
  }
}

/// Basit ikon aksiyonu (şimdilik SnackBar atar)
class _IconAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  const _IconAction({required this.icon, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      icon: Icon(icon),
      onPressed: () {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$tooltip (TODO)')));
      },
    );
  }
}

/// Profil menüsü (şimdilik dummy)
class _ProfileMenu extends StatelessWidget {
  const _ProfileMenu();

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      tooltip: 'Profil',
      itemBuilder: (ctx) => const [
        PopupMenuItem(value: 1, child: Text('Profilim')),
        PopupMenuItem(value: 2, child: Text('Ayarlar')),
        PopupMenuItem(value: 3, child: Text('Çıkış')),
      ],
      onSelected: (v) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Seçildi: $v (TODO)')),
        );
      },
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: CircleAvatar(radius: 14, child: Icon(Icons.person, size: 18)),
      ),
    );
  }
}

/// Alt sekme iskeleti (rol bağımsız örnek)
class _BottomTabs extends StatefulWidget {
  const _BottomTabs();

  @override
  State<_BottomTabs> createState() => _BottomTabsState();
}

class _BottomTabsState extends State<_BottomTabs> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return NavigationBar(
      selectedIndex: _index,
      onDestinationSelected: (i) => setState(() => _index = i),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Akış'),
        NavigationDestination(icon: Icon(Icons.explore_outlined), label: 'Keşfet'),
        NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Mesajlar'),
        NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil'),
      ],
      indicatorColor: cs.primary.withOpacity(.12), // pembe odak
    );
  }
}
