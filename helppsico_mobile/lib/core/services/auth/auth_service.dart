
import 'package:helppsico_mobile/data/repositories/mock/mock_database.dart';

class AuthService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    final user = MockDatabase.users.firstWhere(
      (user) => user.email == email && user.password == password,
      orElse: () => throw Exception('Credenciais inválidas'),
    );

    return {
      ...user.toJson(),
      'token': 'fake_jwt_token_${user.id}',
    };
  }
}