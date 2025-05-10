import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:helppsico_mobile/core/services/auth/auth_service.dart';
import 'package:helppsico_mobile/core/services/storage/secure_storage_service.dart';
import 'package:helppsico_mobile/core/utils/user_info_printer.dart';
import 'package:helppsico_mobile/presentation/viewmodels/state/auth_state.dart';


class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit({AuthService? authService})
      //initializer list(é usada para inicializar variáveis ​​de instância antes de chamar o construtor principal da classe )
      : _authService = authService ?? AuthService(),
        super(const AuthInitial()) {
    // Verificar se o usuário já está autenticado ao iniciar o cubit
    checkAuthStatus();
  }


  Future<void> checkAuthStatus() async {
    final isAuthenticated = await _authService.isAuthenticated();
    
    if (isAuthenticated) {
      final userInfo = await _authService.getUserInfo();
      if (userInfo != null) {
        final userData = AuthResponse(
          id: userInfo['id'],
          name: userInfo['name'],
          email: userInfo['email'],
          role: userInfo['role'],
          message: 'Authenticated',
          token: await _authService.getToken(),
        );
        emit(AuthSuccess(userData));
      }
    }
  }

  Future<void> login(String email, String password) async {
    emit(const AuthLoading());

    try {
      final userData = await _authService.login(email, password);
      emit(AuthSuccess(userData));
      
    
      final userInfoPrinter = UserInfoPrinter(
        authService: _authService,
        storage: SecureStorageService(),
      );
      await userInfoPrinter.printUserInfo();
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    emit(const AuthInitial());
  }
  

  Future<String?> getToken() async {
    return await _authService.getToken();
  }
}






