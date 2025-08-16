import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundconnectmobile/core/theme/app_theme.dart';
import 'package:soundconnectmobile/features/auth/presentation/login_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SoundConnect',
      theme: buildLightTheme(),
      home: const LoginPage(),
    );
  }
}
