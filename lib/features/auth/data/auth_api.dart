// lib/features/auth/data/auth_api.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:soundconnectmobile/core/network/dio_client.dart';
import 'package:soundconnectmobile/core/network/api_paths.dart';

import 'package:soundconnectmobile/features/auth/data/models/requests/login_request.dart';
import 'package:soundconnectmobile/features/auth/data/models/responses/login_response.dart';
import 'package:soundconnectmobile/features/auth/data/models/requests/register_request.dart';

/// DI
final authApiProvider = Provider<AuthApi>((ref) {
  final dio = ref.read(dioProvider);
  return AuthApi(dio);
});

class AuthApi {
  final Dio _dio;
  AuthApi(this._dio);

  /// POST /api/v1/auth/login  -> { success, data: { token } }
  Future<LoginResponse> login(LoginRequest req) async {
    final res = await _dio.post(ApiPaths.login, data: req.toJson());
    final body = _asMap(res.data);
    _ensureSuccess(res, body);
    final data = _asMap(body['data']);
    return LoginResponse.fromJson(data);
  }

  /// (Opsiyonel) Google giriş endpoint’iniz devam ediyorsa:
  Future<LoginResponse> googleSignIn(String idToken) async {
    final res = await _dio.post(ApiPaths.googleSignIn, data: {'idToken': idToken});
    final body = _asMap(res.data);
    _ensureSuccess(res, body);
    final data = _asMap(body['data']);
    return LoginResponse.fromJson(data);
  }

  /// POST /api/v1/auth/register
  /// -> { success, data: { email, status, otpTtlSeconds, mailQueued } }
  /// Flutter tarafında VerifyCodePage’e taşıyabilmek için data map’ini döndürüyoruz.
  Future<Map<String, dynamic>> register(RegisterRequest req) async {
    final res = await _dio.post(ApiPaths.register, data: req.toJson());
    final body = _asMap(res.data);
    _ensureSuccess(res, body);
    final data = _asMap(body['data']);
    return {
      'email': data['email'],
      'status': data['status'],
      'otpTtlSeconds': data['otpTtlSeconds'],
      'mailQueued': data['mailQueued'],
      'message': body['message'],
      'code': body['code'],
      'success': body['success'] == true,
    };
  }

  /// POST /api/v1/auth/verify-code
  /// body: { email, code }  -> { success, data:null }
  /// Başarılıysa true döner; hata durumunda DioException fırlatır.
  Future<bool> verifyCode({required String email, required String code}) async {
    final res = await _dio.post(ApiPaths.verifyCode, data: {
      'email': email,
      'code': code,
    });
    final body = _asMap(res.data);
    _ensureSuccess(res, body);
    return body['success'] == true;
  }

  /// POST /api/v1/auth/resend-code
  /// body: { email } -> BaseResponse<ResendCodeResponseDto>
  /// success=false ve code=429 olsa bile HTTP 200 gelebilir (rate limit semantiği).
  /// Bu yüzden _ensureSuccess ÇAĞIRMAYIP tüm gövdeyi döndürüyoruz.
  Future<Map<String, dynamic>> resendCode({required String email}) async {
    final res = await _dio.post(ApiPaths.resendCode, data: {
      'email': email,
    });
    final body = _asMap(res.data);

    final data = _asMapNullable(body['data']);
    return {
      'success': body['success'] == true,
      'code': body['code'],
      'message': body['message'],
      'otpTtlSeconds': data?['otpTtlSeconds'] ?? 0,
      'mailQueued': data?['mailQueued'] == true,
      'cooldownSeconds': data?['cooldownSeconds'] ?? 0,
    };
  }

  // ---- Helpers ----

  Map<String, dynamic> _asMap(dynamic v) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return v.map((k, val) => MapEntry(k.toString(), val));
    throw DioException(
      requestOptions: RequestOptions(path: ApiPaths.authBase),
      error: 'Unexpected response shape',
      type: DioExceptionType.badResponse,
    );
  }

  Map<String, dynamic>? _asMapNullable(dynamic v) {
    if (v == null) return null;
    return _asMap(v);
  }

  void _ensureSuccess(Response res, Map<String, dynamic> body) {
    final success = body['success'] == true;
    if (success) return;

    final msg = () {
      final details = body['details'];
      if (details is List && details.isNotEmpty) {
        return details.first.toString();
      }
      return body['message']?.toString() ?? 'İstek başarısız';
    }();

    throw DioException(
      requestOptions: res.requestOptions,
      response: res,
      error: msg,
      type: DioExceptionType.badResponse,
    );
  }
}
