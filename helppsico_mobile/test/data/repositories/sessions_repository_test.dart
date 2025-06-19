import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';
import 'package:helppsico_mobile/core/services/storage/secure_storage_service.dart';
import 'package:helppsico_mobile/data/repositories/sessions_repository.dart';
import 'package:helppsico_mobile/domain/entities/session_model.dart';
import 'package:helppsico_mobile/core/services/auth/auth_service.dart';
import 'package:helppsico_mobile/data/datasource/sessions_data_source.dart';

// Mock classes
class MockGenericHttp implements IGenericHttp {
  final Map<String, HttpResponse> _responses = {};
  final List<String> _requestUrls = [];
  
  void setResponse(String url, HttpResponse response) {
    _responses[url] = response;
  }
  
  List<String> get requestUrls => _requestUrls;
  
  @override
  Future<HttpResponse> get(String url, {Map<String, String>? headers}) async {
    _requestUrls.add(url);
    return _responses[url] ?? HttpResponse(statusCode: 404, body: 'Not found', headers: {});
  }
  
  @override
  Future<HttpResponse> post(String url, dynamic body, {Map<String, String>? headers}) async {
    _requestUrls.add(url);
    return _responses[url] ?? HttpResponse(statusCode: 404, body: 'Not found', headers: {});
  }
  
  @override
  Future<HttpResponse> put(String url, dynamic body, {Map<String, String>? headers}) async {
    _requestUrls.add(url);
    return _responses[url] ?? HttpResponse(statusCode: 404, body: 'Not found', headers: {});
  }
  
  @override
  Future<HttpResponse> delete(String url, {Map<String, String>? headers}) async {
    _requestUrls.add(url);
    return _responses[url] ?? HttpResponse(statusCode: 404, body: 'Not found', headers: {});
  }
}

class MockSecureStorageService implements SecureStorageService {
  String? _mockUserId;
  final Map<String, String> _storage = {};
  
  void setMockUserId(String? userId) {
    _mockUserId = userId;
  }
  
  @override
  Future<String?> getString(String key) async {
    return _storage[key];
  }

