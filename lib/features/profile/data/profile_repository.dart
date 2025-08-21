// lib/features/profile/data/profile_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'profile_api.dart';
import 'models/requests/musician_profile_dto.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final api = ref.read(profileApiProvider);
  return ProfileRepository(api);
});

class ProfileRepository {
  final ProfileApi _api;
  ProfileRepository(this._api);

  Future<MusicianProfileDto> getMyMusicianProfile() =>
      _api.getMyMusicianProfile();
}
