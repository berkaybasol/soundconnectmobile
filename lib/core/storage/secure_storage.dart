import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _kTokenKey = 'auth_token';

final secureStorageProvider = Provider<SecureStorage>((ref) {
  return SecureStorage();
});

class SecureStorage {
  // Android'de EncryptedSharedPreferences kullan
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    mOptions: MacOsOptions(accessibility: KeychainAccessibility.first_unlock),
    wOptions: WindowsOptions(), // default ok
    lOptions: LinuxOptions(),   // default ok
    webOptions: WebOptions(),   // web'de no-op
  );

  Future<void> saveToken(String token) async {
    await _storage.write(key: _kTokenKey, value: token);
  }

  Future<String?> getToken() async {
    return _storage.read(key: _kTokenKey);
  }

  Future<void> clearToken() async {
    await _storage.delete(key: _kTokenKey);
  }
}
