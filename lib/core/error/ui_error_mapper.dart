import 'package:dio/dio.dart';

class UiErrorMapper {
  static String humanize(Object e) {
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
