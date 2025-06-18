import 'package:flutter_test/flutter_test.dart';
import 'package:helppsico_mobile/data/datasource/review_datasource.dart';
import 'package:helppsico_mobile/domain/entities/review_entity.dart';
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';
import 'package:helppsico_mobile/core/services/storage/secure_storage_service.dart';
import 'package:helppsico_mobile/core/services/auth/auth_service.dart';

// Mock classes
class MockGenericHttp implements IGenericHttp {
  final Map<String, HttpResponse> _responses = {};
  final List<String> _getRequests = [];
  final List<Map<String, dynamic>> _postRequests = [];
  
  void setResponse(String url, HttpResponse response) {
    _responses[url] = response;
  }
  
  List<String> get getRequests => _getRequests;
  List<Map<String, dynamic>> get postRequests => _postRequests;
  
  @override
  Future<HttpResponse> get(String url, {Map<String, String>? headers}) async {
    _getRequests.add(url);
    return _responses[url] ?? HttpResponse(statusCode: 404, body: {});
  }
  
  @override
  Future<HttpResponse> post(String url,dynamic body, {Map<String, String>? headers}) async {
    _postRequests.add(body);
    return _responses[url] ?? HttpResponse(statusCode: 201, body: {});
  }
  
  @override
  Future<HttpResponse> delete(String url, {Map<String, String>? headers}) async {
    return HttpResponse(statusCode: 204, body: {});
  }
  
  @override
  Future<HttpResponse> put(String url, dynamic  body, {Map<String, String>? headers}) async {
    return HttpResponse(statusCode: 200, body: {});
  }
}

class MockSecureStorageService implements SecureStorageService {
  String? _mockUserId;
  
  void setMockUserId(String? userId) {
    _mockUserId = userId;
  }
  
  @override
  Future<String?> getUserId() async {
    return _mockUserId;
  }
  
