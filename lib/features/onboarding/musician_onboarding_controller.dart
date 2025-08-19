import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:soundconnectmobile/core/network/dio_client.dart';


/// Profil save request DTO
class MusicianProfileSaveRequest {
  final String? stageName;
  final String? description;
  final String? profilePicture;
  final String? instagramUrl;
  final String? youtubeUrl;
  final String? soundcloudUrl;
  final String? spotifyEmbedUrl;
  final List<String> instrumentIds;

  MusicianProfileSaveRequest({
    this.stageName,
    this.description,
    this.profilePicture,
    this.instagramUrl,
    this.youtubeUrl,
    this.soundcloudUrl,
    this.spotifyEmbedUrl,
    this.instrumentIds = const [],
  });

  Map<String, dynamic> toJson() => {
    "stageName": stageName,
    "description": description,
    "profilePicture": profilePicture,
    "instagramUrl": instagramUrl,
    "youtubeUrl": youtubeUrl,
    "soundcloudUrl": soundcloudUrl,
    "spotifyEmbedUrl": spotifyEmbedUrl,
    "instrumentIds": instrumentIds,
  };
}

/// State: yükleniyor / hata / başarılı
class MusicianOnboardingState {
  final bool loading;
  final String? error;
  final bool success;

  const MusicianOnboardingState({
    this.loading = false,
    this.error,
    this.success = false,
  });

  MusicianOnboardingState copyWith({
    bool? loading,
    String? error,
    bool? success,
  }) {
    return MusicianOnboardingState(
      loading: loading ?? this.loading,
      error: error,
      success: success ?? this.success,
    );
  }
}

/// Notifier
class MusicianOnboardingController
    extends StateNotifier<MusicianOnboardingState> {
  final Dio _dio;

  MusicianOnboardingController(this._dio)
      : super(const MusicianOnboardingState());

  Future<void> updateProfile(MusicianProfileSaveRequest req) async {
    try {
      state = state.copyWith(loading: true, error: null, success: false);

      final res = await _dio.put(
        "/api/v1/user/musician-profiles/update",
        data: req.toJson(),
      );

      final ok = res.statusCode == 200 && res.data["success"] == true;
      if (ok) {
        state = state.copyWith(loading: false, success: true);
      } else {
        state = state.copyWith(
          loading: false,
          error: res.data["message"] ?? "Profil güncellenemedi",
        );
      }
    } on DioException catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.response?.data?["message"] ?? e.message,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}

/// Provider
final musicianOnboardingControllerProvider = StateNotifierProvider<
    MusicianOnboardingController, MusicianOnboardingState>((ref) {
  final dio = ref.watch(dioProvider); // senin mevcut global dio provider’ın
  return MusicianOnboardingController(dio);
});
