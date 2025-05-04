import 'package:flutter_test/flutter_test.dart';
import 'package:helppsico_mobile/core/services/auth/auth_service.dart';
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';
import 'package:mocktail/mocktail.dart';

class MockGenericHttp extends Mock implements IGenericHttp {}

void main() {
  late AuthService authService;
  late MockGenericHttp mockHttp;

  setUp(() {
    mockHttp = MockGenericHttp();
    authService = AuthService(http: mockHttp);
  });

  group('AuthService', () {
    const testEmail = 'test@example.com';
    const testPassword = 'password123';
    const testName = 'test';

    test('login should return AuthResponse on successful authentication', () async {
      when(() => mockHttp.post(
            any(),
            any(),
          )).thenAnswer((_) async => HttpResponse(
            statusCode: 200,
            body: {
              'name': testName,
              'email': testEmail,
              'role': 'patient',
              'message': 'Login successful'
            },
          ));

      final result = await authService.login(testEmail, testPassword);

      expect(result, isA<AuthResponse>());
      expect(result.email, equals(testEmail));
      expect(result.name, equals(testEmail.split('@')[0]));
      expect(result.role, equals('patient'));
      expect(result.message, equals('Login successful'));

      verify(() => mockHttp.post(
            'http://localhost:7000/login',
            {'email': testEmail, 'password': testPassword},
          )).called(1);
    });

    test('login should throw exception on invalid credentials', () async {
      when(() => mockHttp.post(
            any(),
            any(),
          )).thenAnswer((_) async => HttpResponse(
            statusCode: 401,
            body: {'message': 'Invalid credentials'},
          ));

      await expectLater(
        () => authService.login(testEmail, testPassword),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          'Exception: Failed to authenticate: Exception: Invalid credentials',
        )),
      );

      verify(() => mockHttp.post(
            'http://localhost:7000/login',
            {'email': testEmail, 'password': testPassword},
          )).called(1);
    });

    test('login should throw exception on server error', () async {
      when(() => mockHttp.post(
            any(),
            any(),
          )).thenAnswer((_) async => HttpResponse(
            statusCode: 500,
            body: {'message': 'Server error'},
          ));

      expect(
        () => authService.login(testEmail, testPassword),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          'Exception: Failed to authenticate: Exception: Server error',
        )),
      );
    });

    test('login should throw exception on network error', () async {
      when(() => mockHttp.post(
            any(),
            any(),
          )).thenThrow(Exception('Network error'));

      expect(
        () => authService.login(testEmail, testPassword),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          'Exception: Failed to authenticate: Exception: Network error',
        )),
      );
    });

    test('AuthResponse.fromJson should create instance correctly', () {
      final json = {
        'name': 'John Doe',
        'email': 'john@example.com',
        'role': 'admin',
        'message': 'Welcome'
      };

      final response = AuthResponse.fromJson(json);

      expect(response.name, equals('John Doe'));
      expect(response.email, equals('john@example.com'));
      expect(response.role, equals('admin'));
      expect(response.message, equals('Welcome'));
    });
  });
}