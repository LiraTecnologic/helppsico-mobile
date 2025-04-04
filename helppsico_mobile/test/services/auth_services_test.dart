import 'package:flutter_test/flutter_test.dart';
import 'package:helppsico_mobile/data/repositories/mock/mock_database.dart';
import 'package:helppsico_mobile/services/auth/auth_service.dart';

void main() {
  late AuthService authService;

  setUp(() {
    authService = AuthService();
  });

  group('AuthService', () {
    group('login', () {
      test('should return user data with token for valid credentials', () async {
     
        const email = 'joao12340@gmail.com';
        const password = '123456';
        final expectedUser = MockDatabase.users.firstWhere(
          (user) => user.email == email && user.password == password,
        );

        
        final result = await authService.login(email, password);

        
        expect(result, isA<Map<String, dynamic>>());
        expect(result['id'], equals(expectedUser.id));
        expect(result['name'], equals(expectedUser.name));
        expect(result['email'], equals(expectedUser.email));
        expect(result['role'], equals(expectedUser.role));
        expect(result['token'], equals('fake_jwt_token_${expectedUser.id}'));
      });

      test('should throw exception for invalid email', () async {
        
        const email = 'invalid@email.com';
        const password = '123456';

        
        expect(
          () => authService.login(email, password),
          throwsA(isA<Exception>()
          .having((e) => e.toString(),"message",  contains('Credenciais inválidas'))
          ),
        );
      });

      test('should throw exception for invalid password', () async {
  
        const email = 'joao12340@gmail.com';
        const password = 'wrongpassword';

 
        expect(
          () => authService.login(email, password),
          throwsA(
          isA<Exception>()
          .having((e) => e.toString(), "message", contains('Credenciais inválidas'))
          ),
        );
      });

      test('should simulate network delay', () async {

        const email = 'joao12340@gmail.com';
        const password = '123456';
        final stopwatch = Stopwatch();


        stopwatch.start();
        await authService.login(email, password);
        stopwatch.stop();

     

        expect(stopwatch.elapsed.inSeconds, greaterThanOrEqualTo(1));
      });
    });
  });
}