import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helppsico_mobile/presentation/viewmodels/bloc/auth_state.dart';
import 'package:helppsico_mobile/services/auth/auth_service.dart';


class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit({AuthService? authService})
      : _authService = authService ?? AuthService(),
        super(const AuthInitial());

  Future<void> login(String email, String password) async {
    emit(const AuthLoading());

    try {
      final userData = await _authService.login(email, password);
      emit(AuthSuccess(userData));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  void logout() {
    emit(const AuthInitial());
  }
}