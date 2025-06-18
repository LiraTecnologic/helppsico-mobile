import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:helppsico_mobile/core/services/auth/auth_service.dart';
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';
import 'package:helppsico_mobile/core/services/storage/secure_storage_service.dart';
import 'package:helppsico_mobile/core/services/psicologo/psicologo_service.dart';
import 'package:helppsico_mobile/domain/entities/user_model.dart';
import 'package:helppsico_mobile/domain/entities/psicologo_entity.dart';

// Mock classes
class MockGenericHttp implements IGenericHttp {
  final Map<String, HttpResponse> _responses = {};
  final List<Map<String, dynamic>> _requests = [];
  
  void setResponse(String url, HttpResponse response) {
    _responses[url] = response;
  }
  
  List<Map<String, dynamic>> get requests => _requests;
  
  @override
  Future<HttpResponse> get(String url, {Map<String, String>? headers}) async {
    _requests.add({
      'method': 'GET',
      'url': url,
      'headers': headers,
    });
    
    return _responses[url] ?? HttpResponse(
      statusCode: 404,
      body: {'error': 'Not found'},
      headers: {},
    );
  }
  
  @override
  Future<HttpResponse> post(String url, dynamic body, {Map<String, String>? headers}) async {
    _requests.add({
      'method': 'POST',
      'url': url,
      'body': body,
      'headers': headers,
    });
    
    return _responses[url] ?? HttpResponse(
      statusCode: 404,
      body: {'error': 'Not found'},
      headers: {},
    );
  }
  
  @override
  Future<HttpResponse> put(String url, dynamic body, {Map<String, String>? headers}) async {
    _requests.add({
      'method': 'PUT',
      'url': url,
      'body': body,
      'headers': headers,
    });
    
    return _responses[url] ?? HttpResponse(
      statusCode: 404,
      body: {'error': 'Not found'},
      headers: {},
    );
  }
  
  @override
  Future<HttpResponse> delete(String url, {Map<String, String>? headers}) async {
    _requests.add({
      'method': 'DELETE',
      'url': url,
      'headers': headers,
    });
    
    return _responses[url] ?? HttpResponse(
      statusCode: 404,
      body: {'error': 'Not found'},
      headers: {},
    );
  }
}

class MockSecureStorageService implements SecureStorageService {
  final Map<String, String?> _storage = {};
  
  @override
  Future<String?> getToken() async {
    return _storage['token'];
  }
  
  @override
  Future<void> saveToken(String token) async {
    _storage['token'] = token;
  }
  
  @override
  Future<void> deleteToken() async {
    _storage.remove('token');
  }
  
  @override
  Future<String?> getUserData() async {
    return _storage['userData'];
  }
  
  @override
  Future<void> saveUserData(String userData) async {
    _storage['userData'] = userData;
  }
  
  @override
  Future<void> deleteUserData() async {
    _storage.remove('userData');
  }
  
  @override
  Future<String?> getUserId() async {
    return _storage['userId'];
  }
  
  @override
  Future<void> saveUserId(String userId) async {
    _storage['userId'] = userId;
  }
  
  @override
  Future<String?> getUserEmail() async {
    return _storage['userEmail'];
  }
  
  @override
  Future<void> saveUserEmail(String userEmail) async {
    _storage['userEmail'] = userEmail;
  }
  
  @override
  Future<String?> getPsicologoData() async {
    return _storage['psicologoData'];
  }
  
  @override
  Future<void> savePsicologoData(String psicologoData) async {
    _storage['psicologoData'] = psicologoData;
  }
  
  @override
  Future<void> clearAll() async {
    _storage.clear();
  }
  
