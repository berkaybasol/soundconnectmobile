import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/musician_self_repository.dart';
import '../../data/models/musician_profile.dart';
import '../../../../onboarding/data/models/requests/musician_profile_save_request.dart';

/// Profil verisini çeker
final musicianSelfProfileProvider = FutureProvider<MusicianProfile>((ref) async {
  final repo = ref.watch(musicianSelfRepositoryProvider);
  return repo.getMe();
});

/// Düzenleme state'i
class MusicianSelfEditState {
  final bool loading;
  final String? error;
  final bool success;

  const MusicianSelfEditState({
    this.loading = false,
    this.error,
    this.success = false,
  });

  MusicianSelfEditState copyWith({bool? loading, String? error, bool? success}) {
    return MusicianSelfEditState(
      loading: loading ?? this.loading,
      error: error,
      success: success ?? this.success,
    );
  }
}

final musicianSelfEditControllerProvider =
StateNotifierProvider<MusicianSelfEditController, MusicianSelfEditState>(
        (ref) => MusicianSelfEditController(ref));

class MusicianSelfEditController extends StateNotifier<MusicianSelfEditState> {
  final Ref _ref;
  MusicianSelfEditController(this._ref) : super(const MusicianSelfEditState());

  Future<void> update(MusicianProfileSaveRequest req) async {
    final repo = _ref.read(musicianSelfRepositoryProvider);
    try {
      state = state.copyWith(loading: true, error: null, success: false);
      await repo.update(req);
      _ref.invalidate(musicianSelfProfileProvider); // cache tazele
      state = state.copyWith(loading: false, success: true);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}
