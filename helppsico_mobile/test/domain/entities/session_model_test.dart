import 'package:flutter_test/flutter_test.dart';
import 'package:helppsico_mobile/domain/entities/session_model.dart';

void main() {
  final tDateTime = DateTime.parse('2024-07-20T10:00:00Z');
  final tSessionModel = SessionModel(
    id: 'sess123',
    psicologoName: 'Dr. John Doe',
    pacienteId: 'pat456',
    data: tDateTime,
    valor: '150.00',
    endereco: '123 Main St, Anytown',
    finalizada: false,
  );

  final tSessionJson = {
    'id': 'sess123',
    'psicologoName': 'Dr. John Doe',
    'pacienteId': 'pat456',
    'data': '2024-07-20T10:00:00Z',
    'valor': '150.00',
    'endereco': '123 Main St, Anytown',
    'finalizada': false,
  };

  final tSessionJsonWithPsicologoId = {
    'id': 'sess123',
    'psicologoId': 'Dr. John Doe', 
    'pacienteId': 'pat456',
    'data': '2024-07-20T10:00:00Z',
    'valor': '150.00',
    'endereco': '123 Main St, Anytown',
    'finalizada': 'false', 
  };

  group('SessionModel', () {
    test('should create a SessionModel from json', () {
     
      final result = SessionModel.fromJson(tSessionJson);

      expect(result, isA<SessionModel>());
      expect(result.id, tSessionModel.id);
      expect(result.psicologoName, tSessionModel.psicologoName);
      expect(result.pacienteId, tSessionModel.pacienteId);
      expect(result.data, tSessionModel.data);
      expect(result.valor, tSessionModel.valor);
      expect(result.endereco, tSessionModel.endereco);
      expect(result.finalizada, tSessionModel.finalizada);
    });

    test('should create a SessionModel from json with psicologoId and finalizada as string', () {
     
      final result = SessionModel.fromJson(tSessionJsonWithPsicologoId);

      expect(result, isA<SessionModel>());
      expect(result.id, tSessionModel.id);
      expect(result.psicologoName, tSessionModel.psicologoName);
      expect(result.pacienteId, tSessionModel.pacienteId);
      expect(result.data, tSessionModel.data);
      expect(result.valor, tSessionModel.valor);
      expect(result.endereco, tSessionModel.endereco);
      expect(result.finalizada, false); 
    });

    test('should handle null values in json for optional fields gracefully', () {
      final tJsonWithNulls = {
        'id': 'sess124',
        'psicologoName': null, 
        'pacienteId': null,    
        'data': '2024-07-21T10:00:00Z',
        'valor': null,         
        'endereco': null,     
        'finalizada': null,    
      };
      final expectedDate = DateTime.parse('2024-07-21T10:00:00Z');

     
      final result = SessionModel.fromJson(tJsonWithNulls);


      expect(result.id, 'sess124');
      expect(result.psicologoName, ''); 
      expect(result.pacienteId, '');    
      expect(result.data, expectedDate);
      expect(result.valor, '');         
      expect(result.endereco, '');     
      expect(result.finalizada, false); 
    });

    test('should handle finalizada as boolean true', () {
      final tJsonFinalizadaTrue = {
        'id': 'sess125',
        'psicologoName': 'Dr. Jane Roe',
        'pacienteId': 'pat789',
        'data': '2024-07-22T10:00:00Z',
        'valor': '200.00',
        'endereco': '456 Oak St, Anytown',
        'finalizada': true,
      };
     
      final result = SessionModel.fromJson(tJsonFinalizadaTrue);

      expect(result.finalizada, true);
    });

     test('should handle finalizada as string \'true\'', () {
      final tJsonFinalizadaStringTrue = {
        'id': 'sess126',
        'psicologoName': 'Dr. Jane Roe',
        'pacienteId': 'pat789',
        'data': '2024-07-22T10:00:00Z',
        'valor': '200.00',
        'endereco': '456 Oak St, Anytown',
        'finalizada': 'true',
      };
     
      final result = SessionModel.fromJson(tJsonFinalizadaStringTrue);

      expect(result.finalizada, true);
    });

        test('two instances with the same values should not be equal by default', () {
      final anotherSessionModel = SessionModel(
        id: 'sess123',
        psicologoName: 'Dr. John Doe',
        pacienteId: 'pat456',
        data: tDateTime,
        valor: '150.00',
        endereco: '123 Main St, Anytown',
        finalizada: false,
      );
      expect(tSessionModel == anotherSessionModel, isFalse);
    });
  });
}