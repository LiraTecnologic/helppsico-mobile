import 'package:flutter_test/flutter_test.dart';
import 'package:helppsico_mobile/domain/entities/user_model.dart';

void main() {
  group('User Model', () {
   
    final userId = 'user123';
    final userName = 'John Doe';
    final userEmail = 'john@example.com';
    final userPassword = 'password123';
    final userRole = 'patient';

    late User user;

    setUp(() {
     
      user = User(
        id: userId,
        name: userName,
        email: userEmail,
        password: userPassword,
        role: userRole,
      );
    });

    
    test('should create a valid User instance with correct properties', () {
      
      expect(user.id, equals(userId));
      expect(user.name, equals(userName));
      expect(user.email, equals(userEmail));
      expect(user.password, equals(userPassword));
      expect(user.role, equals(userRole));
    });

   
    test('should convert User to JSON correctly', () {
      
      final json = user.toJson();

      
      expect(json, isA<Map<String, dynamic>>());
      expect(json['id'], equals(userId));
      expect(json['name'], equals(userName));
      expect(json['email'], equals(userEmail));
      expect(json['role'], equals(userRole));
    });
    
    test('should not include password in JSON', () {
      
      final json = user.toJson();

      
      expect(json.containsKey('password'), isFalse);
    });

   
    test('should handle different values correctly', () {
      
      final adminUser = User(
        id: 'admin456',
        name: 'Admin User',
        email: 'admin@example.com',
        password: 'admin_password',
        role: 'admin',
      );

      
      expect(adminUser.id, 'admin456');
      expect(adminUser.name, 'Admin User');
      expect(adminUser.email, 'admin@example.com');
      expect(adminUser.password, 'admin_password');
      expect(adminUser.role, 'admin');
    });

    
    test('should handle empty string values', () {
     
      final emptyUser = User(
        id: '',
        name: '',
        email: '',
        password: '',
        role: '',
      );

   
      final json = emptyUser.toJson();

     
      expect(emptyUser.id, '');
      expect(emptyUser.name, '');
      expect(emptyUser.email, '');
      expect(emptyUser.password, '');
      expect(emptyUser.role, '');
      
      expect(json['id'], '');
      expect(json['name'], '');
      expect(json['email'], '');
      expect(json['role'], '');
    });
  });
}