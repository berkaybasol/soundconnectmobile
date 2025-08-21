lib/
core/              # Uygulama geneli altyapı (herkesin ortak kullandığı şeyler)
network/         # Ağ: Dio, interceptor, endpoint sabitleri
routing/         # GoRouter; giriş noktaları ve hata sayfası
storage/         # Güvenli saklama (token vs.)
theme/           # Renkler, tipografi, global ThemeData
env/               # Ortam değişkenleri (BASE_URL vb.)
features/          # Dikey modüller (auth, onboarding, profile, location, home, venue_app…)
<feature>/
data/          # API/Repo/Model — ağ & disk burada
api/         # Dio ile endpoint çağrıları
models/      # DTO’lar (requests/responses)
repositories/# API + cache orkestrasyonu
presentation/  # UI + State (Riverpod Notifier’lar + Widget’lar)
controllers/ # StateNotifier’lar, UI’nın konuştuğu katman
pages/       # Ekran sayfaları
widgets/     # Parçalanmış, yeniden kullanılabilir UI blokları
