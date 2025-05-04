import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:helppsico_mobile/core/services/auth/auth_service.dart';
import 'package:helppsico_mobile/presentation/viewmodels/state/auth_state.dart';


class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit({AuthService? authService})
      //initializer list(é usada para inicializar variáveis ​​de instância antes de chamar o construtor principal da classe )
      : _authService = authService ?? AuthService(),
        super(const AuthInitial());//é usado para que o estado do authCubit seja inicializado com o estado AuthInitial

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