  @override
  Future<void> setString(String key, String value) async {
    _storage[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _storage.remove(key);
  }

  @override
  Future<String?> getUserId() async {
    return _mockUserId;
  }

  @override
  Future<void> saveToken(String token) async {
    await setString('jwt_token', token);
  }

  @override
  Future<String?> getToken() async {
    return getString('jwt_token');
  }

  @override
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> deleteToken() async {
    await remove('jwt_token');
  }

  @override
  Future<void> saveUserData(String userData) async {
    await setString('user_data', userData);
  }

  @override
  Future<String?> getUserData() async {
    return getString('user_data');
  }

  @override
  Future<void> deleteUserData() async {
    await remove('user_data');
  }

  @override
  Future<void> saveUserId(String userId) async {
    _mockUserId = userId;
    await setString('user_id', userId);
  }

  @override
  Future<void> saveUserEmail(String email) async {
    await setString('user_email', email);
  }

  @override
  Future<String?> getUserEmail() async {
    return getString('user_email');
  }

  @override
  Future<void> savePsicologoData(String psicologoData) async {
    await setString('psicologo_data', psicologoData);
  }

  @override
  Future<String?> getPsicologoData() async {
    return getString('psicologo_data');
  }

  @override
  Future<void> deletePsicologoData() async {
    await remove('psicologo_data');
  }

  @override
  Future<void> clearAll() async {
    _storage.clear();
    _mockUserId = null;
  }

  @override
  Future<List<String>> getFavoriteDocumentIds() async {
    final jsonString = await getString('favorite_documents');
    if (jsonString != null) {
      final List<dynamic> decodedList = jsonDecode(jsonString);
      return decodedList.cast<String>().toList();
    }
    return [];
  }

  @override
  Future<bool> isDocumentFavorite(String documentId) async {
    final favoriteIds = await getFavoriteDocumentIds();
    return favoriteIds.contains(documentId);
  }

  @override
  Future<void> addFavoriteDocumentId(String documentId) async {
    final favoriteIds = await getFavoriteDocumentIds();
    if (!favoriteIds.contains(documentId)) {
      favoriteIds.add(documentId);
      await setString('favorite_documents', jsonEncode(favoriteIds));
    }
  }

  @override
  Future<void> removeFavoriteDocumentId(String documentId) async {
    final favoriteIds = await getFavoriteDocumentIds();
    if (favoriteIds.contains(documentId)) {
      favoriteIds.remove(documentId);
      await setString('favorite_documents', jsonEncode(favoriteIds));
    }
  }

  @override
  Future<void> toggleFavoriteDocumentId(String documentId) async {
    final favoriteIds = await getFavoriteDocumentIds();
    if (favoriteIds.contains(documentId)) {
      favoriteIds.remove(documentId);
    } else {
      favoriteIds.add(documentId);
    }
    await setString('favorite_documents', jsonEncode(favoriteIds));
  }
}

void main() {
  group('SessionRepository Tests', () {
    late SessionRepository sessionRepository;
    late MockGenericHttp mockGenericHttp;
    late MockSecureStorageService mockSecureStorageService;
    
    setUp(() {
      mockGenericHttp = MockGenericHttp();
      mockSecureStorageService = MockSecureStorageService();
      final mockAuthService = AuthService();
      final mockDataSource = SessionsDataSource(
        mockGenericHttp,
        storage: mockSecureStorageService,
        authService: mockAuthService,
      );
      sessionRepository = SessionRepository(mockDataSource);
    });
    
    group('getSessions', () {
      test('should return list of sessions when API call is successful', () async {
        // Arrange
        const userId = '123';
        const responseBody = '''
        {
          "dado": {
            "content": [
              {
                "id": "session1",
                "nomePsicologo": "Dr. João",
                "idPaciente": "123",
                "data": "2024-01-15",
                "horario": {
                  "inicio": "10:00:00"
                },
                "psicologo": {
                  "valorSessao": "150.00"
                },
                "endereco": "Rua A, 123",
                "finalizada": true
              },
            {
              "id": "session2",
              "nomePsicologo": "Dr. Maria",
              "idPaciente": "123",
              "data": "2024-01-20",
              "horario": {
                "inicio": "14:00:00"
              },
              "psicologo": {
                "valorSessao": "200.00"
              },
              "endereco": "Rua B, 456",
              "finalizada": false
            }
          ]
        }
      }
        ''';
        
        mockSecureStorageService.setMockUserId(userId);
        mockGenericHttp.setResponse(
          'http://10.0.2.2:8080/consultas/paciente/futuras/$userId',
          HttpResponse(statusCode: 200, body: responseBody, headers: {}),
        );
        
        // Act
        final sessions = await sessionRepository.getSessions();
        
        // Assert
        expect(sessions, isA<List<SessionModel>>());
        expect(sessions.length, 2);
        expect(sessions[0].id, 'session1');
        expect(sessions[0].psicologoName, 'Dr. João');
        expect(sessions[0].pacienteId, '123');
        expect(sessions[0].finalizada, true);
        expect(sessions[1].id, 'session2');
        expect(sessions[1].psicologoName, 'Dr. Maria');
        expect(sessions[1].finalizada, false);
      });
      
      test('should return empty list when no sessions found', () async {
        // Arrange
        const userId = '123';
        const responseBody = '{"dado": {"content": []}}';
        
        mockSecureStorageService.setMockUserId(userId);
        mockGenericHttp.setResponse(
          'http://10.0.2.2:8080/consultas/paciente/futuras/$userId',
          HttpResponse(statusCode: 200, body: responseBody, headers: {}),
        );
        
        // Act
        final sessions = await sessionRepository.getSessions();
        
        // Assert
        expect(sessions, isA<List<SessionModel>>());
        expect(sessions.length, 0);
      });
      
      test('should return empty list when user ID is null', () async {
        // Arrange
        mockSecureStorageService.setMockUserId(null);
        
        // Act
        final sessions = await sessionRepository.getSessions();
        
        // Assert
        expect(sessions, isA<List<SessionModel>>());
        expect(sessions.length, 0);
      });
      
      test('should return empty list when user ID is empty', () async {
        // Arrange
        mockSecureStorageService.setMockUserId('');
        
        // Act
        final sessions = await sessionRepository.getSessions();
        
        // Assert
        expect(sessions, isA<List<SessionModel>>());
        expect(sessions.length, 0);
      });
      
      test('should throw exception on API error', () async {
        // Arrange
        const userId = '123';
        
        mockSecureStorageService.setMockUserId(userId);
        mockGenericHttp.setResponse(
          'http://10.0.2.2:8080/consultas/paciente/futuras/$userId',
          HttpResponse(statusCode: 500, body: '{"mensagem": "Erro interno"}', headers: {}),
        );
        
        // Act & Assert
        expect(
          () => sessionRepository.getSessions(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            'Exception: Erro interno',
          )),
        );
      });
      
      test('should throw exception on malformed JSON response', () async {
        // Arrange
        const userId = '123';
        const malformedResponse = '{"dado": invalid json';
        
        mockSecureStorageService.setMockUserId(userId);
        mockGenericHttp.setResponse(
          'http://10.0.2.2:8080/consultas/paciente/futuras/$userId',
          HttpResponse(statusCode: 200, body: malformedResponse, headers: {}),
        );
        
        // Act & Assert
        expect(
          () => sessionRepository.getSessions(),
          throwsA(isA<Exception>()),
        );
      });
      
      test('should handle response without consultas field', () async {
        // Arrange
        const userId = '123';
        const responseBody = '{"dado": {"other": "some other data"}}';
        
        mockSecureStorageService.setMockUserId(userId);
        mockGenericHttp.setResponse(
          'http://10.0.2.2:8080/consultas/paciente/futuras/$userId',
          HttpResponse(statusCode: 200, body: responseBody, headers: {}),
        );
        
        // Act
        final sessions = await sessionRepository.getSessions();
        
        // Assert
        expect(sessions, isA<List<SessionModel>>());
        expect(sessions.length, 0);
      });
      
      test('should handle null consultas field', () async {
        // Arrange
        const userId = '123';
        const responseBody = '{"dado": {"content": null}}';
        
        mockSecureStorageService.setMockUserId(userId);
        mockGenericHttp.setResponse(
          'http://10.0.2.2:8080/consultas/paciente/futuras/$userId',
          HttpResponse(statusCode: 200, body: responseBody, headers: {}),
        );
        
        // Act
        final sessions = await sessionRepository.getSessions();
        
        // Assert
        expect(sessions, isA<List<SessionModel>>());
        expect(sessions.length, 0);
      });
      
      test('should handle sessions with missing fields', () async {
        // Arrange
        const userId = '123';
        const responseBody = '''
        {
          "dado": {
            "content": [
              {
                "id": "session1"
              },
              {
                "nomePsicologo": "Dr. Maria",
                "data": "2024-01-15",
                "horario": {
                  "inicio": "10:00:00"
                }
              }
            ]
          }
        }
        ''';
        
        mockSecureStorageService.setMockUserId(userId);
        mockGenericHttp.setResponse(
          'http://10.0.2.2:8080/consultas/paciente/futuras/$userId',
          HttpResponse(statusCode: 200, body: responseBody, headers: {}),
        );
        
        // Act
        final sessions = await sessionRepository.getSessions();
        
        // Assert
        expect(sessions, isA<List<SessionModel>>());
        expect(sessions.length, 2);
        expect(sessions[0].id, 'session1');
        expect(sessions[1].psicologoName, 'Dr. Maria');
      });
    });
    
    group('getNextSession', () {
      test('should return next upcoming session', () async {
        // Arrange
        const userId = '123';
        final futureDate = DateTime.now().add(const Duration(days: 1));
        final pastDate = DateTime.now().subtract(const Duration(days: 1));
        
        final responseBody = '''
        {
          "dado": {
            "content": [
              {
                "id": "session1",
                "nomePsicologo": "Dr. João",
                "idPaciente": "123",
                "data": "${pastDate.toString().split(' ')[0]}",
                "horario": {
                  "inicio": "10:00:00"
                },
                "psicologo": {
                  "valorSessao": "150.00"
                },
                "endereco": "Rua A, 123",
                "finalizada": true
              },
              {
                "id": "session2",
                "nomePsicologo": "Dr. Maria",
                "idPaciente": "123",
                "data": "${futureDate.toString().split(' ')[0]}",
                "horario": {
                  "inicio": "14:00:00"
                },
                "psicologo": {
                  "valorSessao": "200.00"
                },
                "endereco": "Rua B, 456",
                "finalizada": false
              }
            ]
          }
        }
        ''';
        
        mockSecureStorageService.setMockUserId(userId);
        mockGenericHttp.setResponse(
          'http://10.0.2.2:8080/consultas/paciente/futuras/$userId',
          HttpResponse(statusCode: 200, body: responseBody, headers: {}),
        );
        
        // Act
        final nextSession = await sessionRepository.getNextSession();
        
        // Assert
        expect(nextSession, isNotNull);
        expect(nextSession!.id, 'session2');
        expect(nextSession.psicologoName, 'Dr. Maria');
        expect(nextSession.finalizada, false);
      });
      
      test('should return null when no upcoming sessions', () async {
        // Arrange
        const userId = '123';
        final pastDate = DateTime.now().subtract(const Duration(days: 1));
        
        final responseBody = '''
        {
          "consultas": [
            {
              "id": "session1",
              "psicologoNome": "Dr. João",
              "pacienteId": "123",
              "data": "${pastDate.toIso8601String()}",
              "valor": "150.00",
              "endereco": "Rua A, 123",
              "finalizada": true
            }
          ]
        }
        ''';
        
        mockSecureStorageService.setMockUserId(userId);
        mockGenericHttp.setResponse(
          'http://10.0.2.2:8080/consultas/paciente/futuras/$userId',
          HttpResponse(statusCode: 200, body: responseBody, headers: {}),
        );
        
        // Act
        final nextSession = await sessionRepository.getNextSession();
        
        // Assert
        expect(nextSession, isNull);
      });
      
      test('should return null when no sessions exist', () async {
        // Arrange
        const userId = '123';
        const responseBody = '{"dado": {"content": []}}';
        
        mockSecureStorageService.setMockUserId(userId);
        mockGenericHttp.setResponse(
          'http://10.0.2.2:8080/consultas/paciente/futuras/$userId',
          HttpResponse(statusCode: 200, body: responseBody, headers: {}),
        );
        
        // Act
        final nextSession = await sessionRepository.getNextSession();
        
        // Assert
        expect(nextSession, isNull);
      });
      
      test('should return earliest upcoming session when multiple exist', () async {
        // Arrange
        const userId = '123';
        final futureDate1 = DateTime.now().add(const Duration(days: 2));
        final futureDate2 = DateTime.now().add(const Duration(days: 1));
        final futureDate3 = DateTime.now().add(const Duration(days: 3));
        
        final responseBody = '''
        {
          "consultas": [
            {
              "id": "session1",
              "psicologoNome": "Dr. João",
              "data": "${futureDate1.toIso8601String()}",
              "finalizada": false
            },
            {
              "id": "session2",
              "psicologoNome": "Dr. Maria",
              "data": "${futureDate2.toIso8601String()}",
              "finalizada": false
            },
            {
              "id": "session3",
              "psicologoNome": "Dr. Pedro",
              "data": "${futureDate3.toIso8601String()}",
              "finalizada": false
            }
          ]
        }
        ''';
        
        mockSecureStorageService.setMockUserId(userId);
        mockGenericHttp.setResponse(
          'http://10.0.2.2:8080/consultas/paciente/futuras/$userId',
          HttpResponse(statusCode: 200, body: responseBody, headers: {}),
        );
        
        // Act
        final nextSession = await sessionRepository.getNextSession();
        
        // Assert
        expect(nextSession, isNotNull);
        expect(nextSession!.id, 'session2'); // Earliest future session
        expect(nextSession.psicologoName, 'Dr. Maria');
      });
      
      test('should throw exception on API error for getNextSession', () async {
        // Arrange
        const userId = '123';
        
        mockSecureStorageService.setMockUserId(userId);
        mockGenericHttp.setResponse(
          'http://10.0.2.2:8080/consultas/paciente/futuras/$userId',
          HttpResponse(statusCode: 500, body: '{"mensagem": "Erro ao buscar próxima sessão"}', headers: {}),
        );
        
        // Act & Assert
        expect(
          () => sessionRepository.getNextSession(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            'Exception: Erro ao buscar próxima sessão',
          )),
        );
      });
      
      test('should return null when response body is empty', () async {
        // Arrange
        const userId = '123';
        const responseBody = '{}';
        
        mockSecureStorageService.setMockUserId(userId);
        mockGenericHttp.setResponse(
          'http://10.0.2.2:8080/consultas/paciente/futuras/$userId',
          HttpResponse(statusCode: 200, body: responseBody, headers: {}),
        );
        
        // Act
        final nextSession = await sessionRepository.getNextSession();
        
        // Assert
        expect(nextSession, isNull);
      });
    });
    
    group('API URL Construction', () {
      test('should construct correct API URL for getSessions', () async {
        // Arrange
        const userId = '123';
        mockSecureStorageService.setMockUserId(userId);
        mockGenericHttp.setResponse(
          'http://10.0.2.2:8080/consultas/paciente/futuras/$userId',
          HttpResponse(statusCode: 200, body: '{"dado": {"content": []}}', headers: {}),
        );
        
        // Act
        await sessionRepository.getSessions();
        
        // Assert
        expect(mockGenericHttp.requestUrls.length, 1);
        expect(mockGenericHttp.requestUrls.first, 'http://10.0.2.2:8080/consultas/paciente/futuras/$userId');
      });
      
      test('should handle special characters in user ID', () async {
        // Arrange
        const userId = 'user@123';
        mockSecureStorageService.setMockUserId(userId);
        mockGenericHttp.setResponse(
          'http://10.0.2.2:8080/consultas/paciente/futuras/$userId',
          HttpResponse(statusCode: 200, body: '{"dado": {"content": []}}', headers: {}),
        );
        
        // Act
        await sessionRepository.getSessions();
        
        // Assert
        expect(mockGenericHttp.requestUrls.first, 'http://10.0.2.2:8080/consultas/paciente/futuras/$userId');
      });
    });
  });
}