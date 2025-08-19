// lib/features/venue_app/data/venue_application_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundconnectmobile/features/venue_app/data/venue_application_api.dart';

/// DI
final venueApplicationRepositoryProvider =
Provider<VenueApplicationRepository>((ref) {
  final api = ref.read(venueApplicationApiProvider);
  return VenueApplicationRepository(api);
});

/// -> eklendi: API katmanını saran basit repository
class VenueApplicationRepository {
  final VenueApplicationApi _api;
  VenueApplicationRepository(this._api);

  /// Backend: POST /api/v1/user/venue-applications/create
  /// body: { venueName, venueAddress, cityId, districtId, neighborhoodId? }
  /// return: Map (VenueApplicationResponseDto alanları)
  Future<Map<String, dynamic>> createApplication({
    required String venueName,
    required String venueAddress,
    required String cityId,
    required String districtId,
    String? neighborhoodId,
  }) {
    return _api.createApplication(
      venueName: venueName,
      venueAddress: venueAddress,
      cityId: cityId,
      districtId: districtId,
      neighborhoodId: neighborhoodId,
    );
  }
}
