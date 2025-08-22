import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundconnectmobile/core/network/api_paths.dart';
import 'package:soundconnectmobile/core/network/dio_client.dart';

import '../models/musician_profile.dart';
import '../../../../onboarding/data/models/requests/musician_profile_save_request.dart';

final musicianSelfApiProvider = Provider<MusicianSelfApi>((ref) {
  final dio = ref.watch(dioProvider);
  return MusicianSelfApi(dio);
});

class MusicianSelfApi {
  final Dio _dio;
  MusicianSelfApi(this._dio);

  Future<MusicianProfile> getMe() async {
    final res = await _dio.get(ApiPaths.musicianMe);
    if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
      return MusicianProfile.fromAnyJson(res.data as Map<String, dynamic>);
    }
    throw DioException(
      requestOptions: res.requestOptions,
      response: res,
      error: 'Profil alınamadı',
      type: DioExceptionType.badResponse,
    );
  }

  Future<void> update(MusicianProfileSaveRequest req) async {
    // DÜZELTİLDİ: musicianMeUpdate -> musicianUpdate
    final res = await _dio.put(ApiPaths.musicianUpdate, data: req.toJson());
    final ok = res.statusCode == 200 &&
        (res.data is Map<String, dynamic>
            ? ((res.data as Map)['success'] == true)
            : true);
    if (!ok) {
      final msg = (res.data is Map<String, dynamic>
          ? (res.data as Map)['message']
          : null) ??
          'Profil güncellenemedi';
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        error: msg,
        type: DioExceptionType.badResponse,
      );
    }
  }
}
