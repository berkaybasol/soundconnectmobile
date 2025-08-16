import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:soundconnectmobile/features/auth/presentation/login_page.dart';

final appRouter = GoRouter(
  // Şimdilik login'den başla; bir sonraki adımda token varsa Home'a atacağız.
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const _HomePage(),
    ),
  ],
);

class _HomePage extends StatelessWidget {
  const _HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('SoundConnect Mobile • Home')),
    );
  }
}
