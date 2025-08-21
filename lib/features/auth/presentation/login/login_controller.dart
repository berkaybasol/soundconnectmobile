import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundconnectmobile/features/auth/data/auth_repository.dart';
import 'package:soundconnectmobile/core/error/ui_error_mapper.dart';


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

  Future<bool> login(String username, String password) async {
    state = state.copyWith(loading: true, error: null);
    try {
      await _repo.login(username: username, password: password);
      state = state.copyWith(loading: false);
      return true;
    } catch (e) {
      state = state.copyWith(loading: false, error: UiErrorMapper.humanize(e));
      return false;
    }
  }
}
