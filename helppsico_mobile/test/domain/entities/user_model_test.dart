import 'package:flutter_test/flutter_test.dart';
import 'package:helppsico_mobile/domain/entities/user_model.dart';

void main() {
  final tUser = User(
    id: 'user123',
    name: 'Test User',
    email: 'test@example.com',
    password: 'password123',
    role: 'patient',
  );

  final tUserJson = {
    'id': 'user123',
    'name': 'Test User',
    'email': 'test@example.com',
    'role': 'patient',
   
  };

  group('User', () {
    test('should correctly instantiate a User object', () {
    
      expect(tUser.id, 'user123');
      expect(tUser.name, 'Test User');
      expect(tUser.email, 'test@example.com');
      expect(tUser.password, 'password123');
      expect(tUser.role, 'patient');
    });

    test('should convert a User object to a JSON map', () {
    
      final result = tUser.toJson();

      expect(result, tUserJson);
    });

    
    test('two instances with the same values should not be equal by default', () {
      final anotherUser = User(
        id: 'user123',
        name: 'Test User',
        email: 'test@example.com',
        password: 'password123',
        role: 'patient',
      );
      expect(tUser == anotherUser, isFalse);
    });

    test('an instance should be equal to itself', () {
      expect(tUser == tUser, isTrue);
    });
  });
}