import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';
import 'package:helppsico_mobile/core/services/storage/secure_storage_service.dart';
import 'package:http/http.dart' as http;


// Mock classes
class MockHttpClient extends http.BaseClient {
  final Map<String, http.Response> _responses = {};
  final List<http.BaseRequest> _requests = [];
  
  void setResponse(String url, http.Response response) {
    _responses[url] = response;
  }
  
  List<http.BaseRequest> get requests => _requests;
  
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    _requests.add(request);
    
    final response = _responses[request.url.toString()];
    if (response != null) {
      return http.StreamedResponse(
        Stream.fromIterable([response.bodyBytes]),
        response.statusCode,
        headers: response.headers,
        request: request,
      );
    }
    
    // Default response se não encontrar mock
    return http.StreamedResponse(
      Stream.fromIterable([utf8.encode('{"error": "Not found"}')]),
      404,
      request: request,
    );
  }
}

class MockSecureStorageService implements SecureStorageService {
  String? _mockToken;
  
  void setMockToken(String? token) {
    _mockToken = token;
  }
  
  @override
  Future<String?> getToken() async {
    return _mockToken;
  }
  
  // Implementações vazias para outros métodos não utilizados nos testes
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  group('HttpResponse Tests', () {
    test('should create HttpResponse with all properties', () {
      final response = HttpResponse(
        statusCode: 200,
        body: '{"message": "success"}',
        headers: {'content-type': 'application/json'},
     
      );
      
      expect(response.statusCode, 200);
      expect(response.body, '{"message": "success"}');
      expect(response.headers, {'content-type': 'application/json'});
    });
    
    test('should create HttpResponse with empty headers', () {
      final response = HttpResponse(
        statusCode: 404,
        body: 'Not found',
        headers: {},
      );
      
      expect(response.statusCode, 404);
      expect(response.body, 'Not found');
      expect(response.headers, {});
    });
  });
  
