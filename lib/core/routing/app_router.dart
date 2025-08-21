// lib/core/routing/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soundconnectmobile/features/home/presentation/home_gate.dart';
import 'package:soundconnectmobile/features/home/presentation/mainstage/mainstage_home_page.dart';
import 'package:soundconnectmobile/features/home/presentation/backstage/backstage_home_page.dart';

import 'package:soundconnectmobile/features/profile/musician_profile_page.dart';


final appRouter = GoRouter(
  // Debug için direkt açılacak sayfa:
  // → Müzisyen Backstage’i görmek için: '/debug-musician'
  // → Dinleyici MainStage’i görmek için: '/debug-listener'
  // → Gerçek akış için (token/role ile): '/home'
  initialLocation: '/debug-musician-profile',

  routes: [
    // Müzisyen (Backstage)
    GoRoute(
      path: '/debug-backstage',
      builder: (context, state) => BackstageHomePage(roles: {'ROLE_MUSICIAN' }), // diger roller eklencek
    ),

    GoRoute(
      // muzisyen profile page
      path: '/debug-musician-profile',
      builder: (context, state) => const MusicianProfilePage(),
    ),


    // Dinleyici (MainStage)
    GoRoute(
      path: '/debug-listener',
      builder: (context, state) => const MainStageHomePage(),
    ),

    // Kapı: JWT role'lerine göre MainStage/Backstage seçer
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeGate(),
    ),
  ],

  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Rota bulunamadı')),
    body: Center(child: Text(state.error?.toString() ?? 'Bilinmeyen rota')),
  ),
);
