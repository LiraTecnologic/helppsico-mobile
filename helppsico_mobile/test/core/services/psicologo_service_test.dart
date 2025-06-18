import 'package:flutter_test/flutter_test.dart';
import 'package:helppsico_mobile/core/services/psicologo/psicologo_service.dart';
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';
import 'package:helppsico_mobile/core/services/storage/secure_storage_service.dart';
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
  Future<String?> getUserId() async {
    return _storage['userId'];
  }
  
  @override
  Future<void> saveUserId(String userId) async {
    _storage['userId'] = userId;
  }
  
  // Implementações vazias para outros métodos não utilizados nos testes
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  group('PsicologoService Tests', () {
    late PsicologoService psicologoService;
    late MockGenericHttp mockHttp;
    late MockSecureStorageService mockStorage;
    
    setUp(() {
      mockHttp = MockGenericHttp();
      mockStorage = MockSecureStorageService();
      psicologoService = PsicologoService(
        http: mockHttp,
        storage: mockStorage,
      );
    });
    
    group('Constructor', () {
      test('should create PsicologoService with provided dependencies', () {
        // Act
        final service = PsicologoService(
          http: mockHttp,
          storage: mockStorage,
        );
        
        // Assert
        expect(service, isA<PsicologoService>());
      });
      
      test('should create PsicologoService with default dependencies', () {
        // Act & Assert - Should not throw exception
        expect(() => PsicologoService(), returnsNormally);
      });
    });
    
    group('getPsicologos', () {
      test('should return list of psicologos when request is successful', () async {
        // Arrange
        const token = 'Bearer token123';
        await mockStorage.saveToken(token);
        
        final psicologosResponse = HttpResponse(
          statusCode: 200,
          body: {
            'dados': [
              {
                'id': '1',
                'nome': 'Dr. João Silva',
                'email': 'joao@example.com',
                'crp': 'CRP-123456',
                'telefone': '11999999999',
                'biografia': 'Psicólogo especialista em terapia cognitiva',
                'valorSessao': 150.0,
                'status': 'ATIVO',
                'endereco': {
                  'rua': 'Rua das Flores, 123',
                  'cidade': 'São Paulo',
                  'estado': 'SP',
                  'cep': '01234-567',
                },
              },
              {
                'id': '2',
                'nome': 'Dra. Maria Santos',
                'email': 'maria@example.com',
                'crp': 'CRP-789012',
                'telefone': '11888888888',
                'biografia': 'Especialista em psicologia infantil',
                'valorSessao': 120.0,
                'status': 'ATIVO',
              },
            ],
          },
          headers: {},
        );
        
        mockHttp.setResponse('http://10.0.2.2:8080/psicologos', psicologosResponse);
        
        // Act
        final result = await psicologoService.getPsicologos();
        
        // Assert
        expect(result, hasLength(2));
        expect(result[0].id, '1');
        expect(result[0].nome, 'Dr. João Silva');
        expect(result[0].crp, 'CRP-123456');
        expect(result[0].valorSessao, 150.0);
        expect(result[0].endereco?.rua, 'Rua das Flores, 123');
        expect(result[1].id, '2');
        expect(result[1].nome, 'Dra. Maria Santos');
        expect(result[1].valorSessao, 120.0);
        
        // Verify request was made with correct headers
        final request = mockHttp.requests.first;
        expect(request['method'], 'GET');
        expect(request['url'], 'http://10.0.2.2:8080/psicologos');
        expect(request['headers']['Authorization'], token);
        expect(request['headers']['Content-Type'], 'application/json');
      });
      
      test('should return empty list when no psicologos exist', () async {
        // Arrange
        const token = 'Bearer token123';
        await mockStorage.saveToken(token);
        
        final psicologosResponse = HttpResponse(
          statusCode: 200,
          body: {
            'dados': [],
          },
          headers: {},
        );
        
        mockHttp.setResponse('http://10.0.2.2:8080/psicologos', psicologosResponse);
        
        // Act
        final result = await psicologoService.getPsicologos();
        
        // Assert
        expect(result, isEmpty);
      });
      
      test('should return empty list when dados field is null', () async {
        // Arrange
        const token = 'Bearer token123';
        await mockStorage.saveToken(token);
        
        final psicologosResponse = HttpResponse(
          statusCode: 200,
          body: {
            'dados': null,
          },
          headers: {},
        );
        
        mockHttp.setResponse('http://10.0.2.2:8080/psicologos', psicologosResponse);
        
        // Act
        final result = await psicologoService.getPsicologos();
        
        // Assert
        expect(result, isEmpty);
      });
      
      test('should throw exception when token is null', () async {
        // Arrange
        // Don't save token
        
        // Act & Assert
        expect(
          () async => await psicologoService.getPsicologos(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Token de autenticação não encontrado'),
          )),
        );
      });
      
      test('should throw exception when request fails', () async {
        // Arrange
        const token = 'Bearer token123';
        await mockStorage.saveToken(token);
        
        final errorResponse = HttpResponse(
          statusCode: 500,
          body: {
            'mensagem': 'Erro interno do servidor',
          },
          headers: {},
        );
        
        mockHttp.setResponse('http://10.0.2.2:8080/psicologos', errorResponse);
        
        // Act & Assert
        expect(
          () async => await psicologoService.getPsicologos(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Falha ao buscar psicólogos'),
          )),
        );
      });
    });
    
    group('getPsicologoById', () {
      test('should return psicologo when found', () async {
        // Arrange
        const token = 'Bearer token123';
        const psicologoId = '123';
        await mockStorage.saveToken(token);
        
        final psicologoResponse = HttpResponse(
          statusCode: 200,
          body: {
            'dado': {
              'id': '123',
              'nome': 'Dr. João Silva',
              'email': 'joao@example.com',
              'crp': 'CRP-123456',
              'telefone': '11999999999',
              'biografia': 'Psicólogo especialista',
              'valorSessao': 150.0,
              'status': 'ATIVO',
            },
          },
          headers: {},
        );
        
        mockHttp.setResponse('http://10.0.2.2:8080/psicologos/123', psicologoResponse);
        
        // Act
        final result = await psicologoService.getPsicologoById(psicologoId);
        
        // Assert
        expect(result, isNotNull);
        expect(result!.id, '123');
        expect(result.nome, 'Dr. João Silva');
        expect(result.crp, 'CRP-123456');
        expect(result.valorSessao, 150.0);
        
        // Verify request was made correctly
        final request = mockHttp.requests.first;
        expect(request['method'], 'GET');
        expect(request['url'], 'http://10.0.2.2:8080/psicologos/123');
        expect(request['headers']['Authorization'], token);
      });
      
      test('should return null when psicologo not found', () async {
        // Arrange
        const token = 'Bearer token123';
        const psicologoId = '999';
        await mockStorage.saveToken(token);
        
        final notFoundResponse = HttpResponse(
          statusCode: 404,
          body: {
            'mensagem': 'Psicólogo não encontrado',
          },
          headers: {},
        );
        
        mockHttp.setResponse('http://10.0.2.2:8080/psicologos/999', notFoundResponse);
        
        // Act
        final result = await psicologoService.getPsicologoById(psicologoId);
        
        // Assert
        expect(result, isNull);
      });
      
      test('should return null when response data is null', () async {
        // Arrange
        const token = 'Bearer token123';
        const psicologoId = '123';
        await mockStorage.saveToken(token);
        
        final psicologoResponse = HttpResponse(
          statusCode: 200,
          body: {
            'dado': null,
          },
          headers: {},
        );
        
        mockHttp.setResponse('http://10.0.2.2:8080/psicologos/123', psicologoResponse);
        
        // Act
        final result = await psicologoService.getPsicologoById(psicologoId);
        
        // Assert
        expect(result, isNull);
      });
      
      test('should throw exception when token is null', () async {
        // Arrange
        const psicologoId = '123';
        // Don't save token
        
        // Act & Assert
        expect(
          () async => await psicologoService.getPsicologoById(psicologoId),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Token de autenticação não encontrado'),
          )),
        );
      });
    });
    
    group('getPsicologoByPacienteId', () {
      test('should return psicologo info when found', () async {
        // Arrange
        const token = 'Bearer token123';
        const pacienteId = '456';
        await mockStorage.saveToken(token);
        
        final psicologoResponse = HttpResponse(
          statusCode: 200,
          body: {
            'dado': {
              'id': '123',
              'nome': 'Dr. João Silva',
              'crp': 'CRP-123456',
              'telefone': '11999999999',
              'email': 'joao@example.com',
            },
          },
          headers: {},
        );
        
        mockHttp.setResponse('http://10.0.2.2:8080/psicologos/paciente/456', psicologoResponse);
        
        // Act
        final result = await psicologoService.getPsicologoByPacienteId(pacienteId);
        
        // Assert
        expect(result, isNotNull);
        expect(result!['id'], '123');
        expect(result['nome'], 'Dr. João Silva');
        expect(result['crp'], 'CRP-123456');
        expect(result['telefone'], '11999999999');
        expect(result['email'], 'joao@example.com');
        
        // Verify request was made correctly
        final request = mockHttp.requests.first;
        expect(request['method'], 'GET');
        expect(request['url'], 'http://10.0.2.2:8080/psicologos/paciente/456');
        expect(request['headers']['Authorization'], token);
      });
      
      test('should return null when psicologo not found for paciente', () async {
        // Arrange
        const token = 'Bearer token123';
        const pacienteId = '999';
        await mockStorage.saveToken(token);
        
        final notFoundResponse = HttpResponse(
          statusCode: 404,
          body: {
            'mensagem': 'Psicólogo não encontrado para este paciente',
          },
          headers: {},
        );
        
        mockHttp.setResponse('http://10.0.2.2:8080/psicologos/paciente/999', notFoundResponse);
        
        // Act
        final result = await psicologoService.getPsicologoByPacienteId(pacienteId);
        
        // Assert
        expect(result, isNull);
      });
      
      test('should return null when response data is null', () async {
        // Arrange
        const token = 'Bearer token123';
        const pacienteId = '456';
        await mockStorage.saveToken(token);
        
        final psicologoResponse = HttpResponse(
          statusCode: 200,
          body: {
            'dado': null,
          },
          headers: {},
        );
        
        mockHttp.setResponse('http://10.0.2.2:8080/psicologos/paciente/456', psicologoResponse);
        
        // Act
        final result = await psicologoService.getPsicologoByPacienteId(pacienteId);
        
        // Assert
        expect(result, isNull);
      });
      
      test('should throw exception when token is null', () async {
        // Arrange
        const pacienteId = '456';
        // Don't save token
        
        // Act & Assert
        expect(
          () async => await psicologoService.getPsicologoByPacienteId(pacienteId),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Token de autenticação não encontrado'),
          )),
        );
      });
      
      test('should handle HTTP request exception', () async {
        // Arrange
        const token = 'Bearer token123';
        const pacienteId = '456';
        await mockStorage.saveToken(token);
        
        // Don't set any response, will trigger default 404
        
        // Act
        final result = await psicologoService.getPsicologoByPacienteId(pacienteId);
        
        // Assert
        expect(result, isNull);
      });
    });
    
    group('createPsicologo', () {
      test('should create psicologo successfully', () async {
        // Arrange
        const token = 'Bearer token123';
        await mockStorage.saveToken(token);
        
        final psicologo = Psicologo(
          id: '',
          nome: 'Dr. Novo Psicólogo',
          email: 'novo@example.com',
          crp: 'CRP-999999',
          telefone: '11777777777',
          biografia: 'Novo psicólogo especialista',
          valorSessao: 180.0,
          status: 'ATIVO',
        );
        
        final createResponse = HttpResponse(
          statusCode: 201,
          body: {
            'dado': {
              'id': 'new123',
              'nome': 'Dr. Novo Psicólogo',
              'email': 'novo@example.com',
              'crp': 'CRP-999999',
              'telefone': '11777777777',
              'biografia': 'Novo psicólogo especialista',
              'valorSessao': 180.0,
              'status': 'ATIVO',
            },
          },
          headers: {},
        );
        
        mockHttp.setResponse('http://10.0.2.2:8080/psicologos', createResponse);
        
        // Act
        final result = await psicologoService.createPsicologo(psicologo);
        
        // Assert
        expect(result.id, 'new123');
        expect(result.nome, 'Dr. Novo Psicólogo');
        expect(result.crp, 'CRP-999999');
        expect(result.valorSessao, 180.0);
        
        // Verify request was made correctly
        final request = mockHttp.requests.first;
        expect(request['method'], 'POST');
        expect(request['url'], 'http://10.0.2.2:8080/psicologos');
        expect(request['headers']['Authorization'], token);
        expect(request['body']['nome'], 'Dr. Novo Psicólogo');
        expect(request['body']['crp'], 'CRP-999999');
      });
      
      test('should throw exception when token is null', () async {
        // Arrange
        // Don't save token
        
        final psicologo = Psicologo(
          id: '',
          nome: 'Test',
          crp: 'CRP-123',
        );
        
        // Act & Assert
        expect(
          () async => await psicologoService.createPsicologo(psicologo),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Token de autenticação não encontrado'),
          )),
        );
      });
      
      test('should throw exception when creation fails', () async {
        // Arrange
        const token = 'Bearer token123';
        await mockStorage.saveToken(token);
        
        final psicologo = Psicologo(
          id: '',
          nome: 'Test',
          crp: 'CRP-123',
        );
        
        final errorResponse = HttpResponse(
          statusCode: 400,
          body: {
            'mensagem': 'Dados inválidos',
          },
          headers: {},
        );
        
        mockHttp.setResponse('http://10.0.2.2:8080/psicologos', errorResponse);
        
        // Act & Assert
        expect(
          () async => await psicologoService.createPsicologo(psicologo),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Falha ao criar psicólogo'),
          )),
        );
      });
      
      test('should throw exception when response data is null', () async {
        // Arrange
        const token = 'Bearer token123';
        await mockStorage.saveToken(token);
        
        final psicologo = Psicologo(
          id: '',
          nome: 'Test',
          crp: 'CRP-123',
        );
        
        final createResponse = HttpResponse(
          statusCode: 201,
          body: {
            'dado': null,
          },
          headers: {},
        );
        
        mockHttp.setResponse('http://10.0.2.2:8080/psicologos', createResponse);
        
        // Act & Assert
        expect(
          () async => await psicologoService.createPsicologo(psicologo),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Dados de resposta inválidos'),
          )),
        );
      });
    });
    
    group('updatePsicologo', () {
      test('should update psicologo successfully', () async {
        // Arrange
        const token = 'Bearer token123';
        await mockStorage.saveToken(token);
        
        final psicologo = Psicologo(
          id: '123',
          nome: 'Dr. João Silva Atualizado',
          email: 'joao.updated@example.com',
          crp: 'CRP-123456',
          telefone: '11999999999',
          biografia: 'Biografia atualizada',
          valorSessao: 200.0,
          status: 'ATIVO',
        );
        
        final updateResponse = HttpResponse(
          statusCode: 200,
          body: {
            'dado': {
              'id': '123',
              'nome': 'Dr. João Silva Atualizado',
              'email': 'joao.updated@example.com',
              'crp': 'CRP-123456',
              'telefone': '11999999999',
              'biografia': 'Biografia atualizada',
              'valorSessao': 200.0,
              'status': 'ATIVO',
            },
          },
          headers: {},
        );
        
        mockHttp.setResponse('http://10.0.2.2:8080/psicologos/123', updateResponse);
        
        // Act
        final result = await psicologoService.updatePsicologo(psicologo);
        
        // Assert
        expect(result.id, '123');
        expect(result.nome, 'Dr. João Silva Atualizado');
        expect(result.email, 'joao.updated@example.com');
        expect(result.biografia, 'Biografia atualizada');
        expect(result.valorSessao, 200.0);
        
        // Verify request was made correctly
        final request = mockHttp.requests.first;
        expect(request['method'], 'PUT');
        expect(request['url'], 'http://10.0.2.2:8080/psicologos/123');
        expect(request['headers']['Authorization'], token);
        expect(request['body']['nome'], 'Dr. João Silva Atualizado');
      });
      
      test('should throw exception when token is null', () async {
        // Arrange
        // Don't save token
        
        final psicologo = Psicologo(
          id: '123',
          nome: 'Test',
          crp: 'CRP-123',
        );
        
        // Act & Assert
        expect(
          () async => await psicologoService.updatePsicologo(psicologo),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Token de autenticação não encontrado'),
          )),
        );
      });
      
      test('should throw exception when update fails', () async {
        // Arrange
        const token = 'Bearer token123';
        await mockStorage.saveToken(token);
        
        final psicologo = Psicologo(
          id: '123',
          nome: 'Test',
          crp: 'CRP-123',
        );
        
        final errorResponse = HttpResponse(
          statusCode: 404,
          body: {
            'mensagem': 'Psicólogo não encontrado',
          },
          headers: {},
        );
        
        mockHttp.setResponse('http://10.0.2.2:8080/psicologos/123', errorResponse);
        
        // Act & Assert
        expect(
          () async => await psicologoService.updatePsicologo(psicologo),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Falha ao atualizar psicólogo'),
          )),
        );
      });
    });
    
    group('deletePsicologo', () {
      test('should delete psicologo successfully', () async {
        // Arrange
        const token = 'Bearer token123';
        const psicologoId = '123';
        await mockStorage.saveToken(token);
        
        final deleteResponse = HttpResponse(
          statusCode: 200,
          body: {
            'mensagem': 'Psicólogo excluído com sucesso',
          },
          headers: {},
        );
        
        mockHttp.setResponse('http://10.0.2.2:8080/psicologos/123', deleteResponse);
        
        // Act
        final result = await psicologoService.deletePsicologo(psicologoId);
        
        // Assert
        expect(result, true);
        
        // Verify request was made correctly
        final request = mockHttp.requests.first;
        expect(request['method'], 'DELETE');
        expect(request['url'], 'http://10.0.2.2:8080/psicologos/123');
        expect(request['headers']['Authorization'], token);
      });
      
      test('should return false when deletion fails', () async {
        // Arrange
        const token = 'Bearer token123';
        const psicologoId = '123';
        await mockStorage.saveToken(token);
        
        final errorResponse = HttpResponse(
          statusCode: 404,
          body: {
            'mensagem': 'Psicólogo não encontrado',
          },
          headers: {},
        );
        
        mockHttp.setResponse('http://10.0.2.2:8080/psicologos/123', errorResponse);
        
        // Act
        final result = await psicologoService.deletePsicologo(psicologoId);
        
        // Assert
        expect(result, false);
      });
      
      test('should throw exception when token is null', () async {
        // Arrange
        const psicologoId = '123';
        // Don't save token
        
        // Act & Assert
        expect(
          () async => await psicologoService.deletePsicologo(psicologoId),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Token de autenticação não encontrado'),
          )),
        );
      });
      
      test('should handle HTTP request exception', () async {
        // Arrange
        const token = 'Bearer token123';
        const psicologoId = '123';
        await mockStorage.saveToken(token);
        
        // Don't set any response, will trigger default 404
        
        // Act
        final result = await psicologoService.deletePsicologo(psicologoId);
        
        // Assert
        expect(result, false);
      });
    });
    
    group('searchPsicologos', () {
      test('should search psicologos by name successfully', () async {
        // Arrange
        const token = 'Bearer token123';
        const searchTerm = 'João';
        await mockStorage.saveToken(token);
        
        final searchResponse = HttpResponse(
          statusCode: 200,
          body: {
            'dados': [
              {
                'id': '1',
                'nome': 'Dr. João Silva',
                'email': 'joao@example.com',
                'crp': 'CRP-123456',
                'telefone': '11999999999',
                'biografia': 'Psicólogo especialista',
                'valorSessao': 150.0,
                'status': 'ATIVO',
              },
            ],
          },
          headers: {},
        );
        
        mockHttp.setResponse('http://10.0.2.2:8080/psicologos/buscar?nome=João', searchResponse);
        
        // Act
        final result = await psicologoService.searchPsicologos(searchTerm);
        
        // Assert
        expect(result, hasLength(1));
        expect(result[0].id, '1');
        expect(result[0].nome, 'Dr. João Silva');
        
        // Verify request was made correctly
        final request = mockHttp.requests.first;
        expect(request['method'], 'GET');
        expect(request['url'], 'http://10.0.2.2:8080/psicologos/buscar?nome=João');
        expect(request['headers']['Authorization'], token);
      });
      
      test('should return empty list when no psicologos match search', () async {
        // Arrange
        const token = 'Bearer token123';
        const searchTerm = 'NonExistent';
        await mockStorage.saveToken(token);
        
        final searchResponse = HttpResponse(
          statusCode: 200,
          body: {
            'dados': [],
          },
          headers: {},
        );
        
        mockHttp.setResponse('http://10.0.2.2:8080/psicologos/buscar?nome=NonExistent', searchResponse);
        
        // Act
        final result = await psicologoService.searchPsicologos(searchTerm);
        
        // Assert
        expect(result, isEmpty);
      });
      
      test('should throw exception when token is null', () async {
        // Arrange
        const searchTerm = 'João';
        // Don't save token
        
        // Act & Assert
        expect(
          () async => await psicologoService.searchPsicologos(searchTerm),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Token de autenticação não encontrado'),
          )),
        );
      });
    });
    
    group('Edge Cases', () {
      test('should handle psicologo with special characters', () async {
        // Arrange
        const token = 'Bearer token123';
        await mockStorage.saveToken(token);
        
        final psicologo = Psicologo(
          id: '',
          nome: 'Dr. José da Silva Ção',
          email: 'jose+test@example.com',
          crp: 'CRP-123456/SP',
          telefone: '+55 11 99999-9999',
          biografia: 'Especialista em terapia cognitivo-comportamental & EMDR',
          valorSessao: 150.50,
          status: 'ATIVO',
        );
        
        final createResponse = HttpResponse(
          statusCode: 201,
          body: {
            'dado': {
              'id': 'special123',
              'nome': 'Dr. José da Silva Ção',
              'email': 'jose+test@example.com',
              'crp': 'CRP-123456/SP',
              'telefone': '+55 11 99999-9999',
              'biografia': 'Especialista em terapia cognitivo-comportamental & EMDR',
              'valorSessao': 150.50,
              'status': 'ATIVO',
            },
          },
          headers: {},
        );
        
        mockHttp.setResponse('http://10.0.2.2:8080/psicologos', createResponse);
        
        // Act
        final result = await psicologoService.createPsicologo(psicologo);
        
        // Assert
        expect(result.nome, 'Dr. José da Silva Ção');
        expect(result.email, 'jose+test@example.com');
        expect(result.crp, 'CRP-123456/SP');
        expect(result.telefone, '+55 11 99999-9999');
        expect(result.biografia, 'Especialista em terapia cognitivo-comportamental & EMDR');
        expect(result.valorSessao, 150.50);
      });
      
      test('should handle empty psicologo ID for deletion', () async {
        // Arrange
        const token = 'Bearer token123';
        await mockStorage.saveToken(token);
        
        // Act
        final result = await psicologoService.deletePsicologo('');
        
        // Assert
        expect(result, false);
      });
      
      test('should handle very long biography', () async {
        // Arrange
        const token = 'Bearer token123';
        await mockStorage.saveToken(token);
        
        final longBiography = 'A' * 5000;
        
        final psicologo = Psicologo(
          id: '',
          nome: 'Dr. Test',
          crp: 'CRP-123',
          biografia: longBiography,
        );
        
        final createResponse = HttpResponse(
          statusCode: 201,
          body: {
            'dado': {
              'id': 'long123',
              'nome': 'Dr. Test',
              'crp': 'CRP-123',
              'biografia': longBiography,
            },
          },
          headers: {},
        );
        
        mockHttp.setResponse('http://10.0.2.2:8080/psicologos', createResponse);
        
        // Act
        final result = await psicologoService.createPsicologo(psicologo);
        
        // Assert
        expect(result.biografia, longBiography);
      });
      
      test('should handle search with special characters', () async {
        // Arrange
        const token = 'Bearer token123';
        const searchTerm = 'José & Maria';
        await mockStorage.saveToken(token);
        
        final searchResponse = HttpResponse(
          statusCode: 200,
          body: {
            'dados': [],
          },
          headers: {},
        );
        
        mockHttp.setResponse('http://10.0.2.2:8080/psicologos/buscar?nome=José & Maria', searchResponse);
        
        // Act
        final result = await psicologoService.searchPsicologos(searchTerm);
        
        // Assert
        expect(result, isEmpty);
        
        // Verify request was made with encoded URL
        final request = mockHttp.requests.first;
        expect(request['url'], contains('José & Maria'));
      });
    });
    
    group('Integration Tests', () {
      test('should complete full psicologo workflow', () async {
        // Arrange
        const token = 'Bearer token123';
        await mockStorage.saveToken(token);
        
        // Setup responses for the workflow
        final createResponse = HttpResponse(
          statusCode: 201,
          body: {
            'dado': {
              'id': 'workflow123',
              'nome': 'Dr. Workflow Test',
              'crp': 'CRP-WORKFLOW',
              'email': 'workflow@test.com',
              'valorSessao': 100.0,
              'status': 'ATIVO',
            },
          },
          headers: {},
        );
        
        final getResponse = HttpResponse(
          statusCode: 200,
          body: {
            'dado': {
              'id': 'workflow123',
              'nome': 'Dr. Workflow Test',
              'crp': 'CRP-WORKFLOW',
              'email': 'workflow@test.com',
              'valorSessao': 100.0,
              'status': 'ATIVO',
            },
          },
          headers: {},
        );
        
        final updateResponse = HttpResponse(
          statusCode: 200,
          body: {
            'dado': {
              'id': 'workflow123',
              'nome': 'Dr. Workflow Test Updated',
              'crp': 'CRP-WORKFLOW',
              'email': 'workflow@test.com',
              'valorSessao': 150.0,
              'status': 'ATIVO',
            },
          },
          headers: {},
        );
        
        final deleteResponse = HttpResponse(
          statusCode: 200,
          body: {
            'mensagem': 'Psicólogo excluído com sucesso',
          },
          headers: {},
        );
        
        mockHttp.setResponse('http://10.0.2.2:8080/psicologos', createResponse);
        mockHttp.setResponse('http://10.0.2.2:8080/psicologos/workflow123', getResponse);
        
        // Act & Assert
        
        // 1. Create psicologo
        final psicologo = Psicologo(
          id: '',
          nome: 'Dr. Workflow Test',
          crp: 'CRP-WORKFLOW',
          email: 'workflow@test.com',
          valorSessao: 100.0,
          status: 'ATIVO',
        );
        
        final created = await psicologoService.createPsicologo(psicologo);
        expect(created.id, 'workflow123');
        expect(created.nome, 'Dr. Workflow Test');
        expect(created.valorSessao, 100.0);
        
        // 2. Get psicologo by ID
        final retrieved = await psicologoService.getPsicologoById('workflow123');
        expect(retrieved, isNotNull);
        expect(retrieved!.id, 'workflow123');
        expect(retrieved.nome, 'Dr. Workflow Test');
        
        // 3. Update psicologo
        mockHttp.setResponse('http://10.0.2.2:8080/psicologos/workflow123', updateResponse);
        
        final updatedPsicologo = retrieved.copyWith(
          nome: 'Dr. Workflow Test Updated',
          valorSessao: 150.0,
        );
        
        final updated = await psicologoService.updatePsicologo(updatedPsicologo);
        expect(updated.nome, 'Dr. Workflow Test Updated');
        expect(updated.valorSessao, 150.0);
        
        // 4. Delete psicologo
        mockHttp.setResponse('http://10.0.2.2:8080/psicologos/workflow123', deleteResponse);
        
        final deleted = await psicologoService.deletePsicologo('workflow123');
        expect(deleted, true);
        
        // Verify all requests were made
        expect(mockHttp.requests, hasLength(4));
        expect(mockHttp.requests[0]['method'], 'POST');
        expect(mockHttp.requests[1]['method'], 'GET');
        expect(mockHttp.requests[2]['method'], 'PUT');
        expect(mockHttp.requests[3]['method'], 'DELETE');
      });
    });
  });
}