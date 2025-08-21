// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_flutter/talker_flutter.dart';
import '../../env/env.dart';

/// Basit token okuyucu (BearerInterceptor bunu kullanır)
final authTokenProvider = StateProvider<String?>((ref) => null);

/// Talker log
final talkerProvider = Provider<Talker>((ref) => TalkerFlutter.init());

/// Bearer Interceptor
class BearerInterceptor extends Interceptor {

  final Ref ref;
  final Talker talker;
  BearerInterceptor(this.ref, this.talker);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = ref.read(authTokenProvider);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    talker.debug('[REQ] ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    talker.debug('[RES] ${response.statusCode} ${response.realUri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    talker.error('[ERR] ${err.response?.statusCode} ${err.requestOptions.uri} ${err.message}');
    handler.next(err);
  }
}

/// Dio client
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: Env.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Content-Type': 'application/json'},
      validateStatus: (code) => code != null && code >= 200 && code < 600,
    ),
  );

  dio.interceptors.add(BearerInterceptor(ref, ref.read(talkerProvider)));
  return dio;

  // DEBUG: Çalışan BASE_URL’i logla
  debugPrint('BASE_URL is: ${Env.baseUrl}');

  dio.interceptors.add(BearerInterceptor(ref, ref.read(talkerProvider)));
  return dio;
});
