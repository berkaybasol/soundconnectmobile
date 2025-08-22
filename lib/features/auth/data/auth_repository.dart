// lib/features/auth/data/auth_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:soundconnectmobile/core/network/dio_client.dart'; // authTokenProvider
import 'package:soundconnectmobile/core/storage/secure_storage.dart';
import 'package:soundconnectmobile/features/auth/data/auth_api.dart';
import 'package:soundconnectmobile/features/auth/data/models/requests/login_request.dart';
import 'package:soundconnectmobile/features/auth/data/models/requests/register_request.dart';

/// =============================
/// 1) PROVIDER
/// =============================
/// Dependency Injection için Riverpod Provider.
/// AuthApi + SecureStorage enjekte edilerek AuthRepository oluşturulur.
/// Spring’de @Service bean’ini oluşturmak gibi düşünebilirsin.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final api = ref.read(authApiProvider);
  final storage = ref.read(secureStorageProvider);
  return AuthRepository(ref: ref, api: api, storage: storage);
});

/// =============================
/// 2) REPOSITORY CLASS
/// =============================
/// Bu sınıf, AuthApi ile UI/controller arasındaki köprü.
/// - API çağrılarını yapar (AuthApi)
/// - Token’ı hem SecureStorage’a (kalıcı) hem RAM’e (authTokenProvider) yazar.
/// Spring’de Service katmanına çok benzer.
class AuthRepository {
  final Ref ref;
  final AuthApi api;
  final SecureStorage storage;

  AuthRepository({
    required this.ref,
    required this.api,
    required this.storage,
  });

  /// =============================
  /// App açılışında storage’taki token’ı RAM’e yükle
  /// =============================
  /// Böylece BearerInterceptor header’a ekleyebilir.
  Future<void> hydrateTokenFromStorage() async {
    final token = await storage.getToken();
    ref.read(authTokenProvider.notifier).state = token;
  }

  /// =============================
  /// LOGIN
  /// =============================
  /// Kullanıcı adı/şifre ile giriş → token’ı storage + RAM’e yazar.
  Future<void> login({
    required String username,
    required String password,
  }) async {
    final resp = await api.login(LoginRequest(username: username, password: password));
    await storage.saveToken(resp.token); // kalıcı
    ref.read(authTokenProvider.notifier).state = resp.token; // RAM
  }

  /// Google Sign-In login
  Future<void> loginWithGoogle({required String idToken}) async {
    final resp = await api.googleSignIn(idToken);
    await storage.saveToken(resp.token);
    ref.read(authTokenProvider.notifier).state = resp.token;
  }

  /// =============================
  /// REGISTER
  /// =============================
  /// Kayıt sonrası backend OTP TTL ve mailQueued gibi ek bilgiler döner.
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

  /// =============================
  /// Oturum yardımcıları
  /// =============================
  Future<String?> getToken() => storage.getToken();

  Future<void> logout() async {
    await storage.clearToken(); // kalıcı token sil
    ref.read(authTokenProvider.notifier).state = null; // RAM temizle
  }
}
