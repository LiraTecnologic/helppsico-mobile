import 'package:flutter_test/flutter_test.dart';
import 'package:helppsico_mobile/data/repositories/vinculos_repository.dart';
import 'package:helppsico_mobile/data/datasource/vinculos_datasource.dart';
import 'package:helppsico_mobile/domain/entities/vinculo_model.dart';
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';
import 'package:helppsico_mobile/core/services/storage/secure_storage_service.dart';
import 'package:helppsico_mobile/core/services/auth/auth_service.dart';

// Mock classes
class MockVinculosDataSource implements VinculosDataSource {
  HttpResponse? _mockGetResponse;
  HttpResponse? _mockSolicitarResponse;
  HttpResponse? _mockCancelarResponse;
  Exception? _mockException;
  String? _lastSolicitarPsicologoId;
  String? _lastCancelarVinculoId;
  
  void setMockGetResponse(HttpResponse? response) {
    _mockGetResponse = response;
  }
  
  void setMockSolicitarResponse(HttpResponse? response) {
    _mockSolicitarResponse = response;
  }
  
  void setMockCancelarResponse(HttpResponse? response) {
    _mockCancelarResponse = response;
  }
  
  void setMockException(Exception? exception) {
    _mockException = exception;
  }
  
  String? get lastSolicitarPsicologoId => _lastSolicitarPsicologoId;
  String? get lastCancelarVinculoId => _lastCancelarVinculoId;
  
  @override
  Future<HttpResponse> getVinculoByPacienteId() async {
    if (_mockException != null) {
      throw _mockException!;
    }
    return _mockGetResponse ?? HttpResponse(statusCode: 404, body: {});
  }
  
  @override
  Future<HttpResponse> solicitarVinculo(String psicologoId) async {
    _lastSolicitarPsicologoId = psicologoId;
    if (_mockException != null) {
      throw _mockException!;
    }
    return _mockSolicitarResponse ?? HttpResponse(statusCode: 201, body: {});
  }
  
  @override
  Future<HttpResponse> cancelarVinculo(String vinculoId) async {
    _lastCancelarVinculoId = vinculoId;
    if (_mockException != null) {
      throw _mockException!;
    }
    return _mockCancelarResponse ?? HttpResponse(statusCode: 204, body: {});
  }
  
  @override
  String get baseUrl => 'http://test.com/vinculos';
  
