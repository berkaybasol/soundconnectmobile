// lib/core/routing/require_auth.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:soundconnectmobile/core/storage/secure_storage.dart';
import 'package:soundconnectmobile/core/network/dio_client.dart';

/// =============================
/// 1) REQUIRE AUTH WIDGET
/// =============================
/// Bu widget, içine verdiğin sayfayı (`child`) sadece giriş yapmış
/// kullanıcı görebilsin diye bir **koruma katmanı**.
/// Eğer token yoksa otomatik `/login` sayfasına yönlendiriyor.
/// (Spring’de `@PreAuthorize` veya Filter mantığı gibi)
class RequireAuth extends ConsumerStatefulWidget {
  final Widget child;       // korunacak widget
  final String loginPath;   // login ekranının path’i

  const RequireAuth({
    super.key,
    required this.child,
    this.loginPath = '/login',
  });

  @override
  ConsumerState<RequireAuth> createState() => _RequireAuthState();
}

/// =============================
/// 2) STATE
/// =============================
/// Burada token kontrolü yapılıyor:
/// - RAM’de var mı?
/// - Yoksa secure storage’dan oku
/// - Hâlâ yoksa → login sayfasına at
/// - Varsa → child’ı göster
class _RequireAuthState extends ConsumerState<RequireAuth> {
  bool _checked = false; // kontrol tamamlandı mı?

  @override
  void initState() {
    super.initState();
    _ensureAuth(); // component mount olur olmaz token kontrolünü yap
  }

  Future<void> _ensureAuth() async {
    // 1) RAM’de token var mı?
    var token = ref.read(authTokenProvider);

    if (token == null || token.isEmpty) {
      // 2) Yoksa secure storage’tan oku (telefonun kalıcı hafızası)
      final storage = ref.read(secureStorageProvider);
      token = await storage.getToken();

      // Token bulunduysa RAM’e yaz (authTokenProvider)
      if (token != null && token.isNotEmpty) {
        ref.read(authTokenProvider.notifier).state = token;
      }
    }

    if (!mounted) return;

    // 3) Hâlâ token yoksa → login sayfasına yönlendir
    if (token == null || token.isEmpty) {
      context.go(widget.loginPath);
    } else {
      // Token bulundu, artık child’ı gösterebiliriz
      setState(() => _checked = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_checked) {
      // Token kontrolü bitmeden loading spinner göster
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    // Kontrol bitti, token varsa → child sayfayı göster
    return widget.child;
  }
}