  group('GenericHttp Tests', () {
    late GenericHttp genericHttp;
    late MockHttpClient mockHttpClient;
    late MockSecureStorageService mockStorageService;
    
    setUp(() {
      mockHttpClient = MockHttpClient();
      mockStorageService = MockSecureStorageService();
      genericHttp = GenericHttp(
        client: mockHttpClient,
        secureStorageService: mockStorageService,
      );
    });
    
    group('GET Requests', () {
      test('should perform GET request successfully', () async {
        // Arrange
        const url = 'https://api.example.com/users';
        const responseBody = '{"users": []}';
        mockHttpClient.setResponse(url, http.Response(responseBody, 200));
        mockStorageService.setMockToken('valid-token');
        
        // Act
        final response = await genericHttp.get(url);
        
        // Assert
        expect(response.statusCode, 200);
        expect(response.body, responseBody);
        expect(mockHttpClient.requests.length, 1);
        expect(mockHttpClient.requests.first.method, 'GET');
        expect(mockHttpClient.requests.first.url.toString(), url);
      });
      
      test('should include authorization header when token exists', () async {
        // Arrange
        const url = 'https://api.example.com/users';
        const token = 'Bearer valid-token';
        mockHttpClient.setResponse(url, http.Response('{}', 200));
        mockStorageService.setMockToken(token);
        
        // Act
        await genericHttp.get(url);
        
        // Assert
        final request = mockHttpClient.requests.first;
        expect(request.headers['Authorization'], token);
      });
      
      test('should not include authorization header when token is null', () async {
        // Arrange
        const url = 'https://api.example.com/users';
        mockHttpClient.setResponse(url, http.Response('{}', 200));
        mockStorageService.setMockToken(null);
        
        // Act
        await genericHttp.get(url);
        
        // Assert
        final request = mockHttpClient.requests.first;
        expect(request.headers.containsKey('Authorization'), false);
      });
      
      test('should handle GET request with query parameters', () async {
        // Arrange
        const url = 'https://api.example.com/users?page=1&limit=10';
        mockHttpClient.setResponse(url, http.Response('{}', 200));
        mockStorageService.setMockToken('token');
        
        // Act
        await genericHttp.get(url);
        
        // Assert
        final request = mockHttpClient.requests.first;
        expect(request.url.toString(), url);
        expect(request.url.queryParameters['page'], '1');
        expect(request.url.queryParameters['limit'], '10');
      });
    });
    
    group('POST Requests', () {
      test('should perform POST request successfully', () async {
        // Arrange
        const url = 'https://api.example.com/users';
        const requestBody = '{"name": "John"}';
        const responseBody = '{"id": 1, "name": "John"}';
        mockHttpClient.setResponse(url, http.Response(responseBody, 201));
        mockStorageService.setMockToken('token');
        
        // Act
        final response = await genericHttp.post(url, requestBody);
        
        // Assert
        expect(response.statusCode, 201);
        expect(response.body, responseBody);
        expect(mockHttpClient.requests.length, 1);
        expect(mockHttpClient.requests.first.method, 'POST');
      });
      
      test('should include correct headers for POST request', () async {
        // Arrange
        const url = 'https://api.example.com/users';
        const requestBody = '{"name": "John"}';
        mockHttpClient.setResponse(url, http.Response('{}', 201));
        mockStorageService.setMockToken('Bearer token');
        
        // Act
        await genericHttp.post(url, requestBody);
        
        // Assert
        final request = mockHttpClient.requests.first;
        expect(request.headers['Content-Type'], 'application/json');
        expect(request.headers['Authorization'], 'Bearer token');
      });
      
      test('should handle POST request with empty body', () async {
        // Arrange
        const url = 'https://api.example.com/users';
        mockHttpClient.setResponse(url, http.Response('{}', 200));
        mockStorageService.setMockToken('token');
        
        // Act
        final response = await genericHttp.post(url, '');
        
        // Assert
        expect(response.statusCode, 200);
        expect(mockHttpClient.requests.first.method, 'POST');
      });
    });
    
    group('PUT Requests', () {
      test('should perform PUT request successfully', () async {
        // Arrange
        const url = 'https://api.example.com/users/1';
        const requestBody = '{"name": "John Updated"}';
        const responseBody = '{"id": 1, "name": "John Updated"}';
        mockHttpClient.setResponse(url, http.Response(responseBody, 200));
        mockStorageService.setMockToken('token');
        
        // Act
        final response = await genericHttp.put(url, requestBody);
        
        // Assert
        expect(response.statusCode, 200);
        expect(response.body, responseBody);
        expect(mockHttpClient.requests.length, 1);
        expect(mockHttpClient.requests.first.method, 'PUT');
      });
      
      test('should include correct headers for PUT request', () async {
        // Arrange
        const url = 'https://api.example.com/users/1';
        const requestBody = '{"name": "John"}';
        mockHttpClient.setResponse(url, http.Response('{}', 200));
        mockStorageService.setMockToken('Bearer token');
        
        // Act
        await genericHttp.put(url, requestBody);
        
        // Assert
        final request = mockHttpClient.requests.first;
        expect(request.headers['Content-Type'], 'application/json');
        expect(request.headers['Authorization'], 'Bearer token');
      });
    });
    
    group('DELETE Requests', () {
      test('should perform DELETE request successfully', () async {
        // Arrange
        const url = 'https://api.example.com/users/1';
        mockHttpClient.setResponse(url, http.Response('', 204));
        mockStorageService.setMockToken('token');
        
        // Act
        final response = await genericHttp.delete(url);
        
        // Assert
        expect(response.statusCode, 204);
        expect(response.body, '');
        expect(mockHttpClient.requests.length, 1);
        expect(mockHttpClient.requests.first.method, 'DELETE');
      });
      
      test('should include authorization header for DELETE request', () async {
        // Arrange
        const url = 'https://api.example.com/users/1';
        mockHttpClient.setResponse(url, http.Response('', 204));
        mockStorageService.setMockToken('Bearer token');
        
        // Act
        await genericHttp.delete(url);
        
        // Assert
        final request = mockHttpClient.requests.first;
        expect(request.headers['Authorization'], 'Bearer token');
      });
    });
    
    group('Error Handling', () {
      test('should handle 404 error response', () async {
        // Arrange
        const url = 'https://api.example.com/users/999';
        mockHttpClient.setResponse(url, http.Response('Not found', 404));
        mockStorageService.setMockToken('token');
        
        // Act
        final response = await genericHttp.get(url);
        
        // Assert
        expect(response.statusCode, 404);
        expect(response.body, 'Not found');
      });
      
      test('should handle 500 error response', () async {
        // Arrange
        const url = 'https://api.example.com/users';
        mockHttpClient.setResponse(url, http.Response('Internal server error', 500));
        mockStorageService.setMockToken('token');
        
        // Act
        final response = await genericHttp.get(url);
        
        // Assert
        expect(response.statusCode, 500);
        expect(response.body, 'Internal server error');
      });
      
      test('should handle network timeout', () async {
        // Arrange
        const url = 'https://api.example.com/users';
        mockHttpClient.setResponse(url, http.Response('Request timeout', 408));
        mockStorageService.setMockToken('token');
        
        // Act
        final response = await genericHttp.get(url);
        
        // Assert
        expect(response.statusCode, 408);
        expect(response.body, 'Request timeout');
      });
    });
    
    group('Headers and Content Type', () {
      test('should preserve response headers', () async {
        // Arrange
        const url = 'https://api.example.com/users';
        final responseHeaders = {
          'content-type': 'application/json',
          'x-custom-header': 'custom-value',
        };
        mockHttpClient.setResponse(url, http.Response('{}', 200, headers: responseHeaders));
        mockStorageService.setMockToken('token');
        
        // Act
        final response = await genericHttp.get(url);
        
        // Assert
        expect(response.headers?['content-type'], 'application/json');
        expect(response.headers?['x-custom-header'], 'custom-value');
      });
      
      test('should handle empty response headers', () async {
        // Arrange
        const url = 'https://api.example.com/users';
        mockHttpClient.setResponse(url, http.Response('{}', 200, headers: {}));
        mockStorageService.setMockToken('token');
        
        // Act
        final response = await genericHttp.get(url);
        
        // Assert
        expect(response.headers, {});
      });
    });
    
    group('Special Characters and Encoding', () {
      test('should handle special characters in request body', () async {
        // Arrange
        const url = 'https://api.example.com/users';
        const requestBody = '{"name": "João da Silva & Cia", "description": "Descrição com acentos"}';
        mockHttpClient.setResponse(url, http.Response('{}', 201));
        mockStorageService.setMockToken('token');
        
        // Act
        final response = await genericHttp.post(url, requestBody);
        
        // Assert
        expect(response.statusCode, 201);
      });
      
      test('should handle special characters in response body', () async {
        // Arrange
        const url = 'https://api.example.com/users';
        const responseBody = '{"name": "José", "city": "São Paulo"}';
        mockHttpClient.setResponse(url, http.Response(responseBody, 200));
        mockStorageService.setMockToken('token');
        
        // Act
        final response = await genericHttp.get(url);
        
        // Assert
        expect(response.statusCode, 200);
        expect(response.body, responseBody);
      });
    });
    
    group('Large Data Handling', () {
      test('should handle large request body', () async {
        // Arrange
        const url = 'https://api.example.com/upload';
        final largeBody = '{"data": "${'A' * 10000}"}';
        mockHttpClient.setResponse(url, http.Response('{}', 200));
        mockStorageService.setMockToken('token');
        
        // Act
        final response = await genericHttp.post(url, largeBody);
        
        // Assert
        expect(response.statusCode, 200);
      });
      
      test('should handle large response body', () async {
        // Arrange
        const url = 'https://api.example.com/download';
        final largeResponse = '{"data": "${'B' * 10000}"}';
        mockHttpClient.setResponse(url, http.Response(largeResponse, 200));
        mockStorageService.setMockToken('token');
        
        // Act
        final response = await genericHttp.get(url);
        
        // Assert
        expect(response.statusCode, 200);
        expect(response.body, largeResponse);
      });
    });
  });
}