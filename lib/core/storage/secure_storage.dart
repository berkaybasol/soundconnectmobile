import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// =============================
/// 1) PROVIDER
/// =============================
/// secureStorageProvider → uygulamanın her yerinde kullanılabilecek
/// bir SecureStorage instance'ı sağlar.
/// FlutterSecureStorage = telefonun kalıcı & güvenli hafızası.
/// (iOS Keychain, Android Keystore kullanır)
final secureStorageProvider = Provider<SecureStorage>((ref) {
  final storage = const FlutterSecureStorage(); // güvenli varsayılan kurulum
  return SecureStorage(storage);
});

/// =============================
/// 2) SECURE STORAGE WRAPPER
/// =============================
/// Bu sınıf, FlutterSecureStorage'i sarmalıyor.
/// Key isimlerini (token, pendingRegisterRole) sabit tutarak
/// tek bir merkezden yönetmeni sağlıyor.
class SecureStorage {
  // Anahtar isimleri sabit → yanlış string yazma riskini ortadan kaldırır
  static const _kToken = 'auth_token';
  static const _kPendingRegisterRole = 'pending_register_role';

  final FlutterSecureStorage _storage;
  const SecureStorage(this._storage);

  // --- TOKEN ---
  Future<void> saveToken(String token) =>
      _storage.write(key: _kToken, value: token);

  Future<String?> getToken() =>
      _storage.read(key: _kToken);

  Future<void> clearToken() =>
      _storage.delete(key: _kToken);

  // --- REGISTER ROLE ---
  /// Kayıt sırasında kullanıcı hangi rolü seçtiyse (ör: ROLE_VENUE, ROLE_MUSICIAN),
  /// bunu geçici olarak saklıyoruz. Doğrulama (OTP) tamamlandığında
  /// backend'e gönderilecek.
  Future<void> savePendingRegisterRole(String role) =>
      _storage.write(key: _kPendingRegisterRole, value: role);

  Future<String?> getPendingRegisterRole() =>
      _storage.read(key: _kPendingRegisterRole);

  Future<void> clearPendingRegisterRole() =>
      _storage.delete(key: _kPendingRegisterRole);
}
