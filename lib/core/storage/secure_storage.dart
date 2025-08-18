import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider<SecureStorage>((ref) {
  final storage = const FlutterSecureStorage(); // const güvenli, opsiyonsuz kurulum
  return SecureStorage(storage);
});

class SecureStorage {
  static const _kToken = 'auth_token';
  static const _kPendingRegisterRole = 'pending_register_role';

  final FlutterSecureStorage _storage;
  const SecureStorage(this._storage);

  // --- TOKEN ---
  Future<void> saveToken(String token) => _storage.write(key: _kToken, value: token);
  Future<String?> getToken() => _storage.read(key: _kToken);
  Future<void> clearToken() => _storage.delete(key: _kToken);

  // --- REGISTER: seçilen rolü geçici sakla ---
  Future<void> savePendingRegisterRole(String role) =>
      _storage.write(key: _kPendingRegisterRole, value: role);

  Future<String?> getPendingRegisterRole() =>
      _storage.read(key: _kPendingRegisterRole);

  Future<void> clearPendingRegisterRole() =>
      _storage.delete(key: _kPendingRegisterRole);
}
