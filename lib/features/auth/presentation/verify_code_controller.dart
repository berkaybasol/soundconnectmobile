// lib/features/auth/presentation/verify_code_controller.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:soundconnectmobile/features/auth/data/auth_api.dart';

class VerifyCodeState {
  final bool verifying;
  final bool resending;
  final bool verified;
  final String? error;
  final String? message;
  final int otpTtlSeconds;     // kalan OTP süresi
  final int cooldownSeconds;   // yeniden gönderim bekleme süresi

  const VerifyCodeState({
    this.verifying = false,
    this.resending = false,
    this.verified = false,
    this.error,
    this.message,
    this.otpTtlSeconds = 0,
    this.cooldownSeconds = 0,
  });

  VerifyCodeState copyWith({
    bool? verifying,
    bool? resending,
    bool? verified,
    String? error,
    String? message,
    int? otpTtlSeconds,
    int? cooldownSeconds,
  }) {
    return VerifyCodeState(
      verifying: verifying ?? this.verifying,
      resending: resending ?? this.resending,
      verified: verified ?? this.verified,
      error: error,
      message: message,
      otpTtlSeconds: otpTtlSeconds ?? this.otpTtlSeconds,
      cooldownSeconds: cooldownSeconds ?? this.cooldownSeconds,
    );
  }
}

// autoDispose: sayfadan çıkınca state sıfırlansın (eski true kalmasın)
final verifyCodeControllerProvider =
StateNotifierProvider.autoDispose<VerifyCodeController, VerifyCodeState>((ref) {
  final api = ref.read(authApiProvider);
  return VerifyCodeController(api);
});

class VerifyCodeController extends StateNotifier<VerifyCodeState> {
  final AuthApi _api;
  Timer? _ttlTimer;
  Timer? _cooldownTimer;

  VerifyCodeController(this._api) : super(const VerifyCodeState());

  /// İstersen sayfa açılışında state’i temizlemek için çağır.
  void reset() {
    _stopTimers();
    state = const VerifyCodeState();
  }

  void seedFromRegister({required int otpTtlSeconds}) {
    // Her yeni ekranda verified kesinlikle false olsun
    state = state.copyWith(verified: false, error: null, message: null);
    _startTtl(otpTtlSeconds);
  }

  Future<void> verify({required String email, required String code}) async {
    // Yeni denemeye başlarken verified=false'a çek
    state = state.copyWith(
      verifying: true,
      verified: false,
      error: null,
      message: null,
    );
    try {
      final ok = await _api.verifyCode(email: email, code: code);
      if (ok) {
        _stopTimers();
        state = state.copyWith(verifying: false, verified: true);
      } else {
        // teoride buraya düşmez (API success=false ise exception atıyoruz)
        state = state.copyWith(
          verifying: false,
          verified: false,
          error: 'Doğrulama başarısız',
        );
      }
    } catch (e) {
      state = state.copyWith(
        verifying: false,
        verified: false, // <-- kritik fix
        error: _humanize(e),
      );
    }
  }

  Future<void> resend({required String email}) async {
    state = state.copyWith(resending: true, error: null, message: null, verified: false);
    try {
      final body = await _api.resendCode(email: email);
      // body: success, code, message, otpTtlSeconds, mailQueued, cooldownSeconds
      final success = body['success'] == true;
      final msg = body['message']?.toString();

      final ttl = (body['otpTtlSeconds'] as int?) ?? 0;
      final cooldown = (body['cooldownSeconds'] as int?) ?? 0;

      if (ttl > 0) _startTtl(ttl);
      if (cooldown > 0) _startCooldown(cooldown);

      if (success) {
        state = state.copyWith(
          resending: false,
          verified: false,
          message: msg ?? 'Yeni kod gönderildi',
          error: null,
        );
      } else {
        state = state.copyWith(
          resending: false,
          verified: false,
          error: msg ?? 'İstek kısıtlandı, biraz sonra tekrar deneyin',
        );
      }
    } catch (e) {
      state = state.copyWith(
        resending: false,
        verified: false,
        error: _humanize(e),
      );
    }
  }

  // --- Timers ---

  void _startTtl(int seconds) {
    _ttlTimer?.cancel();
    state = state.copyWith(otpTtlSeconds: seconds);
    _ttlTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      final left = state.otpTtlSeconds - 1;
      if (left <= 0) {
        t.cancel();
        state = state.copyWith(otpTtlSeconds: 0);
      } else {
        state = state.copyWith(otpTtlSeconds: left);
      }
    });
  }

  void _startCooldown(int seconds) {
    _cooldownTimer?.cancel();
    state = state.copyWith(cooldownSeconds: seconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      final left = state.cooldownSeconds - 1;
      if (left <= 0) {
        t.cancel();
        state = state.copyWith(cooldownSeconds: 0);
      } else {
        state = state.copyWith(cooldownSeconds: left);
      }
    });
  }

  void _stopTimers() {
    _ttlTimer?.cancel();
    _ttlTimer = null;
    _cooldownTimer?.cancel();
    _cooldownTimer = null;
  }

  @override
  void dispose() {
    _stopTimers();
    super.dispose();
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
