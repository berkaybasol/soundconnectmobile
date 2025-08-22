import 'package:dio/dio.dart';

// Uygulamada backend’den gelen hataları kullanıcıya anlaşılır bir şekilde göstermek için
// kullanılan yardımcı sınıf.
class UiErrorMapper {
  // humanize metodu, verilen hata objesini (Object e) alır ve kullanıcıya
  // gösterilecek okunabilir bir mesaj string’i döner.
  static String humanize(Object e) {
    // Eğer hata bir DioException ise (Dio = HTTP isteklerini yapan paket),
    // detaylı bir ayrıştırma yapılır.
    if (e is DioException) {
      switch (e.type) {
      // Eğer hata bağlantı süresi dolması, yanıt süresi dolması
      // ya da gönderim süresi dolması ise → zaman aşımı mesajı döndürülür.
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return 'Bağlantı zaman aşımına uğradı';

      // Eğer hata sunucudan kötü bir yanıt geldiyse (örneğin 400, 500),
      // e.error varsa onu string’e çevirip göster, yoksa genel mesaj ver.
        case DioExceptionType.badResponse:
          final msg = e.error?.toString();
          return (msg != null && msg.isNotEmpty) ? msg : 'İstek başarısız';

      // Eğer istek iptal edildiyse.
        case DioExceptionType.cancel:
          return 'İstek iptal edildi';

      // Eğer hata türü bilinmiyorsa veya Dio’nun unknown default case’i ise.
        case DioExceptionType.unknown:
        default:
          return 'Ağ hatası';
      }
    }
    // Eğer gelen hata DioException değilse, direkt toString() ile stringe çevirip döner.
    return e.toString();
  }
}
