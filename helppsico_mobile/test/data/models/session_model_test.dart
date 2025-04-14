import 'package:flutter_test/flutter_test.dart';
import 'package:helppsico_mobile/domain/entities/session_model.dart';

void main() {
  group('SessionModel', () {
    test('should create SessionModel instance with correct values', () {
      final DateTime testDate = DateTime(2024, 4, 5, 14, 30);
      
      final session = SessionModel(
        id: '1',
        psicologoName: 'Dr. Test',
        pacienteId: 'patient123',
        data: testDate,
        valor: '150.00',
        endereco: 'Test Address',
        finalizada: false,
      );

      expect(session.id, '1');
      expect(session.psicologoName, 'Dr. Test');
      expect(session.pacienteId, 'patient123');
      expect(session.data, testDate);
      expect(session.valor, '150.00');
      expect(session.endereco, 'Test Address');
      expect(session.finalizada, false);
    });

    group('fromJson', () {
      test('should correctly parse JSON with DateTime string', () {
        final json = {
          'id': '1',
          'psicologoId': 'Dr. Test',
          'pacienteId': 'patient123',
          'data': '2024-04-05 14:30:00',
          'valor': '150.00',
          'endereco': 'Test Address',
          'finalizada': 'false',
        };

        final session = SessionModel.fromJson(json);

        expect(session.id, '1');
        expect(session.psicologoName, 'Dr. Test');
        expect(session.pacienteId, 'patient123');
        expect(session.data, DateTime(2024, 4, 5, 14, 30));
        expect(session.valor, '150.00');
        expect(session.endereco, 'Test Address');
        expect(session.finalizada, false);
      });

      test('should correctly parse JSON with finalizada as true', () {
        final json = {
          'id': '1',
          'psicologoId': 'Dr. Test',
          'pacienteId': 'patient123',
          'data': '2024-04-05 14:30:00',
          'valor': '150.00',
          'endereco': 'Test Address',
          'finalizada': 'true',
        };

        final session = SessionModel.fromJson(json);
        expect(session.finalizada, true);
      });

      test('should throw FormatException when date is invalid', () {
        final json = {
          'id': '1',
          'psicologoId': 'Dr. Test',
          'pacienteId': 'patient123',
          'data': 'invalid-date',
          'valor': '150.00',
          'endereco': 'Test Address',
          'finalizada': 'false',
        };

        expect(() => SessionModel.fromJson(json), throwsFormatException);
      });

      test('should throw FormatException when finalizada is invalid', () {
        final json = {
          'id': '1',
          'psicologoId': 'Dr. Test',
          'pacienteId': 'patient123',
          'data': '2024-04-05 14:30:00',
          'valor': '150.00',
          'endereco': 'Test Address',
          'finalizada': 'invalid',
        };

        expect(() => SessionModel.fromJson(json), throwsFormatException);
      });
    });
  });
} 