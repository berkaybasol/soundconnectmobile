class Env {
  /// =============================
  /// 1) BACKEND BASE URL
  /// =============================
  /// Uygulamanın tüm HTTP istekleri için temel adres.
  /// `dart-define` ile çalıştırırken BASE_URL parametresi gönderilebiliyor:
  ///
  /// flutter run --dart-define=BASE_URL=http://192.168.1.101:8080
  ///
  /// Eğer dışarıdan verilmezse → defaultValue kullanılır.
  static const baseUrl = String.fromEnvironment(
    'BASE_URL',
    // farklı IP’ler için örnek alternatif defaultValue’ler:
    // defaultValue: 'http://192.168.144.1:8080',
    defaultValue: 'http://192.168.1.101:8080',
  );

  /// =============================
  /// 2) GOOGLE SIGN-IN CLIENT ID
  /// =============================
  /// Google ile giriş için gerekli **Web Client ID** (OAuth 2.0).
  /// Bunun da değeri `dart-define` ile verilecek:
  ///
  /// flutter run --dart-define=GOOGLE_WEB_CLIENT_ID=xxxx.apps.googleusercontent.com
  ///
  /// Default boş bırakılmış → production’da da aynı şekilde doldurulur.
  static const googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
    defaultValue: '',
  );
}