  // Implementações vazias para outros métodos não utilizados nos testes
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class MockPsicologoService implements PsicologoService {
  Map<String, String>? _mockPsicologoInfo;
  
  void setMockPsicologoInfo(Map<String, String>? info) {
    _mockPsicologoInfo = info;
  }
  
  @override
  Future<Map<String, String>?> getPsicologoByPacienteId(String pacienteId) async {
    return _mockPsicologoInfo;
  }
  
  // Implementações vazias para outros métodos não utilizados nos testes
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  group('AuthResponse Tests', () {
    test('should create AuthResponse with all required fields', () {
      // Arrange & Act
      final authResponse = AuthResponse(
        id: '123',
        name: 'John Doe',
        email: 'john@example.com',
        role: 'PACIENTE',
        message: 'Login realizado com sucesso',
        token: 'Bearer token123',
      );
      
      // Assert
      expect(authResponse.id, '123');
      expect(authResponse.name, 'John Doe');
      expect(authResponse.email, 'john@example.com');
      expect(authResponse.role, 'PACIENTE');
      expect(authResponse.message, 'Login realizado com sucesso');
      expect(authResponse.token, 'Bearer token123');
    });
    
    test('should create AuthResponse from JSON', () {
      // Arrange
      final json = {
        'id': 456,
        'name': 'Jane Smith',
        'email': 'jane@example.com',
        'role': 'PSICOLOGO',
        'message': 'Success',
        'token': 'Bearer abc123',
      };
      
      // Act
      final authResponse = AuthResponse.fromJson(json);
      
      // Assert
      expect(authResponse.id, '456');
      expect(authResponse.name, 'Jane Smith');
      expect(authResponse.email, 'jane@example.com');
      expect(authResponse.role, 'PSICOLOGO');
      expect(authResponse.message, 'Success');
      expect(authResponse.token, 'Bearer abc123');
    });
    
    test('should handle null values in JSON', () {
      // Arrange
      final json = {
        'id': null,
        'name': null,
        'email': null,
        'role': null,
        'message': null,
        'token': null,
      };
      
      // Act
      final authResponse = AuthResponse.fromJson(json);
      
      // Assert
      expect(authResponse.id, '');
      expect(authResponse.name, null);
      expect(authResponse.email, null);
      expect(authResponse.role, null);
      expect(authResponse.message, null);
      expect(authResponse.token, null);
    });
  });
  
  group('AuthService Tests', () {
    late AuthService authService;
    late MockGenericHttp mockHttp;
    late MockSecureStorageService mockStorage;
    late MockPsicologoService mockPsicologoService;
    
    setUp(() {
      mockHttp = MockGenericHttp();
      mockStorage = MockSecureStorageService();
      mockPsicologoService = MockPsicologoService();
      authService = AuthService(
        http: mockHttp,
        storage: mockStorage,
        psicologoService: mockPsicologoService,
      );
    });
    
    group('Constructor', () {
      test('should create AuthService with provided dependencies', () {
        // Act
        final service = AuthService(
          http: mockHttp,
          storage: mockStorage,
          psicologoService: mockPsicologoService,
        );
        
        // Assert
        expect(service, isA<AuthService>());
      });
      
      test('should create AuthService with default dependencies', () {
        // Act & Assert - Should not throw exception
        expect(() => AuthService(), returnsNormally);
      });
    });
    
    group('login', () {
      test('should login successfully with valid credentials', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const token = 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyLCJleHAiOjk5OTk5OTk5OTl9.Lkylf_fsOSdNKUuLNlXlXaLPo4qHcqOOKvGvOp8rF5I';
        
        final loginResponse = HttpResponse(
          statusCode: 200,
          body: {
            'dado': {
              'token': token,
              'idUsuario': '123',
              'email': email,
            },
          },
          headers: {},
        );
        
        mockHttp.setResponse('http://10.0.2.2:8080/login/paciente', loginResponse);
        mockPsicologoService.setMockPsicologoInfo({
          'id': 'psych123',
          'nome': 'Dr. Silva',
          'crp': 'CRP-123',
        });
        
        // Act
        final result = await authService.login(email, password);
        
        // Assert
        expect(result.id, '123');
        expect(result.email, email);
        expect(result.role, 'PACIENTE');
        expect(result.token, token);
        expect(result.message, 'Login realizado com sucesso');
        
        // Verify storage calls
        expect(await mockStorage.getToken(), token);
        expect(await mockStorage.getUserId(), '123');
        expect(await mockStorage.getUserEmail(), email);
        
        final userData = await mockStorage.getUserData();
        expect(userData, isNotNull);
        final userMap = json.decode(userData!);
        expect(userMap['id'], '123');
        expect(userMap['email'], email);
        expect(userMap['role'], 'PACIENTE');
        
        final psicologoData = await mockStorage.getPsicologoData();
        expect(psicologoData, isNotNull);
        final psicologoMap = json.decode(psicologoData!);
        expect(psicologoMap['id'], 'psych123');
        expect(psicologoMap['nome'], 'Dr. Silva');
        expect(psicologoMap['crp'], 'CRP-123');
      });
      
      test('should login successfully without psicologo info', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        const token = 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyLCJleHAiOjk5OTk5OTk5OTl9.Lkylf_fsOSdNKUuLNlXlXaLPo4qHcqOOKvGvOp8rF5I';
        
        final loginResponse = HttpResponse(
          statusCode: 200,
          body: {
            'dado': {
              'token': token,
              'idUsuario': '123',
              'email': email,
            },
          },
          headers: {},
        );
        
        mockHttp.setResponse('http://10.0.2.2:8080/login/paciente', loginResponse);
        mockPsicologoService.setMockPsicologoInfo(null);
        
        // Act
        final result = await authService.login(email, password);
        
        // Assert
        expect(result.id, '123');
        expect(result.email, email);
        expect(result.role, 'PACIENTE');
        expect(result.token, token);
        
        // Verify no psicologo data is saved
        final psicologoData = await mockStorage.getPsicologoData();
        expect(psicologoData, isNull);
      });
      
      test('should throw exception when login fails with 401', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'wrongpassword';
        
        final loginResponse = HttpResponse(
          statusCode: 401,
          body: {
            'mensagem': 'Credenciais inválidas',
          },
          headers: {},
        );
        
        mockHttp.setResponse('http://10.0.2.2:8080/login/paciente', loginResponse);
        
        // Act & Assert
        expect(
          () async => await authService.login(email, password),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Credenciais inválidas'),
          )),
        );
      });
      
