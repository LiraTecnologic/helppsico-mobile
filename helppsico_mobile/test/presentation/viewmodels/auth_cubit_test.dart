import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:helppsico_mobile/presentation/viewmodels/state/auth_state.dart';
import 'package:helppsico_mobile/presentation/viewmodels/cubit/auth_cubit.dart';
import 'package:helppsico_mobile/core/services/auth/auth_service.dart';

void main() {
  group('AuthState', () {
    test('AuthInitial should be equal', () {
      expect(const AuthInitial(), const AuthInitial());
    });

    test('AuthLoading should be equal', () {
      expect(const AuthLoading(), const AuthLoading());
    });

    test('AuthSuccess should be equal when same data', () {
      const data1 = {'id': '1', 'name': 'Test'};
      const data2 = {'id': '1', 'name': 'Test'};
      expect(const AuthSuccess(data1), const AuthSuccess(data2));
    });

    test('AuthSuccess should not be equal when different data', () {
      const data1 = {'id': '1', 'name': 'Test'};
      const data2 = {'id': '2', 'name': 'Test'};
      expect(const AuthSuccess(data1), isNot(const AuthSuccess(data2)));
    });

    test('AuthFailure should be equal when same message', () {
      expect(const AuthFailure('Error'), const AuthFailure('Error'));
    });

    test('AuthFailure should not be equal when different message', () {
      expect(const AuthFailure('Error1'), isNot(const AuthFailure('Error2')));
    });
  });

  group('AuthCubit', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthSuccess] when login succeeds',
      build: () => AuthCubit(authService: authService),
      act: (cubit) => cubit.login('joao12340@gmail.com', '123456'),
      expect: () => [
        const AuthLoading(),
        isA<AuthSuccess>(),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthFailure] when login fails',
      build: () => AuthCubit(authService: authService),
      act: (cubit) => cubit.login('invalid@email.com', 'wrongpassword'),
      expect: () => [
        const AuthLoading(),
        isA<AuthFailure>(),
      ],
    );

    test('logout emits AuthInitial', () {
      final cubit = AuthCubit(authService: authService);
      cubit.logout();
      expect(cubit.state, const AuthInitial());
    });

    test('AuthSuccess properties return correct values', () {
      const userData = {
        'id': '1',
        'name': 'Test User',
        'email': 'test@example.com',
        'role': 'patient',
        'token': 'fake_token'
      };
      const authSuccess = AuthSuccess(userData);
      
      expect(authSuccess.userName, 'Test User');
      expect(authSuccess.userRole, 'patient');
    });
  });
}