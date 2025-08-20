import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'location_api.dart';
import 'models/id_name.dart';

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  final api = ref.read(locationApiProvider);
  return LocationRepository(api);
});

class LocationRepository {
  final LocationApi _api;
  LocationRepository(this._api);

  Future<List<IdName>> getCities() => _api.getAllCities();
  Future<List<IdName>> getDistrictsByCity(String cityId) => _api.getDistrictsByCity(cityId);
  Future<List<IdName>> getNeighborhoodsByDistrict(String districtId) =>
      _api.getNeighborhoodsByDistrict(districtId);
}