  // Implementações vazias para outros métodos não utilizados nos testes
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class MockGenericHttp implements IGenericHttp {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class MockSecureStorageService implements SecureStorageService {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class MockAuthService implements AuthService {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  group('VinculosRepository Tests', () {
    late VinculosRepository vinculosRepository;
    late MockVinculosDataSource mockDataSource;
    
    setUp(() {
      mockDataSource = MockVinculosDataSource();
      vinculosRepository = VinculosRepository(dataSource: mockDataSource);
    });
    
    group('Constructor', () {
      test('should create repository with provided dataSource', () {
        // Arrange & Act
        final repository = VinculosRepository(dataSource: mockDataSource);
        
        // Assert
        expect(repository, isA<VinculosRepository>());
      });
      
      test('should create repository with default dependencies when not provided', () {
        // Arrange & Act
        final repository = VinculosRepository(
          http: MockGenericHttp(),
          secureStorage: MockSecureStorageService(),
          authService: MockAuthService(),
        );
        
        // Assert
        expect(repository, isA<VinculosRepository>());
      });
    });
    
    group('getVinculoPaciente', () {
      test('should return VinculoModel when response is successful with complete data', () async {
        // Arrange
        final responseBody = {
          'dado': {
            'id': 'vinculo123',
            'status': 'ATIVO',
            'psicologo': {
              'id': 'psi456',
              'nome': 'Dr. Maria Santos',
              'crp': '12345',
              'valorConsulta': 150.0,
              'fotoUrl': 'https://example.com/foto.jpg',
            },
            'paciente': {
              'id': 'pac789',
              'nome': 'João Silva',
            },
          },
        };
        
        mockDataSource.setMockGetResponse(
          HttpResponse(statusCode: 200, body: responseBody)
        );
        
        // Act
        final result = await vinculosRepository.getVinculoPaciente();
        
        // Assert
        expect(result, isA<VinculoModel>());
        expect(result!.id, 'vinculo123');
        expect(result.status, 'ATIVO');
        expect(result.psicologoId, 'psi456');
        expect(result.psicologoNome, 'Dr. Maria Santos');
        expect(result.psicologoCrp, '12345');
        expect(result.valorConsulta, 150.0);
        expect(result.fotoUrl, 'https://example.com/foto.jpg');
        expect(result.pacienteId, 'pac789');
        expect(result.pacienteNome, 'João Silva');
      });
      
      test('should return VinculoModel with default values when data is incomplete', () async {
        // Arrange
        final responseBody = {
          'dado': {
            'id': 'vinculo123',
            'status': 'PENDENTE',
            'psicologo': {
              'nome': 'Dr. Ana Costa',
            },
            'paciente': {},
          },
        };
        
        mockDataSource.setMockGetResponse(
          HttpResponse(statusCode: 200, body: responseBody)
        );
        
        // Act
        final result = await vinculosRepository.getVinculoPaciente();
        
        // Assert
        expect(result, isA<VinculoModel>());
        expect(result!.id, 'vinculo123');
        expect(result.status, 'PENDENTE');
        expect(result.psicologoId, '');
        expect(result.psicologoNome, 'Dr. Ana Costa');
        expect(result.psicologoCrp, '');
        expect(result.valorConsulta, 0.0);
        expect(result.fotoUrl, '');
        expect(result.pacienteId, '');
        expect(result.pacienteNome, '');
      });
      
      test('should return VinculoModel with default values when psicologo and paciente are null', () async {
        // Arrange
        final responseBody = {
          'dado': {
            'id': 'vinculo123',
            'status': 'CANCELADO',
          },
        };
        
        mockDataSource.setMockGetResponse(
          HttpResponse(statusCode: 200, body: responseBody)
        );
        
        // Act
        final result = await vinculosRepository.getVinculoPaciente();
        
        // Assert
        expect(result, isA<VinculoModel>());
        expect(result!.id, 'vinculo123');
        expect(result.status, 'CANCELADO');
        expect(result.psicologoId, '');
        expect(result.psicologoNome, '');
        expect(result.psicologoCrp, '');
        expect(result.valorConsulta, 0.0);
        expect(result.fotoUrl, '');
        expect(result.pacienteId, '');
        expect(result.pacienteNome, '');
      });
      
      test('should handle valorConsulta as string and convert to double', () async {
        // Arrange
        final responseBody = {
          'dado': {
            'id': 'vinculo123',
            'status': 'ATIVO',
            'psicologo': {
              'id': 'psi456',
              'nome': 'Dr. Carlos Lima',
              'valorConsulta': '200.50',
            },
            'paciente': {
              'id': 'pac789',
              'nome': 'Maria Oliveira',
            },
          },
        };
        
        mockDataSource.setMockGetResponse(
          HttpResponse(statusCode: 200, body: responseBody)
        );
        
        // Act
        final result = await vinculosRepository.getVinculoPaciente();
        
        // Assert
        expect(result!.valorConsulta, 200.50);
      });
      
      test('should handle invalid valorConsulta and default to 0.0', () async {
        // Arrange
        final responseBody = {
          'dado': {
            'id': 'vinculo123',
            'status': 'ATIVO',
            'psicologo': {
              'id': 'psi456',
              'nome': 'Dr. Carlos Lima',
              'valorConsulta': 'invalid_value',
            },
            'paciente': {
              'id': 'pac789',
              'nome': 'Maria Oliveira',
            },
          },
        };
        
        mockDataSource.setMockGetResponse(
          HttpResponse(statusCode: 200, body: responseBody)
        );
        
        // Act
        final result = await vinculosRepository.getVinculoPaciente();
        
        // Assert
        expect(result!.valorConsulta, 0.0);
      });
      
      test('should return null when response status is not 200', () async {
        // Arrange
        mockDataSource.setMockGetResponse(
          HttpResponse(statusCode: 404, body: {})
        );
        
        // Act
        final result = await vinculosRepository.getVinculoPaciente();
        
        // Assert
        expect(result, isNull);
      });
      
      test('should return null when response body is null', () async {
        // Arrange
        mockDataSource.setMockGetResponse(
          HttpResponse(statusCode: 200, body: null)
        );
        
        // Act
        final result = await vinculosRepository.getVinculoPaciente();
        
        // Assert
        expect(result, isNull);
      });
      
      test('should return null when response does not contain dado field', () async {
        // Arrange
        final responseBody = {
          'message': 'Vínculo não encontrado',
        };
        
        mockDataSource.setMockGetResponse(
          HttpResponse(statusCode: 200, body: responseBody)
        );
        
        // Act
        final result = await vinculosRepository.getVinculoPaciente();
        
        // Assert
        expect(result, isNull);
      });
      
      test('should return null when dado field is null', () async {
        // Arrange
        final responseBody = {
          'dado': null,
        };
        
        mockDataSource.setMockGetResponse(
          HttpResponse(statusCode: 200, body: responseBody)
        );
        
        // Act
        final result = await vinculosRepository.getVinculoPaciente();
        
        // Assert
        expect(result, isNull);
      });
      
      test('should return null and print error when exception occurs', () async {
        // Arrange
        final exception = Exception('Erro de rede');
        mockDataSource.setMockException(exception);
        
        // Act
        final result = await vinculosRepository.getVinculoPaciente();
        
        // Assert
        expect(result, isNull);
      });
    });
    
    group('solicitarVinculo', () {
      test('should return VinculoModel when request is successful with status 201', () async {
        // Arrange
        const psicologoId = 'psi456';
        final responseBody = {
          'dado': {
            'id': 'vinculo123',
            'status': 'PENDENTE',
            'psicologo': {
              'id': psicologoId,
              'nome': 'Dr. Maria Santos',
              'crp': '12345',
              'valorConsulta': 150.0,
            },
            'paciente': {
              'id': 'pac789',
              'nome': 'João Silva',
            },
          },
        };
        
        mockDataSource.setMockSolicitarResponse(
          HttpResponse(statusCode: 201, body: responseBody)
        );
        
        // Act
        final result = await vinculosRepository.solicitarVinculo(psicologoId);
        
        // Assert
        expect(result, isA<VinculoModel>());
        expect(result!.id, 'vinculo123');
        expect(result.status, 'PENDENTE');
        expect(result.psicologoId, psicologoId);
        expect(mockDataSource.lastSolicitarPsicologoId, psicologoId);
      });
      
      test('should return VinculoModel when request is successful with status 200', () async {
        // Arrange
        const psicologoId = 'psi456';
        final responseBody = {
          'dado': {
            'id': 'vinculo123',
            'status': 'ATIVO',
            'psicologo': {
              'id': psicologoId,
              'nome': 'Dr. Ana Costa',
            },
            'paciente': {
              'id': 'pac789',
              'nome': 'Maria Oliveira',
            },
          },
        };
        
        mockDataSource.setMockSolicitarResponse(
          HttpResponse(statusCode: 200, body: responseBody)
        );
        
        // Act
        final result = await vinculosRepository.solicitarVinculo(psicologoId);
        
        // Assert
        expect(result, isA<VinculoModel>());
        expect(result!.id, 'vinculo123');
        expect(result.status, 'ATIVO');
        expect(mockDataSource.lastSolicitarPsicologoId, psicologoId);
      });
      
      test('should return null when response status is not 200 or 201', () async {
        // Arrange
        const psicologoId = 'psi456';
        
        mockDataSource.setMockSolicitarResponse(
          HttpResponse(statusCode: 400, body: {})
        );
        
        // Act
        final result = await vinculosRepository.solicitarVinculo(psicologoId);
        
        // Assert
        expect(result, isNull);
        expect(mockDataSource.lastSolicitarPsicologoId, psicologoId);
      });
      
      test('should return null when response body is null', () async {
        // Arrange
        const psicologoId = 'psi456';
        
        mockDataSource.setMockSolicitarResponse(
          HttpResponse(statusCode: 201, body: null)
        );
        
        // Act
        final result = await vinculosRepository.solicitarVinculo(psicologoId);
        
        // Assert
        expect(result, isNull);
      });
      
      test('should return null when response does not contain dado field', () async {
        // Arrange
        const psicologoId = 'psi456';
        final responseBody = {
          'message': 'Vínculo criado com sucesso',
        };
        
        mockDataSource.setMockSolicitarResponse(
          HttpResponse(statusCode: 201, body: responseBody)
        );
        
        // Act
        final result = await vinculosRepository.solicitarVinculo(psicologoId);
        
        // Assert
        expect(result, isNull);
      });
      
      test('should throw exception when dataSource throws exception', () async {
        // Arrange
        const psicologoId = 'psi456';
        final exception = Exception('Erro de rede');
        mockDataSource.setMockException(exception);
        
        // Act & Assert
        expect(
          () => vinculosRepository.solicitarVinculo(psicologoId),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Não foi possível solicitar o vínculo'),
          )),
        );
      });
      
      test('should handle special characters in psicologo ID', () async {
        // Arrange
        const psicologoId = 'psi@456#special';
        final responseBody = {
          'dado': {
            'id': 'vinculo123',
            'status': 'PENDENTE',
            'psicologo': {
              'id': psicologoId,
              'nome': 'Dr. José da Silva',
            },
            'paciente': {
              'id': 'pac789',
              'nome': 'Maria José',
            },
          },
        };
        
        mockDataSource.setMockSolicitarResponse(
          HttpResponse(statusCode: 201, body: responseBody)
        );
        
        // Act
        final result = await vinculosRepository.solicitarVinculo(psicologoId);
        
        // Assert
        expect(result!.psicologoId, psicologoId);
        expect(mockDataSource.lastSolicitarPsicologoId, psicologoId);
      });
      
      test('should handle empty psicologo ID', () async {
        // Arrange
        const psicologoId = '';
        final responseBody = {
          'dado': {
            'id': 'vinculo123',
            'status': 'PENDENTE',
            'psicologo': {},
            'paciente': {},
          },
        };
        
        mockDataSource.setMockSolicitarResponse(
          HttpResponse(statusCode: 201, body: responseBody)
        );
        
        // Act
        final result = await vinculosRepository.solicitarVinculo(psicologoId);
        
        // Assert
        expect(result!.psicologoId, '');
        expect(mockDataSource.lastSolicitarPsicologoId, psicologoId);
      });
    });
    
    group('cancelarVinculo', () {
      test('should return true when cancellation is successful with status 204', () async {
        // Arrange
        const vinculoId = 'vinculo123';
        
        mockDataSource.setMockCancelarResponse(
          HttpResponse(statusCode: 204, body: {})
        );
        
        // Act
        final result = await vinculosRepository.cancelarVinculo(vinculoId);
        
        // Assert
        expect(result, true);
        expect(mockDataSource.lastCancelarVinculoId, vinculoId);
      });
      
      test('should return true when cancellation is successful with status 200', () async {
        // Arrange
        const vinculoId = 'vinculo123';
        
        mockDataSource.setMockCancelarResponse(
          HttpResponse(statusCode: 200, body: {})
        );
        
        // Act
        final result = await vinculosRepository.cancelarVinculo(vinculoId);
        
        // Assert
        expect(result, true);
        expect(mockDataSource.lastCancelarVinculoId, vinculoId);
      });
      
      test('should return false when cancellation fails with other status codes', () async {
        // Arrange
        const vinculoId = 'vinculo123';
        
        mockDataSource.setMockCancelarResponse(
          HttpResponse(statusCode: 404, body: {})
        );
        
        // Act
        final result = await vinculosRepository.cancelarVinculo(vinculoId);
        
        // Assert
        expect(result, false);
        expect(mockDataSource.lastCancelarVinculoId, vinculoId);
      });
      
      test('should throw exception when dataSource throws exception', () async {
        // Arrange
        const vinculoId = 'vinculo123';
        final exception = Exception('Erro de rede');
        mockDataSource.setMockException(exception);
        
        // Act & Assert
        expect(
          () => vinculosRepository.cancelarVinculo(vinculoId),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Não foi possível cancelar o vínculo'),
          )),
        );
      });
      
      test('should handle special characters in vinculo ID', () async {
        // Arrange
        const vinculoId = 'vinculo@123#special';
        
        mockDataSource.setMockCancelarResponse(
          HttpResponse(statusCode: 204, body: {})
        );
        
        // Act
        final result = await vinculosRepository.cancelarVinculo(vinculoId);
        
        // Assert
        expect(result, true);
        expect(mockDataSource.lastCancelarVinculoId, vinculoId);
      });
      
      test('should handle empty vinculo ID', () async {
        // Arrange
        const vinculoId = '';
        
        mockDataSource.setMockCancelarResponse(
          HttpResponse(statusCode: 204, body: {})
        );
        
        // Act
        final result = await vinculosRepository.cancelarVinculo(vinculoId);
        
        // Assert
        expect(result, true);
        expect(mockDataSource.lastCancelarVinculoId, vinculoId);
      });
    });
    
    group('_adaptVinculoDtoToModel', () {
      test('should adapt complete vinculo data correctly', () async {
        // Arrange
        final responseBody = {
          'dado': {
            'id': 'vinculo123',
            'status': 'ATIVO',
            'psicologo': {
              'id': 'psi456',
              'nome': 'Dr. Maria Santos',
              'crp': '12345',
              'valorConsulta': 150.0,
              'fotoUrl': 'https://example.com/foto.jpg',
            },
            'paciente': {
              'id': 'pac789',
              'nome': 'João Silva',
            },
          },
        };
        
        mockDataSource.setMockGetResponse(
          HttpResponse(statusCode: 200, body: responseBody)
        );
        
        // Act
        final result = await vinculosRepository.getVinculoPaciente();
        
        // Assert - Testing the private method indirectly
        expect(result!.id, 'vinculo123');
        expect(result.status, 'ATIVO');
        expect(result.psicologoId, 'psi456');
        expect(result.psicologoNome, 'Dr. Maria Santos');
        expect(result.psicologoCrp, '12345');
        expect(result.valorConsulta, 150.0);
        expect(result.fotoUrl, 'https://example.com/foto.jpg');
        expect(result.pacienteId, 'pac789');
        expect(result.pacienteNome, 'João Silva');
      });
      
      test('should handle null and missing fields with default values', () async {
        // Arrange
        final responseBody = {
          'dado': {
            'id': null,
            'status': null,
          },
        };
        
        mockDataSource.setMockGetResponse(
          HttpResponse(statusCode: 200, body: responseBody)
        );
        
        // Act
        final result = await vinculosRepository.getVinculoPaciente();
        
        // Assert - Testing the private method indirectly
        expect(result!.id, '');
        expect(result.status, 'PENDENTE');
        expect(result.psicologoId, '');
        expect(result.psicologoNome, '');
        expect(result.psicologoCrp, '');
        expect(result.valorConsulta, 0.0);
        expect(result.fotoUrl, '');
        expect(result.pacienteId, '');
        expect(result.pacienteNome, '');
      });
      
      test('should convert non-string IDs to string', () async {
        // Arrange
        final responseBody = {
          'dado': {
            'id': 123,
            'status': 'ATIVO',
            'psicologo': {
              'id': 456,
              'nome': 'Dr. Carlos Lima',
            },
            'paciente': {
              'id': 789,
              'nome': 'Ana Costa',
            },
          },
        };
        
        mockDataSource.setMockGetResponse(
          HttpResponse(statusCode: 200, body: responseBody)
        );
        
        // Act
        final result = await vinculosRepository.getVinculoPaciente();
        
        // Assert - Testing the private method indirectly
        expect(result!.id, '123');
        expect(result.psicologoId, '456');
        expect(result.pacienteId, '789');
      });
    });
    
    group('Integration Tests', () {
      test('should handle complete vinculo workflow', () async {
        // Arrange
        const psicologoId = 'psi456';
        const vinculoId = 'vinculo123';
        
        final solicitarResponseBody = {
          'dado': {
            'id': vinculoId,
            'status': 'PENDENTE',
            'psicologo': {
              'id': psicologoId,
              'nome': 'Dr. Maria Santos',
            },
            'paciente': {
              'id': 'pac789',
              'nome': 'João Silva',
            },
          },
        };
        
        final getResponseBody = {
          'dado': {
            'id': vinculoId,
            'status': 'ATIVO',
            'psicologo': {
              'id': psicologoId,
              'nome': 'Dr. Maria Santos',
            },
            'paciente': {
              'id': 'pac789',
              'nome': 'João Silva',
            },
          },
        };
        
        // Act
        // 1. Solicitar vínculo
        mockDataSource.setMockSolicitarResponse(
          HttpResponse(statusCode: 201, body: solicitarResponseBody)
        );
        final solicitarResult = await vinculosRepository.solicitarVinculo(psicologoId);
        
        // 2. Obter vínculo
        mockDataSource.setMockGetResponse(
          HttpResponse(statusCode: 200, body: getResponseBody)
        );
        final getResult = await vinculosRepository.getVinculoPaciente();
        
        // 3. Cancelar vínculo
        mockDataSource.setMockCancelarResponse(
          HttpResponse(statusCode: 204, body: {})
        );
        final cancelarResult = await vinculosRepository.cancelarVinculo(vinculoId);
        
        // Assert
        expect(solicitarResult!.id, vinculoId);
        expect(solicitarResult.status, 'PENDENTE');
        expect(getResult!.id, vinculoId);
        expect(getResult.status, 'ATIVO');
        expect(cancelarResult, true);
        expect(mockDataSource.lastSolicitarPsicologoId, psicologoId);
        expect(mockDataSource.lastCancelarVinculoId, vinculoId);
      });
      
      test('should handle error scenarios in workflow', () async {
        // Arrange
        const psicologoId = 'psi456';
        const vinculoId = 'vinculo123';
        final networkException = Exception('Erro de rede');
        
        // Act & Assert
        // 1. Test solicitar vínculo error
        mockDataSource.setMockException(networkException);
        expect(
          () => vinculosRepository.solicitarVinculo(psicologoId),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Não foi possível solicitar o vínculo'),
          )),
        );
        
        // 2. Test get vínculo error (should return null, not throw)
        final getResult = await vinculosRepository.getVinculoPaciente();
        expect(getResult, isNull);
        
        // 3. Test cancelar vínculo error
        expect(
          () => vinculosRepository.cancelarVinculo(vinculoId),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Não foi possível cancelar o vínculo'),
          )),
        );
      });
    });
  });
}