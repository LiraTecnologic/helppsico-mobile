import 'package:flutter_test/flutter_test.dart';
import 'package:helppsico_mobile/data/datasource/sessions_data_source.dart';
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';
import 'package:helppsico_mobile/core/services/storage/secure_storage_service.dart';
import 'package:helppsico_mobile/core/services/auth/auth_service.dart';

// Mock classes
class MockGenericHttp implements IGenericHttp {
  final Map<String, HttpResponse> _responses = {};
  final List<String> _getRequests = [];
  final Map<String, Map<String, String>?> _requestHeaders = {};
  
  void setResponse(String url, HttpResponse response) {
    _responses[url] = response;
  }
  
  List<String> get getRequests => _getRequests;
  Map<String, Map<String, String>?> get requestHeaders => _requestHeaders;
  
  @override
  Future<HttpResponse> get(String url, {Map<String, String>? headers}) async {
    _getRequests.add(url);
    _requestHeaders[url] = headers;
    return _responses[url] ?? HttpResponse(statusCode: 404, body: {});
  }
  
  @override
  Future<HttpResponse> post(String url, dynamic body, {Map<String, String>? headers}) async {
    return HttpResponse(statusCode: 201, body: {});
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
  Exception? _mockException;
  
  void setMockUserId(String? userId) {
    _mockUserId = userId;
  }
  
  void setMockException(Exception? exception) {
    _mockException = exception;
  }
  
  @override
  Future<String?> getUserId() async {
    if (_mockException != null) {
      throw _mockException!;
    }
    return _mockUserId;
  }
  
  // Implementações vazias para outros métodos não utilizados nos testes
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class MockAuthService implements AuthService {
  Map<String, String>? _mockAuthHeaders;
  
  void setMockAuthHeaders(Map<String, String>? headers) {
    _mockAuthHeaders = headers;
  }
  
  @override
  Future<Map<String, String>> getAuthHeaders() async {
    return _mockAuthHeaders ?? {};
  }
  
  // Implementações vazias para outros métodos não utilizados nos testes
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  group('SessionsDataSource Tests', () {
    late SessionsDataSource sessionsDataSource;
    late MockGenericHttp mockHttp;
    late MockSecureStorageService mockSecureStorage;
    late MockAuthService mockAuthService;
    
    setUp(() {
      mockHttp = MockGenericHttp();
      mockSecureStorage = MockSecureStorageService();
      mockAuthService = MockAuthService();
      sessionsDataSource = SessionsDataSource(
        mockHttp,
        storage: mockSecureStorage,
        authService: mockAuthService,
      );
    });
    
    group('baseUrl', () {
      test('should return correct base URL', () {
        // Act
        final baseUrl = sessionsDataSource.baseUrl;
        
        // Assert
        expect(baseUrl, 'http://10.0.2.2:8080/consultas');
      });
    });
    
    group('_getPacienteId', () {
      test('should return user ID from secure storage', () async {
        // Arrange
        const expectedUserId = '123';
        mockSecureStorage.setMockUserId(expectedUserId);
        mockAuthService.setMockAuthHeaders({'Authorization': 'Bearer token'});
        mockHttp.setResponse('http://10.0.2.2:8080/consultas/paciente/futuras/$expectedUserId', 
          HttpResponse(statusCode: 200, body: {'dado': {'content': []}}));
        
        // Act
        await sessionsDataSource.getSessions();
        
        // Assert
        expect(mockHttp.getRequests.first, contains(expectedUserId));
      });
      
      test('should return null when storage throws exception', () async {
        // Arrange
        mockSecureStorage.setMockException(Exception('Storage error'));
        
        // Act & Assert
        expect(
          () => sessionsDataSource.getSessions(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Não foi possível obter o ID do paciente'),
          )),
        );
      });
    });
    
    group('getSessions', () {
      test('should make GET request to correct endpoint with auth headers', () async {
        // Arrange
        const userId = '123';
        final authHeaders = {'Authorization': 'Bearer token123'};
        final expectedUrl = 'http://10.0.2.2:8080/consultas/paciente/futuras/$userId';
        
        mockSecureStorage.setMockUserId(userId);
        mockAuthService.setMockAuthHeaders(authHeaders);
        mockHttp.setResponse(expectedUrl, 
          HttpResponse(statusCode: 200, body: {'dado': {'content': []}}));
        
        // Act
        await sessionsDataSource.getSessions();
        
        // Assert
        expect(mockHttp.getRequests, contains(expectedUrl));
        expect(mockHttp.requestHeaders[expectedUrl], authHeaders);
      });
      
      test('should return successful response', () async {
        // Arrange
        const userId = '123';
        final expectedUrl = 'http://10.0.2.2:8080/consultas/paciente/futuras/$userId';
        final expectedResponse = HttpResponse(
          statusCode: 200, 
          body: {
            'dado': {
              'content': [
                {
                  'id': 'session1',
                  'dataHora': '2024-01-15T10:00:00.000Z',
                  'psicologo': {'nome': 'Dr. João'},
                }
              ]
            }
          }
        );
        
        mockSecureStorage.setMockUserId(userId);
        mockAuthService.setMockAuthHeaders({'Authorization': 'Bearer token'});
        mockHttp.setResponse(expectedUrl, expectedResponse);
        
        // Act
        final response = await sessionsDataSource.getSessions();
        
        // Assert
        expect(response.statusCode, 200);
        expect(response.body['dado']['content'], isA<List>());
        expect(response.body['dado']['content'].length, 1);
      });
      
      test('should throw exception when user ID is null', () async {
        // Arrange
        mockSecureStorage.setMockUserId(null);
        
        // Act & Assert
        expect(
          () => sessionsDataSource.getSessions(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Não foi possível obter o ID do paciente'),
          )),
        );
      });
      
      test('should handle HTTP error responses', () async {
        // Arrange
        const userId = '123';
        final expectedUrl = 'http://10.0.2.2:8080/consultas/paciente/futuras/$userId';
        
        mockSecureStorage.setMockUserId(userId);
        mockAuthService.setMockAuthHeaders({'Authorization': 'Bearer token'});
        mockHttp.setResponse(expectedUrl, 
          HttpResponse(statusCode: 500, body: {'error': 'Server error'}));
        
        // Act
        final response = await sessionsDataSource.getSessions();
        
        // Assert
        expect(response.statusCode, 500);
        expect(response.body['error'], 'Server error');
      });
      
      test('should handle empty auth headers', () async {
        // Arrange
        const userId = '123';
        final expectedUrl = 'http://10.0.2.2:8080/consultas/paciente/futuras/$userId';
        
        mockSecureStorage.setMockUserId(userId);
        mockAuthService.setMockAuthHeaders(null);
        mockHttp.setResponse(expectedUrl, 
          HttpResponse(statusCode: 200, body: {'dado': {'content': []}}));
        
        // Act
        await sessionsDataSource.getSessions();
        
        // Assert
        expect(mockHttp.requestHeaders[expectedUrl], null);
      });
    });
    
    group('getNextSession', () {
      test('should return first session when sessions exist', () async {
        // Arrange
        const userId = '123';
        final expectedUrl = 'http://10.0.2.2:8080/consultas/paciente/futuras/$userId';
        final sessionsResponse = HttpResponse(
          statusCode: 200,
          body: {
            'dado': {
              'content': [
                {
                  'id': 'session1',
                  'dataHora': '2024-01-15T10:00:00.000Z',
                  'psicologo': {'nome': 'Dr. João'},
                },
                {
                  'id': 'session2',
                  'dataHora': '2024-01-16T10:00:00.000Z',
                  'psicologo': {'nome': 'Dr. Maria'},
                },
              ]
            }
          }
        );
        
        mockSecureStorage.setMockUserId(userId);
        mockAuthService.setMockAuthHeaders({'Authorization': 'Bearer token'});
        mockHttp.setResponse(expectedUrl, sessionsResponse);
        
        // Act
        final response = await sessionsDataSource.getNextSession();
        
        // Assert
        expect(response.statusCode, 200);
        expect(response.body['id'], 'session1');
        expect(response.body['dataHora'], '2024-01-15T10:00:00.000Z');
      });
      
      test('should return empty response when no sessions exist', () async {
        // Arrange
        const userId = '123';
        final expectedUrl = 'http://10.0.2.2:8080/consultas/paciente/futuras/$userId';
        final sessionsResponse = HttpResponse(
          statusCode: 200,
          body: {
            'dado': {
              'content': []
            }
          }
        );
        
        mockSecureStorage.setMockUserId(userId);
        mockAuthService.setMockAuthHeaders({'Authorization': 'Bearer token'});
        mockHttp.setResponse(expectedUrl, sessionsResponse);
        
        // Act
        final response = await sessionsDataSource.getNextSession();
        
        // Assert
        expect(response.statusCode, 200);
        expect(response.body, {});
      });
      
      test('should return empty response when content is null', () async {
        // Arrange
        const userId = '123';
        final expectedUrl = 'http://10.0.2.2:8080/consultas/paciente/futuras/$userId';
        final sessionsResponse = HttpResponse(
          statusCode: 200,
          body: {
            'dado': {
              'content': null
            }
          }
        );
        
        mockSecureStorage.setMockUserId(userId);
        mockAuthService.setMockAuthHeaders({'Authorization': 'Bearer token'});
        mockHttp.setResponse(expectedUrl, sessionsResponse);
        
        // Act
        final response = await sessionsDataSource.getNextSession();
        
        // Assert
        expect(response.statusCode, 200);
        expect(response.body, {});
      });
      
      test('should return empty response when dado is null', () async {
        // Arrange
        const userId = '123';
        final expectedUrl = 'http://10.0.2.2:8080/consultas/paciente/futuras/$userId';
        final sessionsResponse = HttpResponse(
          statusCode: 200,
          body: {
            'dado': null
          }
        );
        
        mockSecureStorage.setMockUserId(userId);
        mockAuthService.setMockAuthHeaders({'Authorization': 'Bearer token'});
        mockHttp.setResponse(expectedUrl, sessionsResponse);
        
        // Act
        final response = await sessionsDataSource.getNextSession();
        
        // Assert
        expect(response.statusCode, 200);
        expect(response.body, {});
      });
      
      test('should return empty response when HTTP request fails', () async {
        // Arrange
        const userId = '123';
        final expectedUrl = 'http://10.0.2.2:8080/consultas/paciente/futuras/$userId';
        final sessionsResponse = HttpResponse(
          statusCode: 500,
          body: {'error': 'Server error'}
        );
        
        mockSecureStorage.setMockUserId(userId);
        mockAuthService.setMockAuthHeaders({'Authorization': 'Bearer token'});
        mockHttp.setResponse(expectedUrl, sessionsResponse);
        
        // Act
        final response = await sessionsDataSource.getNextSession();
        
        // Assert
        expect(response.statusCode, 200);
        expect(response.body, {});
      });
      
      test('should throw exception when user ID is null', () async {
        // Arrange
        mockSecureStorage.setMockUserId(null);
        
        // Act & Assert
        expect(
          () => sessionsDataSource.getNextSession(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Não foi possível obter o ID do paciente'),
          )),
        );
      });
      
      test('should handle single session correctly', () async {
        // Arrange
        const userId = '123';
        final expectedUrl = 'http://10.0.2.2:8080/consultas/paciente/futuras/$userId';
        final sessionsResponse = HttpResponse(
          statusCode: 200,
          body: {
            'dado': {
              'content': [
                {
                  'id': 'session1',
                  'dataHora': '2024-01-15T10:00:00.000Z',
                  'psicologo': {'nome': 'Dr. João'},
                  'status': 'AGENDADA',
                },
              ]
            }
          }
        );
        
        mockSecureStorage.setMockUserId(userId);
        mockAuthService.setMockAuthHeaders({'Authorization': 'Bearer token'});
        mockHttp.setResponse(expectedUrl, sessionsResponse);
        
        // Act
        final response = await sessionsDataSource.getNextSession();
        
        // Assert
        expect(response.statusCode, 200);
        expect(response.body['id'], 'session1');
        expect(response.body['status'], 'AGENDADA');
      });
    });
    
    group('Interface Implementation', () {
      test('should implement ISessionsDataSource interface', () {
        // Assert
        expect(sessionsDataSource, isA<ISessionsDataSource>());
      });
      
      test('should have all required interface methods', () {
        // Assert
        expect(sessionsDataSource.baseUrl, isA<String>());
        expect(() => sessionsDataSource.getSessions(), returnsNormally);
        expect(() => sessionsDataSource.getNextSession(), returnsNormally);
      });
    });
    
    group('Integration Tests', () {
      test('should handle complete workflow with auth and sessions', () async {
        // Arrange
        const userId = '123';
        final authHeaders = {
          'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
          'Content-Type': 'application/json',
        };
        final expectedUrl = 'http://10.0.2.2:8080/consultas/paciente/futuras/$userId';
        final sessionsResponse = HttpResponse(
          statusCode: 200,
          body: {
            'dado': {
              'content': [
                {
                  'id': 'session1',
                  'dataHora': '2024-01-15T10:00:00.000Z',
                  'psicologo': {
                    'id': '456',
                    'nome': 'Dr. João Silva',
                    'crp': '12345',
                  },
                  'status': 'AGENDADA',
                  'modalidade': 'PRESENCIAL',
                },
                {
                  'id': 'session2',
                  'dataHora': '2024-01-16T14:00:00.000Z',
                  'psicologo': {
                    'id': '456',
                    'nome': 'Dr. João Silva',
                    'crp': '12345',
                  },
                  'status': 'AGENDADA',
                  'modalidade': 'ONLINE',
                },
              ]
            }
          }
        );
        
        mockSecureStorage.setMockUserId(userId);
        mockAuthService.setMockAuthHeaders(authHeaders);
        mockHttp.setResponse(expectedUrl, sessionsResponse);
        
        // Act
        final allSessions = await sessionsDataSource.getSessions();
        final nextSession = await sessionsDataSource.getNextSession();
        
        // Assert
        // Verify all sessions
        expect(allSessions.statusCode, 200);
        expect(allSessions.body['dado']['content'], isA<List>());
        expect(allSessions.body['dado']['content'].length, 2);
        
        // Verify next session (should be first one)
        expect(nextSession.statusCode, 200);
        expect(nextSession.body['id'], 'session1');
        expect(nextSession.body['dataHora'], '2024-01-15T10:00:00.000Z');
        
        // Verify auth headers were used
        expect(mockHttp.requestHeaders[expectedUrl], authHeaders);
      });
      
      test('should handle error scenarios gracefully', () async {
        // Arrange
        mockSecureStorage.setMockException(Exception('Storage unavailable'));
        
        // Act & Assert
        expect(
          () => sessionsDataSource.getSessions(),
          throwsA(isA<Exception>()),
        );
        
        expect(
          () => sessionsDataSource.getNextSession(),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}