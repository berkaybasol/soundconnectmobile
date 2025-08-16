import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundconnectmobile/core/storage/secure_storage.dart';
import 'package:soundconnectmobile/features/auth/data/auth_api.dart';
import 'package:soundconnectmobile/features/auth/data/models/login_request.dart';

/// DI: Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final api = ref.read(authApiProvider);
  final storage = ref.read(secureStorageProvider);
  return AuthRepository(api: api, storage: storage);
});

/// Auth veri erişim katmanı.
/// - Network istekleri: AuthApi
/// - Kalıcı token saklama: SecureStorage
class AuthRepository {
  final AuthApi api;
  final SecureStorage storage;

  AuthRepository({required this.api, required this.storage});

  /// Kullanıcı adı/şifre ile giriş.
  /// Başarılı olursa dönen JWT token'ı kalıcı olarak saklar.
  Future<void> login({
    required String username,
    required String password,
  }) async {
    final resp = await api.login(LoginRequest(username: username, password: password));
    await storage.saveToken(resp.token);
  }

  /// Google ile giriş.
  /// [idToken], Google Sign-In paketiyle elde edilen ID token’dır.
  /// Başarılı olursa dönen JWT token'ı kalıcı olarak saklar.
  Future<void> googleSignIn(String idToken) async {
    final resp = await api.googleSignIn(idToken);
    await storage.saveToken(resp.token);
  }

  /// Saklanan JWT'yi oku (ör. splash yönlendirmesi, interceptor, vs.)
  Future<String?> getToken() => storage.getToken();

  /// Çıkış (logout) için token'ı temizle.
  Future<void> clearToken() => storage.clearToken();
}
