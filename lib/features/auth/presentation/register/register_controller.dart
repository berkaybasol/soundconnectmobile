// lib/features/auth/presentation/register_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:soundconnectmobile/core/error/ui_error_mapper.dart';
import 'package:soundconnectmobile/core/storage/secure_storage.dart';
import 'package:soundconnectmobile/features/auth/data/auth_repository.dart';

class RegisterOutcome {
  final String email;
  final int otpTtlSeconds;
  final bool mailQueued;
  const RegisterOutcome({
    required this.email,
    required this.otpTtlSeconds,
    required this.mailQueued,
  });
}

class RegisterState {
  final bool loading;
  final String? error;

  const RegisterState({this.loading = false, this.error});

  RegisterState copyWith({bool? loading, String? error}) =>
      RegisterState(loading: loading ?? this.loading, error: error);
}

final registerControllerProvider =
StateNotifierProvider<RegisterController, RegisterState>((ref) {
  final repo = ref.read(authRepositoryProvider);
  final storage = ref.read(secureStorageProvider);
  return RegisterController(repo: repo, storage: storage);
});

class RegisterController extends StateNotifier<RegisterState> {
  final AuthRepository _repo;
  final SecureStorage _storage;

  RegisterController({required AuthRepository repo, required SecureStorage storage})
      : _repo = repo,
        _storage = storage,
        super(const RegisterState());

  void clearError() => state = state.copyWith(error: null);

  /// Başarılı olursa RegisterOutcome döner (email + otpTtlSeconds + mailQueued).
  /// Hata olursa null döner ve [state.error] dolar.
  Future<RegisterOutcome?> register({
    required String username,
    required String email,
    required String password,
    required String rePassword,
    required String role,
  }) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final res = await _repo.register(
        username: username,
        email: email,
        password: password,
        rePassword: rePassword,
        role: role,
      );

      // Seçilen rolü geçici sakla (verify sonrası yönlendirme için)
      await _storage.savePendingRegisterRole(role);

      state = state.copyWith(loading: false);
      return RegisterOutcome(
        email: (res['email'] as String?) ?? email,
        otpTtlSeconds: (res['otpTtlSeconds'] as int?) ?? 0,
        mailQueued: res['mailQueued'] == true,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: UiErrorMapper.humanize(e));
      return null;
    }
  }
}
