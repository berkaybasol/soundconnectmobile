// lib/features/venue_app/data/venue_application_api.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:soundconnectmobile/core/network/dio_client.dart';
import 'package:soundconnectmobile/core/storage/secure_storage.dart';
import 'package:soundconnectmobile/env/env.dart';

/// DI
final venueApplicationApiProvider = Provider<VenueApplicationApi>((ref) {
  final dio = ref.read(dioProvider);
  final storage = ref.read(secureStorageProvider);
  return VenueApplicationApi(dio: dio, storage: storage);
});

/// -> eklendi: Token’ı SecureStorage’tan okuyup header’a koyuyoruz (BearerInterceptor’a güvenmeden)
class VenueApplicationApi {
  final Dio _dio;
  final SecureStorage _storage;
  VenueApplicationApi({required Dio dio, required SecureStorage storage})
      : _dio = dio,
        _storage = storage;

  static String get _base =>
      '${Env.baseUrl}/api/v1/user/venue-applications';

  /// POST /api/v1/user/venue-applications/create
  /// body: { venueName, venueAddress, cityId, districtId, neighborhoodId? }
  /// return: BaseResponse<VenueApplicationResponseDto> -> data (Map) döner
  Future<Map<String, dynamic>> createApplication({
    required String venueName,
    required String venueAddress,
    required String cityId,
    required String districtId,
    String? neighborhoodId,
  }) async {
    final token = await _storage.getToken();
    if (token == null || token.isEmpty) {
      throw DioException(
        requestOptions: RequestOptions(path: '$_base/create'),
        error: 'Oturum bulunamadı',
        type: DioExceptionType.badResponse,
      );
    }

    final res = await _dio.post(
      '$_base/create',
      data: {
        'venueName': venueName,
        'venueAddress': venueAddress,
        'cityId': cityId,
        'districtId': districtId,
        if (neighborhoodId != null && neighborhoodId.isNotEmpty)
          'neighborhoodId': neighborhoodId,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    final body = _asMap(res.data);
    _ensureSuccess(res, body);
    final data = _asMap(body['data']); // -> VenueApplicationResponseDto alanları
    return data;
  }

  // ---- Helpers (AuthApi ile aynı davranış) ----
  Map<String, dynamic> _asMap(dynamic v) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) {
      return v.map((k, val) => MapEntry(k.toString(), val));
    }
    throw DioException(
      requestOptions: RequestOptions(path: _base),
      error: 'Unexpected response shape',
      type: DioExceptionType.badResponse,
    );
  }

  void _ensureSuccess(Response res, Map<String, dynamic> body) {
    if (body['success'] == true) return;

    final msg = () {
      final details = body['details'];
      if (details is List && details.isNotEmpty) return details.first.toString();
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
