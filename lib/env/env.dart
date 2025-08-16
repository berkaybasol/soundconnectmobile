class Env {
  /// Backend tabanı
  static const baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://192.168.144.1:8080', // kendi IP'n
  );

  /// Google Sign-In için **Web Client ID** (OAuth 2.0 “Web application”)
  /// Bunu dart-define ile geçeceğiz.
  static const googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '', // boş bırak; run ederken dart-define ile dolduracağız
  );
}
