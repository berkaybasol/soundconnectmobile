import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundconnectmobile/core/error/ui_error_mapper.dart';

import '../api/musician_self_api.dart';
import '../models/musician_profile.dart';
import '../../../../onboarding/data/models/requests/musician_profile_save_request.dart';

final musicianSelfRepositoryProvider = Provider<MusicianSelfRepository>((ref) {
  final api = ref.watch(musicianSelfApiProvider);
  return MusicianSelfRepository(api);
});

class MusicianSelfRepository {
  final MusicianSelfApi _api;
  MusicianSelfRepository(this._api);

  Future<MusicianProfile> getMe() async {
    try {
      return await _api.getMe();
    } catch (e) {
      throw Exception(UiErrorMapper.humanize(e));
    }
  }

  Future<void> update(MusicianProfileSaveRequest req) async {
    try {
      await _api.update(req);
    } catch (e) {
      throw Exception(UiErrorMapper.humanize(e));
    }
  }
}
