// lib/features/profile/presentation/providers/profile_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundconnectmobile/core/network/dio_client.dart';
import '../../data/profile_repository.dart';
import '../../data/models/requests/musician_profile_dto.dart';

final musicianProfileProvider =
FutureProvider.autoDispose<MusicianProfileDto>((ref) async {
  // token değişince yeniden fetch
  final _ = ref.watch(authTokenProvider);
  final repo = ref.read(profileRepositoryProvider);
  return repo.getMyMusicianProfile();
});
