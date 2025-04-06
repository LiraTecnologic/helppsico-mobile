
import 'package:helppsico_mobile/data/models/user_model.dart';

class MockDatabase {
  static final List<User> _users = [
    User(
      id: '1',
      name: 'João Silva',
      email: 'joao12340@gmail.com',
      password: '123456',
      role: 'patient',
    ),
    User(
      id: '2',
      name: 'Maria Santos',
      email: 'maria@example.com',
      password: 'senha456',
      role: 'patient',
    ),
    User(
      id: '3',
      name: 'Pedro Oliveira',
      email: 'pedro@example.com',
      password: 'senha789',
      role: 'patient',
    ),
  ];

  static List<User> get users => _users;
}