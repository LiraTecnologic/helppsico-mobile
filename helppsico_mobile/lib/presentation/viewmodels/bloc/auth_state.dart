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
  final Map<String, dynamic> userData;
  const AuthSuccess(this.userData);

  String get userRole => userData['role'] as String;
  String get userName => userData['name'] as String;
}

class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);
}