      test('should throw exception when response data is null', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        
        final loginResponse = HttpResponse(
          statusCode: 200,
          body: {
            'dado': null,
          },
          headers: {},
        );
        
        mockHttp.setResponse('http://10.0.2.2:8080/login/paciente', loginResponse);
        
        // Act & Assert
        expect(
          () async => await authService.login(email, password),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Dados de resposta inválidos'),
          )),
        );
      });
      
      test('should throw exception when authentication data is incomplete', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        
        final loginResponse = HttpResponse(
          statusCode: 200,
          body: {
            'dado': {
              'token': null,
              'idUsuario': '123',
              'email': email,
            },
          },
          headers: {},
        );
        
        mockHttp.setResponse('http://10.0.2.2:8080/login/paciente', loginResponse);
        
        // Act & Assert
        expect(
          () async => await authService.login(email, password),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Dados de autenticação incompletos'),
          )),
        );
      });
      
      test('should handle HTTP request exception', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        
        // Don't set any response, will trigger default 404
        
        // Act & Assert
        expect(
          () async => await authService.login(email, password),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Falha ao autenticar'),
          )),
        );
      });
    });
    
    group('isAuthenticated', () {
      test('should return true when token is valid and not expired', () async {
        // Arrange
        const validToken = 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyLCJleHAiOjk5OTk5OTk5OTl9.Lkylf_fsOSdNKUuLNlXlXaLPo4qHcqOOKvGvOp8rF5I';
        await mockStorage.saveToken(validToken);
        
        // Act
        final result = await authService.isAuthenticated();
        
        // Assert
        expect(result, true);
      });
      
      test('should return false when token is null', () async {
        // Arrange - No token saved
        
        // Act
        final result = await authService.isAuthenticated();
        
        // Assert
        expect(result, false);
      });
      
      test('should return false when token is expired', () async {
        // Arrange
        const expiredToken = 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyLCJleHAiOjE1MTYyMzkwMjJ9.4Adcj3UFYzPUVaVF43FmMab6RlaQD8A9V8wFzzht-KQ';
        await mockStorage.saveToken(expiredToken);
        
        // Act
        final result = await authService.isAuthenticated();
        
        // Assert
        expect(result, false);
      });
    });
    
    group('getUserInfo', () {
      test('should return user info when user data exists', () async {
        // Arrange
        final user = User(
          id: '123',
          name: 'John Doe',
          email: 'john@example.com',
          password: '',
          role: 'PACIENTE',
          psicologo: null,
        );
        await mockStorage.saveUserData(json.encode(user.toJson()));
        
        // Act
        final result = await authService.getUserInfo();
        
        // Assert
        expect(result, isNotNull);
        expect(result!['id'], '123');
        expect(result['name'], 'John Doe');
        expect(result['email'], 'john@example.com');
        expect(result['role'], 'PACIENTE');
      });
      
      test('should include psicologo info when available', () async {
        // Arrange
        final user = User(
          id: '123',
          name: 'John Doe',
          email: 'john@example.com',
          password: '',
          role: 'PACIENTE',
          psicologo: null,
        );
        await mockStorage.saveUserData(json.encode(user.toJson()));
        
        final psicologo = Psicologo(
          id: 'psych123',
          nome: 'Dr. Silva',
          crp: 'CRP-123',
        );
        await mockStorage.savePsicologoData(json.encode(psicologo.toJson()));
        
        // Act
        final result = await authService.getUserInfo();
        
        // Assert
        expect(result, isNotNull);
        expect(result!['psicologo'], isNotNull);
        expect(result['psicologo']['id'], 'psych123');
        expect(result['psicologo']['nome'], 'Dr. Silva');
        expect(result['psicologo']['crp'], 'CRP-123');
      });
      
      test('should return null when no user data exists', () async {
        // Arrange - No user data saved
        
        // Act
        final result = await authService.getUserInfo();
        
        // Assert
        expect(result, isNull);
      });
      
      test('should return null when user data is invalid JSON', () async {
        // Arrange
        await mockStorage.saveUserData('invalid json');
        
        // Act
        final result = await authService.getUserInfo();
        
        // Assert
        expect(result, isNull);
      });
    });
    
    group('getAuthHeaders', () {
      test('should return headers with authorization when token exists', () async {
        // Arrange
        const token = 'Bearer token123';
        await mockStorage.saveToken(token);
        
        // Act
        final result = await authService.getAuthHeaders();
        
        // Assert
        expect(result['Authorization'], token);
        expect(result['Content-Type'], 'application/json');
      });
      
      test('should return empty headers when token is null', () async {
        // Arrange - No token saved
        
        // Act
        final result = await authService.getAuthHeaders();
        
        // Assert
        expect(result, {});
      });
    });
    
    group('logout', () {
      test('should clear all stored data', () async {
        // Arrange
        await mockStorage.saveToken('token');
        await mockStorage.saveUserData('userData');
        await mockStorage.saveUserId('123');
        await mockStorage.saveUserEmail('test@example.com');
        
        // Act
        await authService.logout();
        
        // Assert
        expect(await mockStorage.getToken(), isNull);
        expect(await mockStorage.getUserData(), isNull);
        expect(await mockStorage.getUserId(), isNull);
        expect(await mockStorage.getUserEmail(), isNull);
      });
    });
    
    group('getToken', () {
      test('should return token when exists', () async {
        // Arrange
        const token = 'Bearer token123';
        await mockStorage.saveToken(token);
        
        // Act
        final result = await authService.getToken();
        
        // Assert
        expect(result, token);
      });
      
      test('should return empty string when token is null', () async {
        // Arrange - No token saved
        
        // Act
        final result = await authService.getToken();
        
        // Assert
        expect(result, '');
      });
    });
    
    group('getCurrentUser', () {
      test('should return user ID when exists', () async {
        // Arrange
        const userId = '123';
        await mockStorage.saveUserId(userId);
        
        // Act
        final result = await authService.getCurrentUser();
        
        // Assert
        expect(result, userId);
      });
      
      test('should return null when user ID does not exist', () async {
        // Arrange - No user ID saved
        
        // Act
        final result = await authService.getCurrentUser();
        
        // Assert
        expect(result, isNull);
      });
    });
    
    group('Edge Cases', () {
      test('should handle special characters in email and password', () async {
        // Arrange
        const email = 'test+special@example.com';
        const password = 'p@ssw0rd!@#\$%';
        const token = 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyLCJleHAiOjk5OTk5OTk5OTl9.Lkylf_fsOSdNKUuLNlXlXaLPo4qHcqOOKvGvOp8rF5I';
        
        final loginResponse = HttpResponse(
          statusCode: 200,
          body: {
            'dado': {
              'token': token,
              'idUsuario': '123',
              'email': email,
            },
          },
          headers: {},
        );
        
        mockHttp.setResponse('http://10.0.2.2:8080/login/paciente', loginResponse);
        mockPsicologoService.setMockPsicologoInfo(null);
        
        // Act
        final result = await authService.login(email, password);
        
        // Assert
        expect(result.email, email);
        expect(result.name, 'test+special'); // Email prefix
      });
      
      test('should handle empty email and password', () async {
        // Arrange
        const email = '';
        const password = '';
        
        final loginResponse = HttpResponse(
          statusCode: 400,
          body: {
            'mensagem': 'Email e senha são obrigatórios',
          },
          headers: {},
        );
        
        mockHttp.setResponse('http://10.0.2.2:8080/login/paciente', loginResponse);
        
        // Act & Assert
        expect(
          () async => await authService.login(email, password),
          throwsA(isA<Exception>()),
        );
      });
      
      test('should handle very long token', () async {
        // Arrange
        final longToken = 'Bearer ${'a' * 1000}';
        await mockStorage.saveToken(longToken);
        
        // Act
        final result = await authService.getToken();
        
        // Assert
        expect(result, longToken);
      });
    });
  });
}