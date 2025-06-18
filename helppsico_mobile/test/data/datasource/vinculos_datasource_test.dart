import 'package:flutter_test/flutter_test.dart';
import 'package:helppsico_mobile/data/datasource/vinculos_datasource.dart';
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';
import 'package:helppsico_mobile/core/services/storage/secure_storage_service.dart';
import 'package:helppsico_mobile/core/services/auth/auth_service.dart';

// Mock classes
class MockGenericHttp implements IGenericHttp {
  final Map<String, HttpResponse> _responses = {};
  final List<String> _getRequests = [];
  final List<Map<String, dynamic>> _postRequests = [];
  final List<String> _deleteRequests = [];
  final Map<String, Map<String, String>?> _requestHeaders = {};
  
  void setResponse(String url, HttpResponse response) {
    _responses[url] = response;
  }
  
  List<String> get getRequests => _getRequests;
  List<Map<String, dynamic>> get postRequests => _postRequests;
  List<String> get deleteRequests => _deleteRequests;
  Map<String, Map<String, String>?> get requestHeaders => _requestHeaders;
  
  @override
  Future<HttpResponse> get(String url, {Map<String, String>? headers}) async {
    _getRequests.add(url);
    _requestHeaders[url] = headers;
    return _responses[url] ?? HttpResponse(statusCode: 404, body: {});
  }
  
  @override
  Future<HttpResponse> post(String url, dynamic body, {Map<String, String>? headers}) async {
    _postRequests.add(body);
    _requestHeaders[url] = headers;
    return _responses[url] ?? HttpResponse(statusCode: 201, body: {});
  }
  
  @override
  Future<HttpResponse> delete(String url, {Map<String, String>? headers}) async {
    _deleteRequests.add(url);
    _requestHeaders[url] = headers;
    return _responses[url] ?? HttpResponse(statusCode: 204, body: {});
  }
  
