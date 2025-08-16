import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundconnectmobile/features/auth/data/auth_repository.dart';

class LoginState {
  final bool loading;
  final String? error;

  const LoginState({this.loading = false, this.error});

  LoginState copyWith({bool? loading, String? error}) =>
      LoginState(loading: loading ?? this.loading, error: error);
}

final loginControllerProvider =
StateNotifierProvider<LoginController, LoginState>((ref) {
  final repo = ref.read(authRepositoryProvider);
  return LoginController(repo);
});

class LoginController extends StateNotifier<LoginState> {
  final AuthRepository _repo;
  LoginController(this._repo) : super(const LoginState());

  void clearError() => state = state.copyWith(error: null);

  /// Kullanıcı adı / şifre ile giriş
  Future<bool> login(String username, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await _repo.login(username: username, password: password);
      state = state.copyWith(loading: false);
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: _humanize(e));
      return false;
    }
  }

  /// Google ile giriş
  Future<bool> googleSignIn(String idToken) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await _repo.googleSignIn(idToken);
      state = state.copyWith(loading: false);
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: _humanize(e));
      return false;
    }
  }

  String _humanize(Object e) {
    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return 'Bağlantı zaman aşımına uğradı';
        case DioExceptionType.badResponse:
        // Backend BaseResponse.message varsa önce onu göster
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
