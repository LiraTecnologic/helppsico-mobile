import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

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
    print('[AuthCubit] Constructor called.');
    print('[AuthCubit] AuthCubit initialized, calling checkAuthStatus.');
    // Verificar se o usuário já está autenticado ao iniciar o cubit
    checkAuthStatus();
  }


  Future<void> checkAuthStatus() async {
    print('[AuthCubit] checkAuthStatus called.');
    final isAuthenticated = await _authService.isAuthenticated();
    print('[AuthCubit] isAuthenticated result: $isAuthenticated');
    
    if (isAuthenticated) {
      print('[AuthCubit] User is authenticated. Fetching user info via AuthService.');
      final userInfo = await _authService.getUserInfo();
      if (userInfo != null) {
        print('[AuthCubit] User info fetched from AuthService: $userInfo');
        final userData = AuthResponse(
          id: userInfo['id'],
          name: userInfo['name'],
          email: userInfo['email'],
          role: userInfo['role'],
          message: 'Authenticated',
          token: await _authService.getToken(),
        );
        print('[AuthCubit] Emitting AuthSuccess with userData: ${userData.email}');
        emit(AuthSuccess(userData));
      } else {
        print('[AuthCubit] User info is null after being authenticated. Emitting AuthInitial.');
        emit(const AuthInitial()); // Or AuthFailure if this is unexpected
      }
    } else {
      print('[AuthCubit] User is not authenticated. Emitting AuthInitial.');
      emit(const AuthInitial());
    }
  }

  Future<void> login(String email, String password) async {
    print('[AuthCubit] login called with email: $email');
    emit(const AuthLoading());
    print('[AuthCubit] Emitted AuthLoading.');
    try {
      print('[AuthCubit] Calling _authService.login for email: $email');
      final userData = await _authService.login(email, password);
      print('[AuthCubit] _authService.login successful. User data: ${userData.email}');
      emit(AuthSuccess(userData));
      print('[AuthCubit] Emitted AuthSuccess for user: ${userData.email}');
      
      print('[AuthCubit] Initializing UserInfoPrinter...');
      final userInfoPrinter = UserInfoPrinter(
        authService: _authService,
        storage: GetIt.instance.get<SecureStorageService>(),
      );
      await userInfoPrinter.printUserInfo();
      print('[AuthCubit] UserInfoPrinter.printUserInfo completed.');
    } catch (e) {
      print('[AuthCubit] Login failed with error: $e');
      emit(AuthFailure(e.toString()));
      print('[AuthCubit] Emitted AuthFailure: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    print('[AuthCubit] logout called.');
    await _authService.logout();
    print('[AuthCubit] _authService.logout completed. Emitting AuthInitial state.');
    emit(const AuthInitial());
  }
  

  Future<String?> getToken() async {
    print('[AuthCubit] getToken called.');
    final token = await _authService.getToken();
    if (token != null && token.length > 10) {
      print('[AuthCubit] Token retrieved: ${token.substring(0, 10)}...'); 
    } else {
      print('[AuthCubit] Token retrieved: $token');
    }
    return token;
  }
}
