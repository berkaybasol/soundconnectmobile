import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soundconnectmobile/features/home/presentation/home_gate.dart';
import 'package:soundconnectmobile/features/home/presentation/mainstage/mainstage_home_page.dart';
import 'package:soundconnectmobile/features/home/presentation/backstage/backstage_home_page.dart';
import 'package:soundconnectmobile/features/auth/presentation/login/login_page.dart';

// Profil & Onboarding importları
import 'package:soundconnectmobile/features/profile/musician/presentation/pages/musician_profile_page.dart';
import 'package:soundconnectmobile/features/onboarding/presentation/pages/musician_onboarding_page.dart';

// 🔸 korumalı sayfalar için
import 'package:soundconnectmobile/core/routing/require_auth.dart';

/// =============================
/// 1) APP ROUTER
/// =============================
/// GoRouter = Flutter için Navigator 2.0 tabanlı routing kütüphanesi.
/// Tüm app rotaları burada merkezi olarak tanımlanıyor.
/// Spring’deki `@RequestMapping` gibi düşünebilirsin:
/// path → hangi sayfa (widget) açılacak.
final appRouter = GoRouter(
  // Uygulama açıldığında hangi route açılsın → debug amaçlı backstage’e ayarlanmış
  initialLocation: '/debug-backstage',

  // Route listesi
  routes: [
    // ======================
    // BACKSTAGE (korumalı)
    // ======================
    GoRoute(
      path: '/debug-backstage',
      builder: (context, state) => const RequireAuth(
        child: BackstageHomePage(roles: {'ROLE_MUSICIAN'}),
      ),
    ),

    // Listener debug → şimdilik korumasız
    GoRoute(
      path: '/debug-listener',
      builder: (context, state) => const MainStageHomePage(),
    ),

    // Ortak home gate → rolüne göre MainStage / Backstage yönlendirmesi yapıyor
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeGate(),
    ),

    // ======================
    // AUTH
    // ======================
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),

    // ======================
    // MUSICIAN PROFILE (korumalı)
    // ======================
    GoRoute(
      path: '/backstage/musician/profile',
      builder: (context, state) => const RequireAuth(
        child: MusicianProfilePage(),
      ),
    ),
    GoRoute(
      path: '/backstage/musician/profile/edit',
      builder: (context, state) => const RequireAuth(
        child: MusicianOnboardingPage(), // şimdilik aynı sayfa reuse
      ),
    ),
  ],



  // Eğer route bulunamazsa → fallback error sayfası
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Rota bulunamadı')),
    body: Center(
      child: Text(state.error?.toString() ?? 'Bilinmeyen rota'),
    ),
  ),
);