  // Implementações vazias para outros métodos não utilizados nos testes
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class MockAuthService implements AuthService {
  Map<String, dynamic>? _mockUserInfo;
  Exception? _mockException;
  
  void setMockUserInfo(Map<String, dynamic>? userInfo) {
    _mockUserInfo = userInfo;
  }
  
  void setMockException(Exception? exception) {
    _mockException = exception;
  }
  
  @override
  Future<Map<String, dynamic>?> getUserInfo() async {
    if (_mockException != null) {
      throw _mockException!;
    }
    return _mockUserInfo;
  }
  
  // Implementações vazias para outros métodos não utilizados nos testes
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  group('ReviewDataSource Tests', () {
    late ReviewDataSource reviewDataSource;
    late MockGenericHttp mockHttp;
    late MockSecureStorageService mockSecureStorage;
    late MockAuthService mockAuthService;
    
    setUp(() {
      mockHttp = MockGenericHttp();
      mockSecureStorage = MockSecureStorageService();
      mockAuthService = MockAuthService();
      reviewDataSource = ReviewDataSource(
        mockHttp,
        mockSecureStorage,
        mockAuthService,
      );
    });
    
    group('baseUrl', () {
      test('should return correct base URL', () {
        // Act
        final baseUrl = reviewDataSource.baseUrl;
        
        // Assert
        expect(baseUrl, 'http://10.0.2.2:8080');
      });
    });
    
    group('_getPacienteId', () {
      test('should return user ID from secure storage when available', () async {
        // Arrange
        const expectedUserId = '123';
        mockSecureStorage.setMockUserId(expectedUserId);
        
        // Act
        final psicologoInfo = await reviewDataSource.getPsicologoInfo();
        
        // Assert - Verifica se foi feita requisição com o ID correto
        expect(mockHttp.getRequests.any((url) => url.contains(expectedUserId)), true);
      });
      
      test('should get user ID from auth service when not in storage', () async {
        // Arrange
        const expectedUserId = '456';
        mockSecureStorage.setMockUserId(null);
        mockAuthService.setMockUserInfo({'id': expectedUserId});
        mockHttp.setResponse('http://10.0.2.2:8080/vinculos/listar/paciente/$expectedUserId', 
          HttpResponse(statusCode: 200, body: {}));
        
        // Act
        await reviewDataSource.getPsicologoInfo();
        
        // Assert
        expect(mockHttp.getRequests.any((url) => url.contains(expectedUserId)), true);
      });
      
      test('should return empty string when user ID not found', () async {
        // Arrange
        mockSecureStorage.setMockUserId(null);
        mockAuthService.setMockUserInfo(null);
        
        // Act
        final psicologoInfo = await reviewDataSource.getPsicologoInfo();
        
        // Assert
        expect(psicologoInfo, null);
      });
      
      test('should handle auth service exception', () async {
        // Arrange
        mockSecureStorage.setMockUserId(null);
        mockAuthService.setMockException(Exception('Auth error'));
        
        // Act
        final psicologoInfo = await reviewDataSource.getPsicologoInfo();
        
        // Assert
        expect(psicologoInfo, null);
      });
      
      test('should return empty string when user ID is empty', () async {
        // Arrange
        mockSecureStorage.setMockUserId('');
        
        // Act
        final psicologoInfo = await reviewDataSource.getPsicologoInfo();
        
        // Assert
        expect(psicologoInfo, null);
      });
    });
    
    group('getPsicologoInfo', () {
      test('should return psicologo info when vinculo exists', () async {
        // Arrange
        const pacienteId = '123';
        const psicologoId = '456';
        const psicologoNome = 'Dr. João Silva';
        
        final responseBody = {
          'dado': {
            'content': [
              {
                'psicologo': {
                  'id': psicologoId,
                  'nome': psicologoNome,
                }
              }
            ]
          }
        };
        
        mockSecureStorage.setMockUserId(pacienteId);
        mockHttp.setResponse('http://10.0.2.2:8080/vinculos/listar/paciente/$pacienteId', 
          HttpResponse(statusCode: 200, body: responseBody));
        
        // Act
        final psicologoInfo = await reviewDataSource.getPsicologoInfo();
        
        // Assert
        expect(psicologoInfo, isNotNull);
        expect(psicologoInfo!['id'], psicologoId);
        expect(psicologoInfo['nome'], psicologoNome);
      });
      
      test('should return null when no vinculo exists', () async {
        // Arrange
        const pacienteId = '123';
        final responseBody = {
          'dado': {
            'content': []
          }
        };
        
        mockSecureStorage.setMockUserId(pacienteId);
        mockHttp.setResponse('http://10.0.2.2:8080/vinculos/listar/paciente/$pacienteId', 
          HttpResponse(statusCode: 200, body: responseBody));
        
        // Act
        final psicologoInfo = await reviewDataSource.getPsicologoInfo();
        
        // Assert
        expect(psicologoInfo, null);
      });
      
      test('should return null when response format is invalid', () async {
        // Arrange
        const pacienteId = '123';
        final responseBody = {'invalid': 'format'};
        
        mockSecureStorage.setMockUserId(pacienteId);
        mockHttp.setResponse('http://10.0.2.2:8080/vinculos/listar/paciente/$pacienteId', 
          HttpResponse(statusCode: 200, body: responseBody));
        
        // Act
        final psicologoInfo = await reviewDataSource.getPsicologoInfo();
        
        // Assert
        expect(psicologoInfo, null);
      });
      
      test('should return null when psicologo data is incomplete', () async {
        // Arrange
        const pacienteId = '123';
        final responseBody = {
          'dado': {
            'content': [
              {
                'psicologo': {
                  'id': null,
                  'nome': 'Dr. João Silva',
                }
              }
            ]
          }
        };
        
        mockSecureStorage.setMockUserId(pacienteId);
        mockHttp.setResponse('http://10.0.2.2:8080/vinculos/listar/paciente/$pacienteId', 
          HttpResponse(statusCode: 200, body: responseBody));
        
        // Act
        final psicologoInfo = await reviewDataSource.getPsicologoInfo();
        
        // Assert
        expect(psicologoInfo, null);
      });
      
      test('should return null when HTTP request fails', () async {
        // Arrange
        const pacienteId = '123';
        mockSecureStorage.setMockUserId(pacienteId);
        mockHttp.setResponse('http://10.0.2.2:8080/vinculos/listar/paciente/$pacienteId', 
          HttpResponse(statusCode: 500, body: {}));
        
        // Act
        final psicologoInfo = await reviewDataSource.getPsicologoInfo();
        
        // Assert
        expect(psicologoInfo, null);
      });
      
      test('should handle exception gracefully', () async {
        // Arrange
        mockSecureStorage.setMockUserId(null);
        mockAuthService.setMockException(Exception('Network error'));
        
        // Act
        final psicologoInfo = await reviewDataSource.getPsicologoInfo();
        
        // Assert
        expect(psicologoInfo, null);
      });
    });
    
    group('getReviewsByPsicologoId', () {
      test('should return list of reviews for valid psicologo ID', () async {
        // Arrange
        const psicologoId = '456';
        final responseBody = {
          'dado': {
            'content': [
              {
                'id': 'review1',
                'psicologo': {'id': psicologoId, 'nome': 'Dr. João'},
                'paciente': {'id': '123', 'nome': 'Maria'},
                'nota': 5,
                'comentario': 'Excelente profissional',
                'dataAvaliacao': '2024-01-15T10:00:00.000Z',
              },
              {
                'id': 'review2',
                'psicologo': {'id': psicologoId, 'nome': 'Dr. João'},
                'paciente': {'id': '124', 'nome': 'José'},
                'nota': 4,
                'comentario': 'Muito bom',
                'dataAvaliacao': '2024-01-16T10:00:00.000Z',
              },
            ]
          }
        };
        
        mockHttp.setResponse('http://10.0.2.2:8080/avaliacoes/psicologo/$psicologoId', 
          HttpResponse(statusCode: 200, body: responseBody));
        
        // Act
        final reviews = await reviewDataSource.getReviewsByPsicologoId(psicologoId);
        
        // Assert
        expect(reviews, isA<List<ReviewEntity>>());
        expect(reviews.length, 2);
        expect(reviews[0].id, 'review1');
        expect(reviews[0].rating, 5);
        expect(reviews[0].comment, 'Excelente profissional');
        expect(reviews[1].id, 'review2');
        expect(reviews[1].rating, 4);
      });
      
      test('should return empty list when no reviews exist', () async {
        // Arrange
        const psicologoId = '456';
        final responseBody = {
          'dado': {
            'content': []
          }
        };
        
        mockHttp.setResponse('http://10.0.2.2:8080/avaliacoes/psicologo/$psicologoId', 
          HttpResponse(statusCode: 200, body: responseBody));
        
        // Act
        final reviews = await reviewDataSource.getReviewsByPsicologoId(psicologoId);
        
        // Assert
        expect(reviews, isA<List<ReviewEntity>>());
        expect(reviews.length, 0);
      });
      
      test('should throw exception when response format is invalid', () async {
        // Arrange
        const psicologoId = '456';
        final responseBody = {'invalid': 'format'};
        
        mockHttp.setResponse('http://10.0.2.2:8080/avaliacoes/psicologo/$psicologoId', 
          HttpResponse(statusCode: 200, body: responseBody));
        
        // Act & Assert
        expect(
          () => reviewDataSource.getReviewsByPsicologoId(psicologoId),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Formato de resposta inválido'),
          )),
        );
      });
      
      test('should throw exception when response is null', () async {
        // Arrange
        const psicologoId = '456';
        
        mockHttp.setResponse('http://10.0.2.2:8080/avaliacoes/psicologo/$psicologoId', 
          HttpResponse(statusCode: 200, body: null));
        
        // Act & Assert
        expect(
          () => reviewDataSource.getReviewsByPsicologoId(psicologoId),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Formato de resposta inválido'),
          )),
        );
      });
      
      test('should throw exception with error message from response', () async {
        // Arrange
        const psicologoId = '456';
        final responseBody = {'mensagem': 'Psicólogo não encontrado'};
        
        mockHttp.setResponse('http://10.0.2.2:8080/avaliacoes/psicologo/$psicologoId', 
          HttpResponse(statusCode: 404, body: responseBody));
        
        // Act & Assert
        expect(
          () => reviewDataSource.getReviewsByPsicologoId(psicologoId),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Psicólogo não encontrado'),
          )),
        );
      });
      
      test('should throw exception with default message when no error message', () async {
        // Arrange
        const psicologoId = '456';
        
        mockHttp.setResponse('http://10.0.2.2:8080/avaliacoes/psicologo/$psicologoId', 
          HttpResponse(statusCode: 500, body: {}));
        
        // Act & Assert
        expect(
          () => reviewDataSource.getReviewsByPsicologoId(psicologoId),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Falha ao carregar avaliações'),
          )),
        );
      });
      
      test('should handle network connection error', () async {
        // Arrange
        const psicologoId = '456';
        
        // Não definir resposta para simular erro de conexão
        
        // Act & Assert
        expect(
          () => reviewDataSource.getReviewsByPsicologoId(psicologoId),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Erro de conexão'),
          )),
        );
      });
    });
    
    group('_adaptAvaliacaoToReviewEntity', () {
      test('should correctly adapt complete review data', () async {
        // Arrange
        const psicologoId = '456';
        final responseBody = {
          'dado': {
            'content': [
              {
                'id': 'review1',
                'psicologo': {
                  'id': 456,
                  'nome': 'Dr. João Silva',
                  'crp': '12345',
                },
                'paciente': {
                  'id': 123,
                  'nome': 'Maria Santos',
                },
                'nota': 5,
                'comentario': 'Excelente profissional, muito atencioso',
                'dataAvaliacao': '2024-01-15T10:30:00.000Z',
              },
            ]
          }
        };
        
        mockHttp.setResponse('http://10.0.2.2:8080/avaliacoes/psicologo/$psicologoId', 
          HttpResponse(statusCode: 200, body: responseBody));
        
        // Act
        final reviews = await reviewDataSource.getReviewsByPsicologoId(psicologoId);
        
        // Assert
        expect(reviews.length, 1);
        final review = reviews[0];
        expect(review.id, 'review1');
        expect(review.psicologoId, '456');
        expect(review.pacienteId, '123');
        expect(review.userName, 'Maria Santos');
        expect(review.rating, 5);
        expect(review.comment, 'Excelente profissional, muito atencioso');
        expect(review.date, '2024-01-15T10:30:00.000Z');
      });
      
      test('should handle missing or null psicologo data', () async {
        // Arrange
        const psicologoId = '456';
        final responseBody = {
          'dado': {
            'content': [
              {
                'id': 'review1',
                'psicologo': null,
                'paciente': {'id': 123, 'nome': 'Maria'},
                'nota': 4,
                'comentario': 'Bom',
                'dataAvaliacao': '2024-01-15T10:00:00.000Z',
              },
            ]
          }
        };
        
        mockHttp.setResponse('http://10.0.2.2:8080/avaliacoes/psicologo/$psicologoId', 
          HttpResponse(statusCode: 200, body: responseBody));
        
        // Act
        final reviews = await reviewDataSource.getReviewsByPsicologoId(psicologoId);
        
        // Assert
        expect(reviews.length, 1);
        expect(reviews[0].psicologoId, '');
      });
      
      test('should handle missing or null paciente data', () async {
        // Arrange
        const psicologoId = '456';
        final responseBody = {
          'dado': {
            'content': [
              {
                'id': 'review1',
                'psicologo': {'id': 456, 'nome': 'Dr. João'},
                'paciente': null,
                'nota': 4,
                'comentario': 'Bom',
                'dataAvaliacao': '2024-01-15T10:00:00.000Z',
              },
            ]
          }
        };
        
        mockHttp.setResponse('http://10.0.2.2:8080/avaliacoes/psicologo/$psicologoId', 
          HttpResponse(statusCode: 200, body: responseBody));
        
        // Act
        final reviews = await reviewDataSource.getReviewsByPsicologoId(psicologoId);
        
        // Assert
        expect(reviews.length, 1);
        expect(reviews[0].pacienteId, '');
        expect(reviews[0].userName, '');
      });
      
      test('should handle missing fields with defaults', () async {
        // Arrange
        const psicologoId = '456';
        final responseBody = {
          'dado': {
            'content': [
              {
                // Missing id, nota, comentario, dataAvaliacao
                'psicologo': {'id': 456, 'nome': 'Dr. João'},
                'paciente': {'id': 123, 'nome': 'Maria'},
              },
            ]
          }
        };
        
        mockHttp.setResponse('http://10.0.2.2:8080/avaliacoes/psicologo/$psicologoId', 
          HttpResponse(statusCode: 200, body: responseBody));
        
        // Act
        final reviews = await reviewDataSource.getReviewsByPsicologoId(psicologoId);
        
        // Assert
        expect(reviews.length, 1);
        final review = reviews[0];
        expect(review.id, '');
        expect(review.rating, 0);
        expect(review.comment, '');
        expect(review.date, '');
      });
    });
    
    group('Integration Tests', () {
      test('should handle complete workflow from getting psicologo info to reviews', () async {
        // Arrange
        const pacienteId = '123';
        const psicologoId = '456';
        const psicologoNome = 'Dr. João Silva';
        
        // Mock vinculo response
        final vinculoResponse = {
          'dado': {
            'content': [
              {
                'psicologo': {
                  'id': psicologoId,
                  'nome': psicologoNome,
                }
              }
            ]
          }
        };
        
        // Mock reviews response
        final reviewsResponse = {
          'dado': {
            'content': [
              {
                'id': 'review1',
                'psicologo': {'id': int.parse(psicologoId), 'nome': psicologoNome},
                'paciente': {'id': int.parse(pacienteId), 'nome': 'Maria'},
                'nota': 5,
                'comentario': 'Excelente',
                'dataAvaliacao': '2024-01-15T10:00:00.000Z',
              },
            ]
          }
        };
        
        mockSecureStorage.setMockUserId(pacienteId);
        mockHttp.setResponse('http://10.0.2.2:8080/vinculos/listar/paciente/$pacienteId', 
          HttpResponse(statusCode: 200, body: vinculoResponse));
        mockHttp.setResponse('http://10.0.2.2:8080/avaliacoes/psicologo/$psicologoId', 
          HttpResponse(statusCode: 200, body: reviewsResponse));
        
        // Act
        final psicologoInfo = await reviewDataSource.getPsicologoInfo();
        final reviews = await reviewDataSource.getReviewsByPsicologoId(psicologoId);
        
        // Assert
        expect(psicologoInfo, isNotNull);
        expect(psicologoInfo!['id'], psicologoId);
        expect(psicologoInfo['nome'], psicologoNome);
        
        expect(reviews.length, 1);
        expect(reviews[0].psicologoId, psicologoId);
        expect(reviews[0].rating, 5);
      });
    });
  });
}