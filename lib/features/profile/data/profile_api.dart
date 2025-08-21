// lib/features/profile/data/profile_api.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundconnectmobile/core/network/dio_client.dart';
import 'models/requests/musician_profile_dto.dart';

final profileApiProvider = Provider<ProfileApi>((ref) {
  final dio = ref.read(dioProvider);
  return ProfileApi(dio);
});

class ProfileApi {
  final Dio _dio;
  ProfileApi(this._dio);

  Future<MusicianProfileDto> getMyMusicianProfile() async {
    final res = await _dio.get('/api/v1/user/musician-profiles/me');
    final status = res.statusCode ?? 0;
    final body = (res.data is Map) ? res.data as Map : const {};

    if (status == 401 || status == 403) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        error: body['message'] ?? 'Oturum gerekli',
        type: DioExceptionType.badResponse,
      );
    }
    if (status == 404) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        error: body['message'] ?? 'Müzisyen profili bulunamadı',
        type: DioExceptionType.badResponse,
      );
    }
    if (status != 200 || body['data'] is! Map) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        error: body['message'] ?? 'Profil getirilemedi ($status)',
        type: DioExceptionType.badResponse,
      );
    }

    return MusicianProfileDto.fromJson(
      Map<String, dynamic>.from(body['data'] as Map),
    );
  }
}
