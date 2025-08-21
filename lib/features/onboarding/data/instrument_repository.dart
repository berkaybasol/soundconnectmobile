import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/instrument.dart';
import 'package:soundconnectmobile/core/network/dio_client.dart';
import 'package:soundconnectmobile/core/network/api_paths.dart';

final instrumentRepositoryProvider = Provider<InstrumentRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return InstrumentRepository(dio);
});

class InstrumentRepository {
  final Dio _dio;
  InstrumentRepository(this._dio);

  Future<List<Instrument>> getAll() async {
    final res = await _dio.get(ApiPaths.instrumentsAll);
    if ((res.statusCode ?? 0) != 200 || res.data is! Map) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        error: 'Enstrüman listesi alınamadı',
        type: DioExceptionType.badResponse,
      );
    }
    final list = (res.data['data'] as List?) ?? const [];
    return list
        .map((e) => Instrument.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }
}
