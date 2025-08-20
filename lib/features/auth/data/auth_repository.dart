// lib/features/auth/data/auth_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:soundconnectmobile/core/network/dio_client.dart'; // authTokenProvider
import 'package:soundconnectmobile/core/storage/secure_storage.dart';
import 'package:soundconnectmobile/features/auth/data/auth_api.dart';
import 'package:soundconnectmobile/features/auth/data/models/requests/login_request.dart';
import 'package:soundconnectmobile/features/auth/data/models/requests/register_request.dart';

/// DI
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final api = ref.read(authApiProvider);
  final storage = ref.read(secureStorageProvider);
  return AuthRepository(ref: ref, api: api, storage: storage);
});

class AuthRepository {
  final Ref ref;
  final AuthApi api;
  final SecureStorage storage;

  AuthRepository({
    required this.ref,
    required this.api,
    required this.storage,
  });

  /// App açılışında storage’taki token’ı RAM’e yükle (BearerInterceptor için).
  Future<void> hydrateTokenFromStorage() async {
    final token = await storage.getToken();
    ref.read(authTokenProvider.notifier).state = token;
  }

  /// Kullanıcı adı/şifre ile giriş → token kalıcı + RAM
  Future<void> login({required String username, required String password}) async {
    final resp = await api.login(LoginRequest(username: username, password: password));
    await storage.saveToken(resp.token);
    ref.read(authTokenProvider.notifier).state = resp.token;
  }

  /// (Opsiyonel) Google Sign-In
  Future<void> loginWithGoogle({required String idToken}) async {
    final resp = await api.googleSignIn(idToken);
    await storage.saveToken(resp.token);
    ref.read(authTokenProvider.notifier).state = resp.token;
  }

  /// Kayıt → OTP TTL & mailQueued dönüş bilgisi UI’ya gider
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String rePassword,
    required String role,
  }) async {
    final req = RegisterRequest(
      username: username,
      email: email,
      password: password,
      rePassword: rePassword,
      role: role,
    );
    return api.register(req);
  }

  /// OTP doğrulama
  Future<bool> verifyCode({required String email, required String code}) {
    return api.verifyCode(email: email, code: code);
  }

  /// OTP yeniden gönder (cooldown bilgisiyle)
  Future<Map<String, dynamic>> resendCode({required String email}) {
    return api.resendCode(email: email);
  }

  /// Oturum yardımcıları
  Future<String?> getToken() => storage.getToken();

  Future<void> logout() async {
    await storage.clearToken();
    ref.read(authTokenProvider.notifier).state = null;
  }
}
