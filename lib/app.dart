import 'package:flutter/material.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

class SoundConnectApp extends StatelessWidget {
  const SoundConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: buildLightTheme(),
      routerConfig: appRouter,
    );
  }
}
