import 'package:flutter_test/flutter_test.dart';
import 'package:helppsico_mobile/domain/entities/user_model.dart';
import 'package:helppsico_mobile/domain/entities/psicologo_entity.dart';

void main() {
  group('User Model Tests', () {
    late Map<String, dynamic> validUserJson;
    late Map<String, dynamic> userJsonWithPsicologo;
    late Psicologo testPsicologo;

    setUp(() {
      testPsicologo = Psicologo(
        id: 'psi123',
        nome: 'Dr. João Silva',
        crp: '12345',
      );

      validUserJson = {
        'id': '123',
        'name': 'João Silva',
        'email': 'joao@email.com',
        'role': 'PACIENTE',
        'cpf': '12345678901',
        'telefone': '11999999999',
        'dataNascimento': '1990-01-01',
        'endereco': 'Rua A, 123',
      };

      userJsonWithPsicologo = {
        ...validUserJson,
        'psicologo': {
          'id': 'psi123',
          'nome': 'Dr. João Silva',
          'crp': '12345',
        },
      };
    });

    test('should create User instance with required fields', () {
      final user = User(
        id: '123',
        name: 'João Silva',
        email: 'joao@email.com',
        password: 'password123',
        role: 'PACIENTE',
      );

      expect(user.id, '123');
      expect(user.name, 'João Silva');
      expect(user.email, 'joao@email.com');
      expect(user.password, 'password123');
      expect(user.role, 'PACIENTE');
      expect(user.cpf, isNull);
      expect(user.telefone, isNull);
      expect(user.dataNascimento, isNull);
      expect(user.endereco, isNull);
      expect(user.psicologo, isNull);
    });

    test('should create User instance with all fields', () {
      final user = User(
        id: '123',
        name: 'João Silva',
        email: 'joao@email.com',
        password: 'password123',
        role: 'PACIENTE',
        cpf: '12345678901',
        telefone: '11999999999',
        dataNascimento: '1990-01-01',
        endereco: 'Rua A, 123',
        psicologo: testPsicologo,
      );

      expect(user.id, '123');
      expect(user.name, 'João Silva');
      expect(user.email, 'joao@email.com');
      expect(user.password, 'password123');
      expect(user.role, 'PACIENTE');
      expect(user.cpf, '12345678901');
      expect(user.telefone, '11999999999');
      expect(user.dataNascimento, '1990-01-01');
      expect(user.endereco, 'Rua A, 123');
      expect(user.psicologo, testPsicologo);
    });

    test('should create User from valid JSON', () {
      final user = User.fromJson(validUserJson);

      expect(user.id, '123');
      expect(user.name, 'João Silva');
      expect(user.email, 'joao@email.com');
      expect(user.password, '');
      expect(user.role, 'PACIENTE');
      expect(user.cpf, '12345678901');
      expect(user.telefone, '11999999999');
      expect(user.dataNascimento, '1990-01-01');
      expect(user.endereco, 'Rua A, 123');
      expect(user.psicologo, isNull);
    });

    test('should create User from JSON with psicologo', () {
      final user = User.fromJson(userJsonWithPsicologo);

      expect(user.id, '123');
      expect(user.name, 'João Silva');
      expect(user.email, 'joao@email.com');
      expect(user.password, '');
      expect(user.role, 'PACIENTE');
      expect(user.psicologo, isNotNull);
      expect(user.psicologo!.id, 'psi123');
      expect(user.psicologo!.nome, 'Dr. João Silva');
      expect(user.psicologo!.crp, '12345');
    });

    test('should handle null and missing values in JSON', () {
      final incompleteJson = {
        'id': null,
        'email': null,
        'role': null,
      };

      final user = User.fromJson(incompleteJson);

      expect(user.id, '');
      expect(user.name, '');
      expect(user.email, '');
      expect(user.password, '');
      expect(user.role, 'PACIENTE');
      expect(user.cpf, isNull);
      expect(user.telefone, isNull);
      expect(user.dataNascimento, isNull);
      expect(user.endereco, isNull);
      expect(user.psicologo, isNull);
    });

    test('should convert User to JSON correctly', () {
      final user = User(
        id: '123',
        name: 'João Silva',
        email: 'joao@email.com',
        password: 'password123',
        role: 'PACIENTE',
        cpf: '12345678901',
        telefone: '11999999999',
        dataNascimento: '1990-01-01',
        endereco: 'Rua A, 123',
        psicologo: testPsicologo,
      );

      final json = user.toJson();

      expect(json['id'], '123');
      expect(json['name'], 'João Silva');
      expect(json['email'], 'joao@email.com');
      expect(json['role'], 'PACIENTE');
      expect(json['cpf'], '12345678901');
      expect(json['telefone'], '11999999999');
      expect(json['dataNascimento'], '1990-01-01');
      expect(json['endereco'], 'Rua A, 123');
      expect(json['psicologo'], isNotNull);
    });

    test('should convert User to JSON without optional fields', () {
      final user = User(
        id: '123',
        name: 'João Silva',
        email: 'joao@email.com',
        password: 'password123',
        role: 'PACIENTE',
      );

      final json = user.toJson();

      expect(json['id'], '123');
      expect(json['name'], 'João Silva');
      expect(json['email'], 'joao@email.com');
      expect(json['role'], 'PACIENTE');
      expect(json.containsKey('cpf'), false);
      expect(json.containsKey('telefone'), false);
      expect(json.containsKey('dataNascimento'), false);
      expect(json.containsKey('endereco'), false);
      expect(json.containsKey('psicologo'), false);
    });

    test('should handle numeric id in JSON', () {
      final jsonWithNumericId = {
        ...validUserJson,
        'id': 123,
      };

      final user = User.fromJson(jsonWithNumericId);
      expect(user.id, '123');
    });
  });
}