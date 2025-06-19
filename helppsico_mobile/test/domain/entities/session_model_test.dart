import 'package:flutter_test/flutter_test.dart';
import 'package:helppsico_mobile/domain/entities/session_model.dart';

void main() {
  group('SessionModel Tests', () {
    late Map<String, dynamic> validSessionJson;
    late Map<String, dynamic> sessionJsonWithPsicologoId;
    late Map<String, dynamic> sessionJsonWithBooleanFinalizada;
    late Map<String, dynamic> sessionJsonWithStringFinalizada;

    setUp(() {
      validSessionJson = {
        'id': '123',
        'psicologoName': 'Dr. João Silva',
        'pacienteId': '456',
        'data': '2024-01-15T10:00:00.000Z',
        'valor': '150.00',
        'endereco': 'Rua A, 123',
        'finalizada': true,
      };

      sessionJsonWithPsicologoId = {
        'id': '123',
        'psicologoId': 'Dr. Maria Santos',
        'pacienteId': '456',
        'data': '2024-01-15T10:00:00.000Z',
        'valor': '150.00',
        'endereco': 'Rua A, 123',
        'finalizada': false,
      };

      sessionJsonWithBooleanFinalizada = {
        'id': '123',
        'psicologoName': 'Dr. João Silva',
        'pacienteId': '456',
        'data': '2024-01-15T10:00:00.000Z',
        'valor': '150.00',
        'endereco': 'Rua A, 123',
        'finalizada': true,
      };

      sessionJsonWithStringFinalizada = {
        'id': '123',
        'psicologoName': 'Dr. João Silva',
        'pacienteId': '456',
        'data': '2024-01-15T10:00:00.000Z',
        'valor': '150.00',
        'endereco': 'Rua A, 123',
        'finalizada': 'true',
      };
    });

    test('should create SessionModel instance with all fields', () {
      final session = SessionModel(
        id: '123',
        psicologoName: 'Dr. João Silva',
        pacienteId: '456',
        data: DateTime.parse('2024-01-15T10:00:00.000Z'),
        valor: '150.00',
        endereco: 'Rua A, 123',
        finalizada: true,
      );

      expect(session.id, '123');
      expect(session.psicologoName, 'Dr. João Silva');
      expect(session.pacienteId, '456');
      expect(session.data, DateTime.parse('2024-01-15T10:00:00.000Z'));
      expect(session.valor, '150.00');
      expect(session.endereco, 'Rua A, 123');
      expect(session.finalizada, true);
    });

    test('should create SessionModel from valid JSON with psicologoName', () {
      final session = SessionModel.fromJson(validSessionJson);

      expect(session.id, '123');
      expect(session.psicologoName, 'Dr. João Silva');
      expect(session.pacienteId, '456');
      expect(session.data, DateTime.parse('2024-01-15T10:00:00.000Z'));
      expect(session.valor, '150.00');
      expect(session.endereco, 'Rua A, 123');
      expect(session.finalizada, true);
    });

    test('should create SessionModel from JSON with psicologoId fallback', () {
      final session = SessionModel.fromJson(sessionJsonWithPsicologoId);

      expect(session.id, '123');
      expect(session.psicologoName, 'Dr. Maria Santos');
      expect(session.pacienteId, '456');
      expect(session.data, DateTime.parse('2024-01-15T10:00:00.000Z'));
      expect(session.valor, '150.00');
      expect(session.endereco, 'Rua A, 123');
      expect(session.finalizada, false);
    });

    test('should handle boolean finalizada field', () {
      final session = SessionModel.fromJson(sessionJsonWithBooleanFinalizada);
      expect(session.finalizada, true);
    });

    test('should handle string finalizada field - true', () {
      final session = SessionModel.fromJson(sessionJsonWithStringFinalizada);
      expect(session.finalizada, true);
    });

    test('should handle string finalizada field - false', () {
      final jsonWithFalseFinalizada = {
        ...sessionJsonWithStringFinalizada,
        'finalizada': 'false',
      };
      final session = SessionModel.fromJson(jsonWithFalseFinalizada);
      expect(session.finalizada, false);
    });

    test('should handle string finalizada field - other values', () {
      final jsonWithOtherFinalizada = {
        ...sessionJsonWithStringFinalizada,
        'finalizada': 'other',
      };
      final session = SessionModel.fromJson(jsonWithOtherFinalizada);
      expect(session.finalizada, false);
    });

    test('should handle null and missing values in JSON', () {
      final incompleteJson = {
        'id': null,
        'data': '2024-01-15T10:00:00.000Z',
      };

      final session = SessionModel.fromJson(incompleteJson);

      expect(session.id, '');
      expect(session.psicologoName, '');
      expect(session.pacienteId, '');
      expect(session.data, DateTime.parse('2024-01-15T10:00:00.000Z'));
      expect(session.valor, '');
      expect(session.endereco, '');
      expect(session.finalizada, false);
    });

    test('should handle numeric id and pacienteId in JSON', () {
      final jsonWithNumericIds = {
        ...validSessionJson,
        'id': 123,
        'pacienteId': 456,
      };

      final session = SessionModel.fromJson(jsonWithNumericIds);
      expect(session.id, '123');
      expect(session.pacienteId, '456');
    });

    test('should handle numeric valor in JSON', () {
      final jsonWithNumericValor = {
        ...validSessionJson,
        'valor': 150.50,
      };

      final session = SessionModel.fromJson(jsonWithNumericValor);
      expect(session.valor, '150.5');
    });

    test('should handle numeric endereco in JSON', () {
      final jsonWithNumericEndereco = {
        ...validSessionJson,
        'endereco': 123,
      };

      final session = SessionModel.fromJson(jsonWithNumericEndereco);
      expect(session.endereco, '123');
    });

    test('should parse date correctly', () {
      final session = SessionModel.fromJson(validSessionJson);
      final expectedDate = DateTime.parse('2024-01-15T10:00:00.000Z');
      expect(session.data, expectedDate);
    });
  });
}