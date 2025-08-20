import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:soundconnectmobile/core/network/dio_client.dart';
import 'package:soundconnectmobile/core/network/api_paths.dart';
import 'models/id_name.dart';

/// DI
final locationApiProvider = Provider<LocationApi>((ref) {
  final dio = ref.read(dioProvider);
  return LocationApi(dio);
});

class LocationApi {
  final Dio _dio;
  LocationApi(this._dio);

  Future<List<IdName>> getAllCities() async {
    final res = await _dio.get(ApiPaths.citiesAll);
    final data = _extractList(res);
    return data.map((e) => IdName.fromJson(e)).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  /// İlçeleri şehir ID’ye göre getir; eğer beklenen gövde yoksa
  /// tümünü çekip client-side filtrele (senin fallback davranışın korunuyor).
  Future<List<IdName>> getDistrictsByCity(String cityId) async {
    final res = await _dio.get(ApiPaths.districtsByCity(cityId));
    final ok = _isOk(res);
    if (!ok) {
      final all = await _dio.get(ApiPaths.districtsAll);
      final list = _extractListRaw(all);
      final filtered = list.where((e) {
        final m = Map<String, dynamic>.from(e as Map);
        return m['cityId']?.toString() == cityId;
      }).map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map)).toList();

      return filtered.map((e) => IdName.fromJson(e)).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    }
    final list = _extractListRaw(res);
    return list
        .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map))
        .map((e) => IdName.fromJson(e))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<List<IdName>> getNeighborhoodsByDistrict(String districtId) async {
    final res = await _dio.get(ApiPaths.neighborhoodsByDistrict(districtId));
    final ok = _isOk(res);
    if (!ok) {
      final all = await _dio.get(ApiPaths.neighborhoodsAll);
      final list = _extractListRaw(all);
      final filtered = list.where((e) {
        final m = Map<String, dynamic>.from(e as Map);
        return m['districtId']?.toString() == districtId;
      }).map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map)).toList();

      return filtered.map((e) => IdName.fromJson(e)).toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    }
    final list = _extractListRaw(res);
    return list
        .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map))
        .map((e) => IdName.fromJson(e))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  // ---- helpers ----

  bool _isOk(Response res) {
    final status = res.statusCode ?? 0;
    if (status != 200) return false;
    final data = res.data;
    if (data is! Map) return false;
    final m = Map<String, dynamic>.from(data);
    return m['success'] == true && m['data'] is List;
  }

  List<Map<String, dynamic>> _extractList(Response res) {
    final m = Map<String, dynamic>.from(res.data as Map);
    final list = (m['data'] as List?) ?? const [];
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  List _extractListRaw(Response res) {
    final data = res.data;
    if (data is Map && data['data'] is List) return data['data'] as List;
    return const [];
  }
}
