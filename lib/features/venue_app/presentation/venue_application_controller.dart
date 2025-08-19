// lib/features/venue_app/presentation/venue_application_controller.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundconnectmobile/features/venue_app/data/venue_application_repository.dart';

/// Provider
final venueApplicationControllerProvider = StateNotifierProvider<
    VenueApplicationController, AsyncValue<void>>((ref) {
  final repo = ref.read(venueApplicationRepositoryProvider);
  return VenueApplicationController(repo);
});

/// Sadece tek sınıf: State = AsyncValue<void>
/// - AsyncLoading => gönderiliyor
/// - AsyncData(null) => başarı
/// - AsyncError(String message) => hata
class VenueApplicationController extends StateNotifier<AsyncValue<void>> {
  final VenueApplicationRepository _repo;

  VenueApplicationController(this._repo)
      : super(const AsyncValue.data(null));

  Future<bool> submit({
    required String venueName,
    required String venueAddress,
    required String cityId,
    required String districtId,
    String? neighborhoodId,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repo.createApplication(
        venueName: venueName,
        venueAddress: venueAddress,
        cityId: cityId,
        districtId: districtId,
        neighborhoodId: neighborhoodId,
      );
      state = const AsyncValue.data(null);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(_humanize(e), st);
      return false;
    }
  }

  String _humanize(Object e) {
    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return 'Bağlantı zaman aşımına uğradı';
        case DioExceptionType.badResponse:
          final msg = e.error?.toString();
          return (msg != null && msg.isNotEmpty) ? msg : 'İstek başarısız';
        case DioExceptionType.cancel:
          return 'İstek iptal edildi';
        case DioExceptionType.unknown:
        default:
          return 'Ağ hatası';
      }
    }
    return e.toString();
  }
}
