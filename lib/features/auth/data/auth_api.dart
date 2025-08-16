import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundconnectmobile/core/network/endpoints.dart';
import 'package:soundconnectmobile/core/network/dio_client.dart';
import 'package:soundconnectmobile/features/auth/data/models/login_request.dart';
import 'package:soundconnectmobile/features/auth/data/models/login_response.dart';
import 'package:soundconnectmobile/shared/models/base_response.dart';

final authApiProvider = Provider<AuthApi>((ref) {
  final dio = ref.read(dioProvider);
  return AuthApi(dio);
});

class AuthApi {
  final Dio _dio;
  AuthApi(this._dio);

  /// Kullanıcı adı/şifre ile login
  Future<LoginResponse> login(LoginRequest request) async {
    final res = await _dio.post(ApiPaths.login, data: request.toJson());

    // Beklenen zarf: { success, message, code, data: { token } }
    final map = res.data as Map<String, dynamic>;
    final base = BaseResponse<LoginResponse>.fromJson(
      map,
      dataParser: (obj) => obj == null
          ? throw Exception('Empty data')
          : LoginResponse.fromJson(obj as Map<String, dynamic>),
    );

    if (!base.success || base.data == null) {
      throw DioException(
        requestOptions: res.requestOptions,
        error: base.message ?? 'Login failed',
        response: res,
        type: DioExceptionType.badResponse,
      );
    }
    return base.data!;
  }

  /// Google ile giriş
  /// Not: Backend hangi alanı bekliyorsa ('idToken' / 'accessToken') burada ona göre gönder.
  Future<LoginResponse> googleSignIn(String idToken) async {
    final res = await _dio.post(
      ApiPaths.googleSignIn,
      data: {'idToken': idToken},
    );

    final map = res.data as Map<String, dynamic>;
    final base = BaseResponse<LoginResponse>.fromJson(
      map,
      dataParser: (obj) => obj == null
          ? throw Exception('Empty data')
          : LoginResponse.fromJson(obj as Map<String, dynamic>),
    );

    if (!base.success || base.data == null) {
      throw DioException(
        requestOptions: res.requestOptions,
        error: base.message ?? 'Google login failed',
        response: res,
        type: DioExceptionType.badResponse,
      );
    }
    return base.data!;
  }

// İleride ihtiyaç olursa:
// Future<LoginResponse> completeGoogleProfile(CompleteGoogleProfileRequest req) async { ... }
// Future<void> register(RegisterRequest req) async { ... }
// Future<void> verifyEmail(String token) async { ... }
}
