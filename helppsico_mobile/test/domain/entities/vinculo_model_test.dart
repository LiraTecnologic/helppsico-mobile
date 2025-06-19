import 'package:flutter_test/flutter_test.dart';
import 'package:helppsico_mobile/domain/entities/vinculo_model.dart';

void main() {
  group('VinculoModel Tests', () {
    late Map<String, dynamic> validVinculoJson;
    late Map<String, dynamic> vinculoJsonWithNulls;

    setUp(() {
      validVinculoJson = {
        'id': 'vinculo123',
        'pacienteId': 'pac456',
        'pacienteNome': 'João Silva',
        'psicologoId': 'psi789',
        'psicologoNome': 'Dr. Maria Santos',
        'psicologoCrp': 'CRP 12/34567',
        'valorConsulta': 150.0,
        'fotoUrl': 'https://example.com/photo.jpg',
        'status': 'ATIVO',
      };

      vinculoJsonWithNulls = {
        'id': null,
        'pacienteId': null,
        'pacienteNome': null,
        'psicologoId': null,
        'psicologoNome': null,
        'psicologoCrp': null,
        'valorConsulta': null,
        'fotoUrl': null,
        'status': null,
      };
    });

    test('should create VinculoModel instance with all fields', () {
      final vinculo = VinculoModel(
        id: 'vinculo123',
        pacienteId: 'pac456',
        pacienteNome: 'João Silva',
        psicologoId: 'psi789',
        psicologoNome: 'Dr. Maria Santos',
        psicologoCrp: 'CRP 12/34567',
        valorConsulta: 150.0,
        fotoUrl: 'https://example.com/photo.jpg',
        status: 'ATIVO',
      );

      expect(vinculo.id, 'vinculo123');
      expect(vinculo.pacienteId, 'pac456');
      expect(vinculo.pacienteNome, 'João Silva');
      expect(vinculo.psicologoId, 'psi789');
      expect(vinculo.psicologoNome, 'Dr. Maria Santos');
      expect(vinculo.psicologoCrp, 'CRP 12/34567');
      expect(vinculo.valorConsulta, 150.0);
      expect(vinculo.fotoUrl, 'https://example.com/photo.jpg');
      expect(vinculo.status, 'ATIVO');
    });

    test('should create VinculoModel from valid JSON', () {
      final vinculo = VinculoModel.fromJson(validVinculoJson);

      expect(vinculo.id, 'vinculo123');
      expect(vinculo.pacienteId, 'pac456');
      expect(vinculo.pacienteNome, 'João Silva');
      expect(vinculo.psicologoId, 'psi789');
      expect(vinculo.psicologoNome, 'Dr. Maria Santos');
      expect(vinculo.psicologoCrp, 'CRP 12/34567');
      expect(vinculo.valorConsulta, 150.0);
      expect(vinculo.fotoUrl, 'https://example.com/photo.jpg');
      expect(vinculo.status, 'ATIVO');
    });

    test('should handle null values in JSON', () {
      final vinculo = VinculoModel.fromJson(vinculoJsonWithNulls);

      expect(vinculo.id, '');
      expect(vinculo.pacienteId, '');
      expect(vinculo.pacienteNome, '');
      expect(vinculo.psicologoId, '');
      expect(vinculo.psicologoNome, '');
      expect(vinculo.psicologoCrp, '');
      expect(vinculo.valorConsulta, 0.0);
      expect(vinculo.fotoUrl, '');
      expect(vinculo.status, '');
    });

    test('should handle missing fields in JSON', () {
      final incompleteJson = <String, dynamic>{};
      final vinculo = VinculoModel.fromJson(incompleteJson);

      expect(vinculo.id, '');
      expect(vinculo.pacienteId, '');
      expect(vinculo.pacienteNome, '');
      expect(vinculo.psicologoId, '');
      expect(vinculo.psicologoNome, '');
      expect(vinculo.psicologoCrp, '');
      expect(vinculo.valorConsulta, 0.0);
      expect(vinculo.fotoUrl, '');
      expect(vinculo.status, '');
    });

    test('should handle different numeric types for valorConsulta', () {
      final testCases = [
        {'valorConsulta': 150, 'expected': 150.0},
        {'valorConsulta': 150.5, 'expected': 150.5},
        {'valorConsulta': '200', 'expected': 200.0},
        {'valorConsulta': '250.75', 'expected': 250.75},
        {'valorConsulta': 'invalid', 'expected': 0.0},
      ];

      for (final testCase in testCases) {
        final json = {
          ...validVinculoJson,
          'valorConsulta': testCase['valorConsulta'],
        };
        final vinculo = VinculoModel.fromJson(json);
        expect(vinculo.valorConsulta, testCase['expected']);
      }
    });

    test('should convert VinculoModel to JSON correctly', () {
      final vinculo = VinculoModel(
        id: 'vinculo123',
        pacienteId: 'pac456',
        pacienteNome: 'João Silva',
        psicologoId: 'psi789',
        psicologoNome: 'Dr. Maria Santos',
        psicologoCrp: 'CRP 12/34567',
        valorConsulta: 150.0,
        fotoUrl: 'https://example.com/photo.jpg',
        status: 'ATIVO',
      );

      final json = vinculo.toJson();

      expect(json['id'], 'vinculo123');
      expect(json['pacienteId'], 'pac456');
      expect(json['pacienteNome'], 'João Silva');
      expect(json['psicologoId'], 'psi789');
      expect(json['psicologoNome'], 'Dr. Maria Santos');
      expect(json['psicologoCrp'], 'CRP 12/34567');
      expect(json['valorConsulta'], 150.0);
      expect(json['fotoUrl'], 'https://example.com/photo.jpg');
      expect(json['status'], 'ATIVO');
    });

    test('should convert to JSON and back correctly', () {
      final originalVinculo = VinculoModel(
        id: 'vinculo123',
        pacienteId: 'pac456',
        pacienteNome: 'João Silva',
        psicologoId: 'psi789',
        psicologoNome: 'Dr. Maria Santos',
        psicologoCrp: 'CRP 12/34567',
        valorConsulta: 150.0,
        fotoUrl: 'https://example.com/photo.jpg',
        status: 'ATIVO',
      );

      final json = originalVinculo.toJson();
      final recreatedVinculo = VinculoModel.fromJson(json);

      expect(recreatedVinculo.id, originalVinculo.id);
      expect(recreatedVinculo.pacienteId, originalVinculo.pacienteId);
      expect(recreatedVinculo.pacienteNome, originalVinculo.pacienteNome);
      expect(recreatedVinculo.psicologoId, originalVinculo.psicologoId);
      expect(recreatedVinculo.psicologoNome, originalVinculo.psicologoNome);
      expect(recreatedVinculo.psicologoCrp, originalVinculo.psicologoCrp);
      expect(recreatedVinculo.valorConsulta, originalVinculo.valorConsulta);
      expect(recreatedVinculo.fotoUrl, originalVinculo.fotoUrl);
      expect(recreatedVinculo.status, originalVinculo.status);
    });

    test('should handle empty strings in JSON', () {
      final jsonWithEmptyStrings = {
        'id': '',
        'pacienteId': '',
        'pacienteNome': '',
        'psicologoId': '',
        'psicologoNome': '',
        'psicologoCrp': '',
        'valorConsulta': 0,
        'fotoUrl': '',
        'status': '',
      };

      final vinculo = VinculoModel.fromJson(jsonWithEmptyStrings);

      expect(vinculo.id, '');
      expect(vinculo.pacienteId, '');
      expect(vinculo.pacienteNome, '');
      expect(vinculo.psicologoId, '');
      expect(vinculo.psicologoNome, '');
      expect(vinculo.psicologoCrp, '');
      expect(vinculo.valorConsulta, 0.0);
      expect(vinculo.fotoUrl, '');
      expect(vinculo.status, '');
    });

    test('should handle special characters in strings', () {
      final jsonWithSpecialChars = {
        'id': 'vínculo-123',
        'pacienteId': 'pac@456',
        'pacienteNome': 'João da Silva & Cia',
        'psicologoId': 'psi#789',
        'psicologoNome': 'Dr. María José Santos',
        'psicologoCrp': 'CRP 12/34567-8',
        'valorConsulta': 150.99,
        'fotoUrl': 'https://example.com/photo%20with%20spaces.jpg',
        'status': 'ATIVO/PENDENTE',
      };

      final vinculo = VinculoModel.fromJson(jsonWithSpecialChars);

      expect(vinculo.id, 'vínculo-123');
      expect(vinculo.pacienteId, 'pac@456');
      expect(vinculo.pacienteNome, 'João da Silva & Cia');
      expect(vinculo.psicologoId, 'psi#789');
      expect(vinculo.psicologoNome, 'Dr. María José Santos');
      expect(vinculo.psicologoCrp, 'CRP 12/34567-8');
      expect(vinculo.valorConsulta, 150.99);
      expect(vinculo.fotoUrl, 'https://example.com/photo%20with%20spaces.jpg');
      expect(vinculo.status, 'ATIVO/PENDENTE');
    });

    test('should handle very long strings', () {
      final longString = 'A' * 1000;
      final jsonWithLongStrings = {
        'id': longString,
        'pacienteId': longString,
        'pacienteNome': longString,
        'psicologoId': longString,
        'psicologoNome': longString,
        'psicologoCrp': longString,
        'valorConsulta': 150.0,
        'fotoUrl': longString,
        'status': longString,
      };

      final vinculo = VinculoModel.fromJson(jsonWithLongStrings);

      expect(vinculo.id, longString);
      expect(vinculo.pacienteId, longString);
      expect(vinculo.pacienteNome, longString);
      expect(vinculo.psicologoId, longString);
      expect(vinculo.psicologoNome, longString);
      expect(vinculo.psicologoCrp, longString);
      expect(vinculo.valorConsulta, 150.0);
      expect(vinculo.fotoUrl, longString);
      expect(vinculo.status, longString);
    });

    test('should handle negative valorConsulta', () {
      final jsonWithNegativeValue = {
        ...validVinculoJson,
        'valorConsulta': -50.0,
      };

      final vinculo = VinculoModel.fromJson(jsonWithNegativeValue);
      expect(vinculo.valorConsulta, -50.0);
    });

    test('should handle zero valorConsulta', () {
      final jsonWithZeroValue = {
        ...validVinculoJson,
        'valorConsulta': 0,
      };

      final vinculo = VinculoModel.fromJson(jsonWithZeroValue);
      expect(vinculo.valorConsulta, 0.0);
    });

    test('should handle very large valorConsulta', () {
      final jsonWithLargeValue = {
        ...validVinculoJson,
        'valorConsulta': 999999.99,
      };

      final vinculo = VinculoModel.fromJson(jsonWithLargeValue);
      expect(vinculo.valorConsulta, 999999.99);
    });
  });
}