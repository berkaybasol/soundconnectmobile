// lib/features/auth/presentation/register_controller.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  return RegisterController(ref);
});

class RegisterController extends StateNotifier<RegisterState> {
  final Ref _ref;
  RegisterController(this._ref) : super(const RegisterState());

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
      final repo = _ref.read(authRepositoryProvider);
      final res = await repo.register(
        username: username,
        email: email,
        password: password,
        rePassword: rePassword,
        role: role,
      );

      // Seçilen rolü geçici sakla (verify sonrası yönlendirme için)
      await _ref.read(secureStorageProvider).savePendingRegisterRole(role);

      state = state.copyWith(loading: false);
      return RegisterOutcome(
        email: (res['email'] as String?) ?? email,
        otpTtlSeconds: (res['otpTtlSeconds'] as int?) ?? 0,
        mailQueued: res['mailQueued'] == true,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: _humanize(e));
      return null;
    }
  }

  String _humanize(Object e) {
    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return 'Bağlantı zaman aşımına uğradı';
        case DioExceptionType.badResponse:
          final msg = e.error?.toString();
          return (msg != null && msg.isNotEmpty) ? msg : 'İstek başarısız';
        case DioExceptionType.cancel:
          return 'İstek iptal edildi';
        case DioExceptionType.unknown:
        default:
          return 'Ağ hatası';
      }
    }
    return e.toString();
  }
}
