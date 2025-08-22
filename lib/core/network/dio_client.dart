// lib/core/network/dio_client.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_flutter/talker_flutter.dart';
import '../../env/env.dart';

/// =============================
/// 1) TOKEN YÖNETİMİ
/// =============================
/// Burada global bir `StateProvider` tanımlanıyor.
/// Login olunca JWT token buraya yazılır, logout olunca null yapılır.
/// BearerInterceptor her request atıldığında buradan token'ı okuyacak.
final authTokenProvider = StateProvider<String?>((ref) => null);

/// =============================
/// 2) TALKER LOG
/// =============================
/// Talker = gelişmiş bir log kütüphanesi.
/// Tüm request/response/error logları buradan geçiyor.
/// Flutter tarafında debug için kullanıyorsun.
final talkerProvider = Provider<Talker>((ref) => TalkerFlutter.init());

/// =============================
/// 3) BEARER INTERCEPTOR
/// =============================
/// Dio'nun interceptor özelliğini override ediyoruz.
/// Amaç: her outgoing request'e Authorization: Bearer <token> header'ı eklemek,
/// ayrıca request/response/error loglarını Talker üzerinden bastırmak.
class BearerInterceptor extends Interceptor {
  final Ref ref;
  final Talker talker;
  BearerInterceptor(this.ref, this.talker);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Token var mı? varsa Authorization header'a ekle.
    final token = ref.read(authTokenProvider);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    // Request log
    talker.debug('[REQ] ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Response log
    talker.debug('[RES] ${response.statusCode} ${response.realUri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Error log
    talker.error('[ERR] ${err.response?.statusCode} ${err.requestOptions.uri} ${err.message}');
    handler.next(err);
  }
}

/// =============================
/// 4) DIO PROVIDER
/// =============================
/// Riverpod Provider ile global bir Dio instance tanımlanıyor.
/// Tüm API sınıfları bu dio'yu enjekte ederek kullanacak.
/// BaseOptions → baseUrl, timeout, content-type ayarları.
/// Interceptor olarak BearerInterceptor ekleniyor.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: Env.baseUrl, // .env’den geliyor
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Content-Type': 'application/json'},
      // validateStatus: 200–599 → hata alsa bile response objesi dönsün
      validateStatus: (code) => code != null && code >= 200 && code < 600,
    ),
  );

  // BearerInterceptor ekleniyor → token & log yönetimi
  dio.interceptors.add(BearerInterceptor(ref, ref.read(talkerProvider)));

  // DEBUG amaçlı base url yazdırılıyor
  debugPrint('BASE_URL is: ${Env.baseUrl}');

  return dio;
});