  @override
  Future<HttpResponse> put(String url, dynamic body, {Map<String, String>? headers}) async {
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
  String? _mockCurrentUser;
  Exception? _mockException;
  
  void setMockAuthHeaders(Map<String, String>? headers) {
    _mockAuthHeaders = headers;
  }
  
  void setMockCurrentUser(String? userId) {
    _mockCurrentUser = userId;
  }
  
  void setMockException(Exception? exception) {
    _mockException = exception;
  }
  
  @override
  Future<Map<String, String>> getAuthHeaders() async {
    if (_mockException != null) {
      throw _mockException!;
    }
    return _mockAuthHeaders ?? {};
  }
  
  @override
  Future<String?> getCurrentUser() async {
    if (_mockException != null) {
      throw _mockException!;
    }
    return _mockCurrentUser;
  }
  
  // Implementações vazias para outros métodos não utilizados nos testes
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  group('VinculosDataSource Tests', () {
    late VinculosDataSource vinculosDataSource;
    late MockGenericHttp mockHttp;
    late MockSecureStorageService mockSecureStorage;
    late MockAuthService mockAuthService;
    
    setUp(() {
      mockHttp = MockGenericHttp();
      mockSecureStorage = MockSecureStorageService();
      mockAuthService = MockAuthService();
      vinculosDataSource = VinculosDataSource(
        mockHttp,
        storage: mockSecureStorage,
        authService: mockAuthService,
      );
    });
    
    group('baseUrl', () {
      test('should return correct base URL', () {
        // Act
        final baseUrl = vinculosDataSource.baseUrl;
        
        // Assert
        expect(baseUrl, 'http://10.0.2.2:8080/vinculos');
      });
    });
    
    group('_getPacienteId', () {
      test('should return user ID from secure storage when available', () async {
        // Arrange
        const expectedUserId = '123';
        mockSecureStorage.setMockUserId(expectedUserId);
        mockAuthService.setMockAuthHeaders({'Authorization': 'Bearer token'});
        mockHttp.setResponse('http://10.0.2.2:8080/vinculos/paciente/$expectedUserId', 
          HttpResponse(statusCode: 200, body: {}));
        
        // Act
        await vinculosDataSource.getVinculoByPacienteId();
        
        // Assert
        expect(mockHttp.getRequests.first, contains(expectedUserId));
      });
      
      test('should get user ID from auth service when not in storage', () async {
        // Arrange
        const expectedUserId = '456';
        mockSecureStorage.setMockUserId(null);
        mockAuthService.setMockCurrentUser(expectedUserId);
        mockAuthService.setMockAuthHeaders({'Authorization': 'Bearer token'});
        mockHttp.setResponse('http://10.0.2.2:8080/vinculos/paciente/$expectedUserId', 
          HttpResponse(statusCode: 200, body: {}));
        
        // Act
        await vinculosDataSource.getVinculoByPacienteId();
        
        // Assert
        expect(mockHttp.getRequests.first, contains(expectedUserId));
      });
      
      test('should throw exception when user ID not found anywhere', () async {
        // Arrange
        mockSecureStorage.setMockUserId(null);
        mockAuthService.setMockCurrentUser(null);
        
        // Act & Assert
        expect(
          () => vinculosDataSource.getVinculoByPacienteId(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Não foi possível obter o ID do paciente'),
          )),
        );
      });
      
      test('should throw exception when storage throws error', () async {
        // Arrange
        mockSecureStorage.setMockException(Exception('Storage error'));
        
        // Act & Assert
        expect(
          () => vinculosDataSource.getVinculoByPacienteId(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Erro ao obter ID do paciente'),
          )),
        );
      });
      
      test('should handle empty user ID from storage', () async {
        // Arrange
        const fallbackUserId = '789';
        mockSecureStorage.setMockUserId('');
        mockAuthService.setMockCurrentUser(fallbackUserId);
        mockAuthService.setMockAuthHeaders({'Authorization': 'Bearer token'});
        mockHttp.setResponse('http://10.0.2.2:8080/vinculos/paciente/$fallbackUserId', 
          HttpResponse(statusCode: 200, body: {}));
        
        // Act
        await vinculosDataSource.getVinculoByPacienteId();
        
        // Assert
        expect(mockHttp.getRequests.first, contains(fallbackUserId));
      });
    });
    
    group('getVinculoByPacienteId', () {
      test('should make GET request to correct endpoint with auth headers', () async {
        // Arrange
        const userId = '123';
        final authHeaders = {'Authorization': 'Bearer token123'};
        final expectedUrl = 'http://10.0.2.2:8080/vinculos/paciente/$userId';
        
        mockSecureStorage.setMockUserId(userId);
        mockAuthService.setMockAuthHeaders(authHeaders);
        mockHttp.setResponse(expectedUrl, 
          HttpResponse(statusCode: 200, body: {}));
        
        // Act
        await vinculosDataSource.getVinculoByPacienteId();
        
        // Assert
        expect(mockHttp.getRequests, contains(expectedUrl));
        expect(mockHttp.requestHeaders[expectedUrl], authHeaders);
      });
      
      test('should return successful response', () async {
        // Arrange
        const userId = '123';
        final expectedUrl = 'http://10.0.2.2:8080/vinculos/paciente/$userId';
        final expectedResponse = HttpResponse(
          statusCode: 200, 
          body: {
            'id': 'vinculo1',
            'pacienteId': userId,
            'psicologoId': '456',
            'status': 'ATIVO',
          }
        );
        
        mockSecureStorage.setMockUserId(userId);
        mockAuthService.setMockAuthHeaders({'Authorization': 'Bearer token'});
        mockHttp.setResponse(expectedUrl, expectedResponse);
        
        // Act
        final response = await vinculosDataSource.getVinculoByPacienteId();
        
        // Assert
        expect(response.statusCode, 200);
        expect(response.body['id'], 'vinculo1');
        expect(response.body['status'], 'ATIVO');
      });
      
      test('should throw exception with error message from response', () async {
        // Arrange
        const userId = '123';
        final expectedUrl = 'http://10.0.2.2:8080/vinculos/paciente/$userId';
        
        mockSecureStorage.setMockUserId(userId);
        mockAuthService.setMockAuthHeaders({'Authorization': 'Bearer token'});
        mockHttp.setResponse(expectedUrl, 
          HttpResponse(statusCode: 404, body: {'mensagem': 'Vínculo não encontrado'}));
        
        // Act & Assert
        expect(
          () => vinculosDataSource.getVinculoByPacienteId(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Vínculo não encontrado'),
          )),
        );
      });
      
      test('should throw exception with default message when no error message', () async {
        // Arrange
        const userId = '123';
        final expectedUrl = 'http://10.0.2.2:8080/vinculos/paciente/$userId';
        
        mockSecureStorage.setMockUserId(userId);
        mockAuthService.setMockAuthHeaders({'Authorization': 'Bearer token'});
        mockHttp.setResponse(expectedUrl, 
          HttpResponse(statusCode: 500, body: {}));
        
        // Act & Assert
        expect(
          () => vinculosDataSource.getVinculoByPacienteId(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Falha ao obter vínculo'),
          )),
        );
      });
      
      test('should handle connection error', () async {
        // Arrange
        const userId = '123';
        mockSecureStorage.setMockUserId(userId);
        mockAuthService.setMockAuthHeaders({'Authorization': 'Bearer token'});
        // Não definir resposta para simular erro de conexão
        
        // Act & Assert
        expect(
          () => vinculosDataSource.getVinculoByPacienteId(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Erro de conexão'),
          )),
        );
      });
    });
    
    group('solicitarVinculo', () {
      test('should make POST request with correct data and auth headers', () async {
        // Arrange
        const userId = '123';
        const psicologoId = '456';
        final authHeaders = {'Authorization': 'Bearer token123'};
        final expectedUrl = 'http://10.0.2.2:8080/vinculos';
        
        mockSecureStorage.setMockUserId(userId);
        mockAuthService.setMockAuthHeaders(authHeaders);
        mockHttp.setResponse(expectedUrl, 
          HttpResponse(statusCode: 201, body: {'id': 'vinculo1'}));
        
        // Act
        await vinculosDataSource.solicitarVinculo(psicologoId);
        
        // Assert
        final postRequest = mockHttp.postRequests.first;
        expect(postRequest['idPaciente'], userId);
        expect(postRequest['idPsicologo'], psicologoId);
        expect(mockHttp.requestHeaders[expectedUrl], authHeaders);
      });
      
      test('should return successful response for status 201', () async {
        // Arrange
        const userId = '123';
        const psicologoId = '456';
        final expectedUrl = 'http://10.0.2.2:8080/vinculos';
        final expectedResponse = HttpResponse(
          statusCode: 201, 
          body: {
            'id': 'vinculo1',
            'pacienteId': userId,
            'psicologoId': psicologoId,
            'status': 'PENDENTE',
          }
        );
        
        mockSecureStorage.setMockUserId(userId);
        mockAuthService.setMockAuthHeaders({'Authorization': 'Bearer token'});
        mockHttp.setResponse(expectedUrl, expectedResponse);
        
        // Act
        final response = await vinculosDataSource.solicitarVinculo(psicologoId);
        
        // Assert
        expect(response.statusCode, 201);
        expect(response.body['id'], 'vinculo1');
        expect(response.body['status'], 'PENDENTE');
      });
      
      test('should return successful response for status 200', () async {
        // Arrange
        const userId = '123';
        const psicologoId = '456';
        final expectedUrl = 'http://10.0.2.2:8080/vinculos';
        final expectedResponse = HttpResponse(
          statusCode: 200, 
          body: {
            'id': 'vinculo1',
            'message': 'Vínculo já existe',
          }
        );
        
        mockSecureStorage.setMockUserId(userId);
        mockAuthService.setMockAuthHeaders({'Authorization': 'Bearer token'});
        mockHttp.setResponse(expectedUrl, expectedResponse);
        
        // Act
        final response = await vinculosDataSource.solicitarVinculo(psicologoId);
        
        // Assert
        expect(response.statusCode, 200);
        expect(response.body['message'], 'Vínculo já existe');
      });
      
      test('should throw exception with error message from response', () async {
        // Arrange
        const userId = '123';
        const psicologoId = '456';
        final expectedUrl = 'http://10.0.2.2:8080/vinculos';
        
        mockSecureStorage.setMockUserId(userId);
        mockAuthService.setMockAuthHeaders({'Authorization': 'Bearer token'});
        mockHttp.setResponse(expectedUrl, 
          HttpResponse(statusCode: 400, body: {'mensagem': 'Psicólogo não encontrado'}));
        
        // Act & Assert
        expect(
          () => vinculosDataSource.solicitarVinculo(psicologoId),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Psicólogo não encontrado'),
          )),
        );
      });
      
      test('should throw exception with default message when no error message', () async {
        // Arrange
        const userId = '123';
        const psicologoId = '456';
        final expectedUrl = 'http://10.0.2.2:8080/vinculos';
        
        mockSecureStorage.setMockUserId(userId);
        mockAuthService.setMockAuthHeaders({'Authorization': 'Bearer token'});
        mockHttp.setResponse(expectedUrl, 
          HttpResponse(statusCode: 422, body: {}));
        
        // Act & Assert
        expect(
          () => vinculosDataSource.solicitarVinculo(psicologoId),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Falha ao solicitar vínculo'),
          )),
        );
      });
      
      test('should handle connection error', () async {
        // Arrange
        const userId = '123';
        const psicologoId = '456';
        mockSecureStorage.setMockUserId(userId);
        mockAuthService.setMockAuthHeaders({'Authorization': 'Bearer token'});
        // Não definir resposta para simular erro de conexão
        
        // Act & Assert
        expect(
          () => vinculosDataSource.solicitarVinculo(psicologoId),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Erro de conexão'),
          )),
        );
      });
      
      test('should throw exception when user ID is null', () async {
        // Arrange
        const psicologoId = '456';
        mockSecureStorage.setMockUserId(null);
        mockAuthService.setMockCurrentUser(null);
        
        // Act & Assert
        expect(
          () => vinculosDataSource.solicitarVinculo(psicologoId),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Não foi possível obter o ID do paciente'),
          )),
        );
      });
    });
    
    group('cancelarVinculo', () {
      test('should make DELETE request to correct endpoint with auth headers', () async {
        // Arrange
        const vinculoId = 'vinculo123';
        final authHeaders = {'Authorization': 'Bearer token123'};
        final expectedUrl = 'http://10.0.2.2:8080/vinculos/$vinculoId';
        
        mockAuthService.setMockAuthHeaders(authHeaders);
        mockHttp.setResponse(expectedUrl, 
          HttpResponse(statusCode: 204, body: {}));
        
        // Act
        await vinculosDataSource.cancelarVinculo(vinculoId);
        
        // Assert
        expect(mockHttp.deleteRequests, contains(expectedUrl));
        expect(mockHttp.requestHeaders[expectedUrl], authHeaders);
      });
      
      test('should return successful response', () async {
        // Arrange
        const vinculoId = 'vinculo123';
        final expectedUrl = 'http://10.0.2.2:8080/vinculos/$vinculoId';
        final expectedResponse = HttpResponse(
          statusCode: 204, 
          body: {}
        );
        
        mockAuthService.setMockAuthHeaders({'Authorization': 'Bearer token'});
        mockHttp.setResponse(expectedUrl, expectedResponse);
        
        // Act
        final response = await vinculosDataSource.cancelarVinculo(vinculoId);
        
        // Assert
        expect(response.statusCode, 204);
      });
      
      test('should handle special characters in vinculo ID', () async {
        // Arrange
        const vinculoId = 'vinculo@123#special';
        final expectedUrl = 'http://10.0.2.2:8080/vinculos/$vinculoId';
        
        mockAuthService.setMockAuthHeaders({'Authorization': 'Bearer token'});
        mockHttp.setResponse(expectedUrl, 
          HttpResponse(statusCode: 204, body: {}));
        
        // Act
        await vinculosDataSource.cancelarVinculo(vinculoId);
        
        // Assert
        expect(mockHttp.deleteRequests, contains(expectedUrl));
      });
      
      test('should handle empty vinculo ID', () async {
        // Arrange
        const vinculoId = '';
        final expectedUrl = 'http://10.0.2.2:8080/vinculos/$vinculoId';
        
        mockAuthService.setMockAuthHeaders({'Authorization': 'Bearer token'});
        mockHttp.setResponse(expectedUrl, 
          HttpResponse(statusCode: 204, body: {}));
        
        // Act
        await vinculosDataSource.cancelarVinculo(vinculoId);
        
        // Assert
        expect(mockHttp.deleteRequests, contains(expectedUrl));
      });
    });
    
    group('Interface Implementation', () {
      test('should implement IVinculosDataSource interface', () {
        // Assert
        expect(vinculosDataSource, isA<IVinculosDataSource>());
      });
      
      test('should have all required interface methods', () {
        // Assert
        expect(vinculosDataSource.baseUrl, isA<String>());
        expect(() => vinculosDataSource.getVinculoByPacienteId(), returnsNormally);
        expect(() => vinculosDataSource.solicitarVinculo('123'), returnsNormally);
        expect(() => vinculosDataSource.cancelarVinculo('123'), returnsNormally);
      });
    });
    
    group('Integration Tests', () {
      test('should handle complete vinculo workflow', () async {
        // Arrange
        const userId = '123';
        const psicologoId = '456';
        const vinculoId = 'vinculo789';
        final authHeaders = {
          'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
          'Content-Type': 'application/json',
        };
        
        mockSecureStorage.setMockUserId(userId);
        mockAuthService.setMockAuthHeaders(authHeaders);
        
        // Mock responses for each operation
        mockHttp.setResponse('http://10.0.2.2:8080/vinculos', 
          HttpResponse(statusCode: 201, body: {'id': vinculoId, 'status': 'PENDENTE'}));
        mockHttp.setResponse('http://10.0.2.2:8080/vinculos/paciente/$userId', 
          HttpResponse(statusCode: 200, body: {'id': vinculoId, 'status': 'ATIVO'}));
        mockHttp.setResponse('http://10.0.2.2:8080/vinculos/$vinculoId', 
          HttpResponse(statusCode: 204, body: {}));
        
        // Act
        final solicitarResponse = await vinculosDataSource.solicitarVinculo(psicologoId);
        final getResponse = await vinculosDataSource.getVinculoByPacienteId();
        final cancelarResponse = await vinculosDataSource.cancelarVinculo(vinculoId);
        
        // Assert
        // Verify solicitar vinculo
        expect(solicitarResponse.statusCode, 201);
        expect(solicitarResponse.body['id'], vinculoId);
        expect(mockHttp.postRequests.first['idPaciente'], userId);
        expect(mockHttp.postRequests.first['idPsicologo'], psicologoId);
        
        // Verify get vinculo
        expect(getResponse.statusCode, 200);
        expect(getResponse.body['id'], vinculoId);
        
        // Verify cancelar vinculo
        expect(cancelarResponse.statusCode, 204);
        
        // Verify auth headers were used in all requests
        expect(mockHttp.requestHeaders.values.every((headers) => headers == authHeaders), true);
      });
      
      test('should handle error scenarios in workflow', () async {
        // Arrange
        const userId = '123';
        const psicologoId = '456';
        
        mockSecureStorage.setMockUserId(userId);
        mockAuthService.setMockAuthHeaders({'Authorization': 'Bearer token'});
        
        // Mock error responses
        mockHttp.setResponse('http://10.0.2.2:8080/vinculos', 
          HttpResponse(statusCode: 400, body: {'mensagem': 'Vínculo já existe'}));
        mockHttp.setResponse('http://10.0.2.2:8080/vinculos/paciente/$userId', 
          HttpResponse(statusCode: 404, body: {'mensagem': 'Paciente não encontrado'}));
        
        // Act & Assert
        expect(
          () => vinculosDataSource.solicitarVinculo(psicologoId),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Vínculo já existe'),
          )),
        );
        
        expect(
          () => vinculosDataSource.getVinculoByPacienteId(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Paciente não encontrado'),
          )),
        );
      });
    });
  });
}