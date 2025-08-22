import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundconnectmobile/features/auth/data/auth_repository.dart';
import 'package:soundconnectmobile/core/error/ui_error_mapper.dart';

/// =============================
/// 1) LOGIN STATE
/// =============================
/// Ekrandaki login durumunu (loading, error) tutan model.
/// UI sadece bu state'i dinler → loading spinner aç/kapat, hata mesajı göster.
class LoginState {
  final bool loading;
  final String? error;

  const LoginState({this.loading = false, this.error});

  /// copyWith → mevcut state'in kopyasını üretip sadece verilen alanları değiştirir.
  LoginState copyWith({bool? loading, String? error}) =>
      LoginState(loading: loading ?? this.loading, error: error);
}

/// =============================
/// 2) PROVIDER
/// =============================
/// Riverpod StateNotifierProvider → LoginController + LoginState'i UI'ya bağlar.
/// Spring’deki @Controller + @Service’i UI’ya expose etmek gibi.
/// UI → ref.watch(loginControllerProvider) diyerek state'i alır.
final loginControllerProvider =
StateNotifierProvider<LoginController, LoginState>((ref) {
  final repo = ref.read(authRepositoryProvider); // AuthRepository enjekte edildi
  return LoginController(repo);
});

/// =============================
/// 3) CONTROLLER
/// =============================
/// LoginController, AuthRepository'yi kullanarak giriş işlemini yapar.
/// - State yönetir (loading, error)
/// - Hata olursa UiErrorMapper ile insan-dostu mesaja çevirir.
/// Flutter tarafındaki "iş mantığı" burada.
/// Spring’deki Service + Controller karışımı gibi.
class LoginController extends StateNotifier<LoginState> {
  final AuthRepository _repo;
  LoginController(this._repo) : super(const LoginState());

  /// Hata mesajını temizle
  void clearError() => state = state.copyWith(error: null);

  /// Login işlemi
  /// - UI'dan çağrılır
  /// - loading true yapılır
  /// - repository.login çağrılır
  /// - başarılıysa loading kapatılır ve true döner
  /// - hata alırsa loading kapatılır, error'a humanize edilmiş hata mesajı yazılır
  Future<bool> login(String username, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await _repo.login(username: username, password: password);
      state = state.copyWith(loading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: UiErrorMapper.humanize(e), // DioException → insani mesaj
      );
      return false;
    }
  }
}
