import 'package:flutter_test/flutter_test.dart';
import 'package:helppsico_mobile/data/datasource/documents_datasource.dart';
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';
import 'package:helppsico_mobile/core/services/storage/secure_storage_service.dart';
import 'package:helppsico_mobile/core/services/auth/auth_service.dart';

// Mock classes
class MockGenericHttp implements IGenericHttp {
  final Map<String, HttpResponse> _responses = {};
  final List<String> _getRequests = [];
  final List<Map<String, dynamic>> _postRequests = [];
  final List<String> _deleteRequests = [];
  
  void setResponse(String url, HttpResponse response) {
    _responses[url] = response;
  }
  
  List<String> get getRequests => _getRequests;
  List<Map<String, dynamic>> get postRequests => _postRequests;
  List<String> get deleteRequests => _deleteRequests;
  
  @override
  Future<HttpResponse> get(String url, {Map<String, String>? headers}) async {
    _getRequests.add(url);
    return _responses[url] ?? HttpResponse(statusCode: 404, body: {});
  }
  
  @override
  Future<HttpResponse> post(String url, dynamic body, {Map<String, String>? headers}) async {
    _postRequests.add(body);
    return _responses[url] ?? HttpResponse(statusCode: 201, body: {});
  }
  
  @override
  Future<HttpResponse> delete(String url, {Map<String, String>? headers}) async {
    _deleteRequests.add(url);
    return _responses[url] ?? HttpResponse(statusCode: 204, body: {});
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
  
  @override
  Future<void> saveUserId(String userId) async {
    _mockUserId = userId;
  }
  
  // Implementações vazias para outros métodos não utilizados nos testes
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class MockAuthService implements AuthService {
  Map<String, dynamic>? _mockUserInfo;
  
  void setMockUserInfo(Map<String, dynamic>? userInfo) {
    _mockUserInfo = userInfo;
  }
  
  @override
  Future<Map<String, dynamic>?> getUserInfo() async {
    return _mockUserInfo;
  }
  
  // Implementações vazias para outros métodos não utilizados nos testes
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  group('DocumentsDataSource Tests', () {
    late DocumentsDataSource documentsDataSource;
    late MockGenericHttp mockHttp;
    late MockSecureStorageService mockSecureStorage;
    late MockAuthService mockAuthService;
    
    setUp(() {
      mockHttp = MockGenericHttp();
      mockSecureStorage = MockSecureStorageService();
      mockAuthService = MockAuthService();
      documentsDataSource = DocumentsDataSource(
        mockHttp,
        mockSecureStorage,
        mockAuthService,
      );
    });
    
    group('_getPacienteId', () {
      test('should return user ID from secure storage when available', () async {
        // Arrange
        const expectedUserId = '123';
        mockSecureStorage.setMockUserId(expectedUserId);
        
        // Act
        final response = await documentsDataSource.getDocuments();
        
        // Assert
        expect(mockHttp.getRequests.first, contains(expectedUserId));
      });
      
      test('should get user ID from auth service when not in storage', () async {
        // Arrange
        const expectedUserId = '456';
        mockSecureStorage.setMockUserId(null);
        mockAuthService.setMockUserInfo({'id': expectedUserId});
        mockHttp.setResponse('http://localhost:8080/documentos/$expectedUserId', 
          HttpResponse(statusCode: 200, body: {}));
        
        // Act
        await documentsDataSource.getDocuments();
        
        // Assert
        expect(mockHttp.getRequests.first, contains(expectedUserId));
      });
      
      test('should save user ID to storage when obtained from auth service', () async {
        // Arrange
        const expectedUserId = '789';
        mockSecureStorage.setMockUserId(null);
        mockAuthService.setMockUserInfo({'id': expectedUserId});
        mockHttp.setResponse('http://localhost:8080/documentos/$expectedUserId', 
          HttpResponse(statusCode: 200, body: {}));
        
        // Act
        await documentsDataSource.getDocuments();
        
        // Assert
        expect(mockSecureStorage._mockUserId, expectedUserId);
      });
      
      test('should throw exception when user ID not found anywhere', () async {
        // Arrange
        mockSecureStorage.setMockUserId(null);
        mockAuthService.setMockUserInfo(null);
        
        // Act & Assert
        expect(
          () => documentsDataSource.getDocuments(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('ID do paciente não encontrado'),
          )),
        );
      });
      
      test('should throw exception when user ID is empty string', () async {
        // Arrange
        mockSecureStorage.setMockUserId('');
        mockAuthService.setMockUserInfo({'id': ''});
        
        // Act & Assert
        expect(
          () => documentsDataSource.getDocuments(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('ID do paciente não encontrado'),
          )),
        );
      });
      
      test('should handle auth service returning user info without id', () async {
        // Arrange
        mockSecureStorage.setMockUserId(null);
        mockAuthService.setMockUserInfo({'name': 'John Doe'});
        
        // Act & Assert
        expect(
          () => documentsDataSource.getDocuments(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('ID do paciente não encontrado'),
          )),
        );
      });
    });
    
    group('getDocuments', () {
      test('should make GET request to correct endpoint', () async {
        // Arrange
        const userId = '123';
        mockSecureStorage.setMockUserId(userId);
        mockHttp.setResponse('http://localhost:8080/documentos/$userId', 
          HttpResponse(statusCode: 200, body: {}));
        
        // Act
        await documentsDataSource.getDocuments();
        
        // Assert
        expect(mockHttp.getRequests, contains('http://localhost:8080/documentos/$userId'));
      });
      
      test('should return successful response', () async {
        // Arrange
        const userId = '123';
        final expectedResponse = HttpResponse(statusCode: 200, body: {'documents': []});
        mockSecureStorage.setMockUserId(userId);
        mockHttp.setResponse('http://localhost:8080/documentos/$userId', expectedResponse);
        
        // Act
        final response = await documentsDataSource.getDocuments();
        
        // Assert
        expect(response.statusCode, 200);
        expect(response.body, expectedResponse.body);
      });
      
      test('should throw exception on HTTP error', () async {
        // Arrange
        const userId = '123';
        mockSecureStorage.setMockUserId(userId);
        mockHttp.setResponse('http://localhost:8080/documentos/$userId', 
          HttpResponse(statusCode: 500, body: {'mensagem': 'Server error'}));
        
        // Act & Assert
        expect(
          () => documentsDataSource.getDocuments(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Server error'),
          )),
        );
      });
      
      test('should throw exception with default message when no error message in response', () async {
        // Arrange
        const userId = '123';
        mockSecureStorage.setMockUserId(userId);
        mockHttp.setResponse('http://localhost:8080/documentos/$userId', 
          HttpResponse(statusCode: 404, body: {}));
        
        // Act & Assert
        expect(
          () => documentsDataSource.getDocuments(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Falha na operação HTTP'),
          )),
        );
      });
    });
    
    group('uploadDocument', () {
      test('should make POST request with correct data', () async {
        // Arrange
        const userId = '123';
        const filePath = '/path/to/file.pdf';
        final metadata = {
          'title': 'Test Document',
          'description': 'Test Description',
          'type': 'ATESTADO',
        };
        
        mockSecureStorage.setMockUserId(userId);
        mockHttp.setResponse('http://localhost:8080/solicitacoes-documentos', 
          HttpResponse(statusCode: 201, body: {}));
        
        // Act
        await documentsDataSource.uploadDocument(filePath, metadata);
        
        // Assert
        final postRequest = mockHttp.postRequests.first;
        expect(postRequest['idPaciente'], userId);
        expect(postRequest['titulo'], 'Test Document');
        expect(postRequest['descricao'], 'Test Description');
        expect(postRequest['tipo'], 'ATESTADO');
        expect(postRequest['urlArquivo'], filePath);
      });
      
      test('should handle missing metadata with defaults', () async {
        // Arrange
        const userId = '123';
        const filePath = '/path/to/file.pdf';
        final metadata = <String, dynamic>{};
        
        mockSecureStorage.setMockUserId(userId);
        mockHttp.setResponse('http://localhost:8080/solicitacoes-documentos', 
          HttpResponse(statusCode: 201, body: {}));
        
        // Act
        await documentsDataSource.uploadDocument(filePath, metadata);
        
        // Assert
        final postRequest = mockHttp.postRequests.first;
        expect(postRequest['titulo'], '');
        expect(postRequest['descricao'], '');
        expect(postRequest['tipo'], 'OUTRO');
      });
      
      test('should return successful response', () async {
        // Arrange
        const userId = '123';
        const filePath = '/path/to/file.pdf';
        final metadata = {'title': 'Test'};
        final expectedResponse = HttpResponse(statusCode: 201, body: {'id': 'doc123'});
        
        mockSecureStorage.setMockUserId(userId);
        mockHttp.setResponse('http://localhost:8080/solicitacoes-documentos', expectedResponse);
        
        // Act
        final response = await documentsDataSource.uploadDocument(filePath, metadata);
        
        // Assert
        expect(response.statusCode, 201);
        expect(response.body, expectedResponse.body);
      });
      
      test('should throw exception on upload error', () async {
        // Arrange
        const userId = '123';
        const filePath = 'invalid/path';
        final metadata = {'title': 'Test Document'};

        mockSecureStorage.setMockUserId(userId);
        mockHttp.setResponse('http://localhost:8080/solicitacoes-documentos', 
          HttpResponse(statusCode: 400, body: {'mensagem': 'Invalid file'}));
        
        // Act & Assert
        try {
          await documentsDataSource.uploadDocument(filePath, metadata);
          fail('should have thrown an exception');
        } catch (e) {
          expect(e, isA<Exception>());
          expect(e.toString(), contains('Invalid file'));
        }
      });
    });
    
    group('deleteDocument', () {
      test('should make DELETE request to correct endpoint', () async {
        // Arrange
        const documentId = 'doc123';
        mockHttp.setResponse('http://localhost:8080/documentos/$documentId', 
          HttpResponse(statusCode: 204, body: {}));
        
        // Act
        await documentsDataSource.deleteDocument(documentId);
        
        // Assert
        expect(mockHttp.deleteRequests, contains('http://localhost:8080/documentos/$documentId'));
      });
      
      test('should return successful response', () async {
        // Arrange
        const documentId = 'doc123';
        final expectedResponse = HttpResponse(statusCode: 204, body: {});
        mockHttp.setResponse('http://localhost:8080/documentos/$documentId', expectedResponse);
        
        // Act
        final response = await documentsDataSource.deleteDocument(documentId);
        
        // Assert
        expect(response.statusCode, 204);
      });
      
      test('should throw exception on deletion error', () async {
        // Arrange
        const documentId = 'doc-to-fail';
        mockHttp.setResponse('http://localhost:8080/documentos/$documentId', 
          HttpResponse(statusCode: 500, body: {'mensagem': 'Server error'}));
        
        // Act & Assert
        try {
          await documentsDataSource.deleteDocument(documentId);
          fail('should have thrown an exception');
        } catch (e) {
          expect(e, isA<Exception>());
          expect(e.toString(), contains('Server error'));
        }
      });
      
      test('should handle special characters in document ID', () async {
        // Arrange
        const documentId = 'doc@123#special';
        mockHttp.setResponse('http://localhost:8080/documentos/$documentId', 
          HttpResponse(statusCode: 204, body: {}));
        
        // Act
        await documentsDataSource.deleteDocument(documentId);
        
        // Assert
        expect(mockHttp.deleteRequests, contains('http://localhost:8080/documentos/$documentId'));
      });
    });
    
    group('_handleHttpRequest', () {
      test('should accept status code 200', () async {
        // Arrange
        const userId = '123';
        mockSecureStorage.setMockUserId(userId);
        mockHttp.setResponse('http://localhost:8080/documentos/$userId', 
          HttpResponse(statusCode: 200, body: {}));
        
        // Act & Assert
        expect(() => documentsDataSource.getDocuments(), returnsNormally);
      });
      
      test('should accept status code 201', () async {
        // Arrange
        const userId = '123';
        const filePath = '/path/to/file.pdf';
        final metadata = {'title': 'Test'};
        
        mockSecureStorage.setMockUserId(userId);
        mockHttp.setResponse('http://localhost:8080/solicitacoes-documentos', 
          HttpResponse(statusCode: 201, body: {}));
        
        // Act & Assert
        expect(() => documentsDataSource.uploadDocument(filePath, metadata), returnsNormally);
      });
      
      test('should accept status code 204', () async {
        // Arrange
        const documentId = 'doc123';
        mockHttp.setResponse('http://localhost:8080/documentos/$documentId', 
          HttpResponse(statusCode: 204, body: {}));
        
        // Act & Assert
        expect(() => documentsDataSource.deleteDocument(documentId), returnsNormally);
      });
      
      test('should throw exception for other status codes', () async {
        // Arrange
        const userId = '123';
        mockSecureStorage.setMockUserId(userId);
        mockHttp.setResponse('http://localhost:8080/documentos/$userId', 
          HttpResponse(statusCode: 401, body: {}));
        
        // Act & Assert
        expect(
          () => documentsDataSource.getDocuments(),
          throwsA(isA<Exception>()),
        );
      });
    });
    
    group('Integration Tests', () {
      test('should handle complete upload workflow', () async {
        // Arrange
        const userId = '123';
        const filePath = '/path/to/document.pdf';
        final metadata = {
          'title': 'Medical Certificate',
          'description': 'Certificate for medical leave',
          'type': 'ATESTADO',
        };
        
        mockSecureStorage.setMockUserId(null);
        mockAuthService.setMockUserInfo({'id': userId});
        mockHttp.setResponse('http://localhost:8080/solicitacoes-documentos', 
          HttpResponse(statusCode: 201, body: {'id': 'doc123'}));
        
        // Act
        final response = await documentsDataSource.uploadDocument(filePath, metadata);
        
        // Assert
        expect(response.statusCode, 201);
        expect(mockSecureStorage._mockUserId, userId); // Should save user ID
        final postRequest = mockHttp.postRequests.first;
        expect(postRequest['idPaciente'], userId);
        expect(postRequest['titulo'], 'Medical Certificate');
      });
      
      test('should handle error responses with custom messages', () async {
        // Arrange
        const userId = '123';
        mockSecureStorage.setMockUserId(userId);
        mockHttp.setResponse('http://localhost:8080/documentos/$userId', 
          HttpResponse(statusCode: 500, body: {'mensagem': 'Database connection failed'}));
        
        // Act & Assert
        expect(
          () => documentsDataSource.getDocuments(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Database connection failed'),
          )),
        );
      });
    });
  });
}