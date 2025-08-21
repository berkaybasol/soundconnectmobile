import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:soundconnectmobile/core/network/dio_client.dart';
import 'package:soundconnectmobile/features/onboarding/data/models/requests/musician_profile_save_request.dart';

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

final musicianOnboardingControllerProvider = StateNotifierProvider<
    MusicianOnboardingController, MusicianOnboardingState>((ref) {
  final dio = ref.watch(dioProvider);
  return MusicianOnboardingController(dio);
});
