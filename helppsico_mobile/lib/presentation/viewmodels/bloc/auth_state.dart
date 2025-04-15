import 'package:helppsico_mobile/core/services/auth/auth_service.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthSuccess extends AuthState {
  final AuthResponse userData;
  const AuthSuccess(this.userData);

  String get userRole => userData.role;
  String get userName => userData.name;
}

class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);
}