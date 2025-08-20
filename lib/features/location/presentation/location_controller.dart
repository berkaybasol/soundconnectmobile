import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:soundconnectmobile/core/error/ui_error_mapper.dart';
import 'package:soundconnectmobile/features/location/data/location_repository.dart';
import 'package:soundconnectmobile/features/location/data/models/id_name.dart';

class LocationState {
  final List<IdName> cities;
  final List<IdName> districts;
  final List<IdName> neighborhoods;

  final bool loadingCities;
  final bool loadingDistricts;
  final bool loadingNeighborhoods;

  final String? errorMessage;

  const LocationState({
    this.cities = const [],
    this.districts = const [],
    this.neighborhoods = const [],
    this.loadingCities = false,
    this.loadingDistricts = false,
    this.loadingNeighborhoods = false,
    this.errorMessage,
  });

  LocationState copyWith({
    List<IdName>? cities,
    List<IdName>? districts,
    List<IdName>? neighborhoods,
    bool? loadingCities,
    bool? loadingDistricts,
    bool? loadingNeighborhoods,
    String? errorMessage,
  }) {
    return LocationState(
      cities: cities ?? this.cities,
      districts: districts ?? this.districts,
      neighborhoods: neighborhoods ?? this.neighborhoods,
      loadingCities: loadingCities ?? this.loadingCities,
      loadingDistricts: loadingDistricts ?? this.loadingDistricts,
      loadingNeighborhoods: loadingNeighborhoods ?? this.loadingNeighborhoods,
      errorMessage: errorMessage,
    );
  }
}

final locationControllerProvider =
StateNotifierProvider<LocationController, LocationState>((ref) {
  final repo = ref.read(locationRepositoryProvider);
  return LocationController(repo);
});

class LocationController extends StateNotifier<LocationState> {
  final LocationRepository _repo;

  LocationController(this._repo) : super(const LocationState());

  void clearError() => state = state.copyWith(errorMessage: null);

  Future<void> ensureCitiesLoaded() async {
    if (state.cities.isNotEmpty || state.loadingCities) return;
    await loadCities();
  }

  Future<void> loadCities() async {
    state = state.copyWith(loadingCities: true, errorMessage: null);
    try {
      final cities = await _repo.getCities();
      state = state.copyWith(cities: cities);
    } catch (e) {
      state = state.copyWith(errorMessage: UiErrorMapper.humanize(e));
    } finally {
      state = state.copyWith(loadingCities: false);
    }
  }

  Future<void> loadDistricts(String cityId) async {
    state = state.copyWith(
      loadingDistricts: true,
      errorMessage: null,
      districts: const [],
      neighborhoods: const [],
    );
    try {
      final districts = await _repo.getDistrictsByCity(cityId);
      state = state.copyWith(districts: districts);
    } catch (e) {
      state = state.copyWith(errorMessage: UiErrorMapper.humanize(e));
    } finally {
      state = state.copyWith(loadingDistricts: false);
    }
  }

  Future<void> loadNeighborhoods(String districtId) async {
    state = state.copyWith(
      loadingNeighborhoods: true,
      errorMessage: null,
      neighborhoods: const [],
    );
    try {
      final neighborhoods = await _repo.getNeighborhoodsByDistrict(districtId);
      state = state.copyWith(neighborhoods: neighborhoods);
    } catch (e) {
      state = state.copyWith(errorMessage: UiErrorMapper.humanize(e));
    } finally {
      state = state.copyWith(loadingNeighborhoods: false);
    }
  }
}
