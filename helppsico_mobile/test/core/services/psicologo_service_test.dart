import 'package:flutter_test/flutter_test.dart';

import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';
import 'package:helppsico_mobile/core/services/psicologo/psicologo_service.dart';
import 'package:helppsico_mobile/core/services/storage/secure_storage_service.dart';
import 'package:mocktail/mocktail.dart';

class MockGenericHttp extends Mock implements IGenericHttp {}

class MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  group('PsicologoService Tests', () {
    late PsicologoService psicologoService;
    late MockGenericHttp mockHttp;
    late MockSecureStorageService mockStorage;
    
    setUp(() {
      mockHttp = MockGenericHttp();
      mockStorage = MockSecureStorageService();
      psicologoService = PsicologoService(mockHttp, mockStorage);
    });
    
    tearDown(() {
      // Limpar registros do GetIt se necessário
      // GetIt.instance.reset();
    });
    
    test('should create instance with dependencies', () {
      expect(psicologoService, isNotNull);
      expect(psicologoService, isA<PsicologoService>());
    });

    group('getPsicologoByPacienteId', () {
      test('should return psicologo data when API call is successful', () async {
        // Arrange
        const pacienteId = '123';
        const token = 'test-token';
        final responseBody = {
          'dado': {
            'content': [
              {
                'psicologo': {
                  'id': '456',
                  'nome': 'Dr. João Silva',
                  'crp': '12345-SP'
                }
              }
            ]
          }
        };
        
        // Mock token retrieval
        when(() => mockStorage.getToken())
            .thenAnswer((_) async => token);
        
        // Mock HTTP response
        when(() => mockHttp.get(
              'http://localhost:8080/vinculos/listar/paciente/$pacienteId',
              headers: {'Authorization': 'Bearer $token'}
            ))
            .thenAnswer((_) async => HttpResponse(
                  statusCode: 200,
                  body: responseBody,
                ));
        
        // Act
        final result = await psicologoService.getPsicologoByPacienteId(pacienteId);
        
        // Assert
        expect(result, isNotNull);
        expect(result!['id'], '456');
        expect(result['nome'], 'Dr. João Silva');
        expect(result['crp'], '12345-SP');
        
        // Verify interactions
        verify(() => mockStorage.getToken()).called(1);
        verify(() => mockHttp.get(
              'http://localhost:8080/vinculos/listar/paciente/$pacienteId',
              headers: {'Authorization': 'Bearer $token'}
            )).called(1);
      });
      
      test('should return null when token is null', () async {
        // Arrange
        const pacienteId = '123';
        
        // Mock token retrieval to return null
        when(() => mockStorage.getToken())
            .thenAnswer((_) async => null);
        
        // Act
        final result = await psicologoService.getPsicologoByPacienteId(pacienteId);
        
        // Assert
        expect(result, isNull);
        
        // Verify interactions
        verify(() => mockStorage.getToken()).called(1);
        verifyNever(() => mockHttp.get(any(), headers: any(named: 'headers')));
      });
      
      test('should return null when API returns non-200 status code', () async {
        // Arrange
        const pacienteId = '123';
        const token = 'test-token';
        
        // Mock token retrieval
        when(() => mockStorage.getToken())
            .thenAnswer((_) async => token);
        
        // Mock HTTP response with error
        when(() => mockHttp.get(
              'http://localhost:8080/vinculos/listar/paciente/$pacienteId',
              headers: {'Authorization': 'Bearer $token'}
            ))
            .thenAnswer((_) async => HttpResponse(
                  statusCode: 404,
                  body: {'error': 'Not found'},
                ));
        
        // Act
        final result = await psicologoService.getPsicologoByPacienteId(pacienteId);
        
        // Assert
        expect(result, isNull);
        
        // Verify interactions
        verify(() => mockStorage.getToken()).called(1);
        verify(() => mockHttp.get(
              'http://localhost:8080/vinculos/listar/paciente/$pacienteId',
              headers: {'Authorization': 'Bearer $token'}
            )).called(1);
      });
      
      test('should return null when API returns empty content', () async {
        // Arrange
        const pacienteId = '123';
        const token = 'test-token';
        final responseBody = {
          'dado': {
            'content': []
          }
        };
        
        // Mock token retrieval
        when(() => mockStorage.getToken())
            .thenAnswer((_) async => token);
        
        // Mock HTTP response with empty content
        when(() => mockHttp.get(
              'http://localhost:8080/vinculos/listar/paciente/$pacienteId',
              headers: {'Authorization': 'Bearer $token'}
            ))
            .thenAnswer((_) async => HttpResponse(
                  statusCode: 200,
                  body: responseBody,
                ));
        
        // Act
        final result = await psicologoService.getPsicologoByPacienteId(pacienteId);
        
        // Assert
        expect(result, isNull);
        
        // Verify interactions
        verify(() => mockStorage.getToken()).called(1);
        verify(() => mockHttp.get(
              'http://localhost:8080/vinculos/listar/paciente/$pacienteId',
              headers: {'Authorization': 'Bearer $token'}
            )).called(1);
      });
      
      test('should handle missing fields in psicologo data', () async {
        // Arrange
        const pacienteId = '123';
        const token = 'test-token';
        final responseBody = {
          'dado': {
            'content': [
              {
                'psicologo': {
                  'id': '456',
                  // nome está ausente
                  // crp está ausente
                }
              }
            ]
          }
        };
        
        // Mock token retrieval
        when(() => mockStorage.getToken())
            .thenAnswer((_) async => token);
        
        // Mock HTTP response
        when(() => mockHttp.get(
              'http://localhost:8080/vinculos/listar/paciente/$pacienteId',
              headers: {'Authorization': 'Bearer $token'}
            ))
            .thenAnswer((_) async => HttpResponse(
                  statusCode: 200,
                  body: responseBody,
                ));
        
        // Act
        final result = await psicologoService.getPsicologoByPacienteId(pacienteId);
        
        // Assert
        expect(result, isNotNull);
        expect(result!['id'], '456');
        expect(result['nome'], '');
        expect(result['crp'], '');
      });
    });
  });
}