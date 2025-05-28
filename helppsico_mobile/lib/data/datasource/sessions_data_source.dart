import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';
import 'package:helppsico_mobile/core/services/storage/secure_storage_service.dart';
import 'package:helppsico_mobile/core/services/auth/auth_service.dart';

abstract class ISessionsDataSource {
  String get baseUrl;
  Future<HttpResponse> getSessions();
  Future<HttpResponse> getNextSession();
}

class SessionsDataSource implements ISessionsDataSource {
  final IGenericHttp _http;
  final SecureStorageService _storage;
  final AuthService _authService;
  
  SessionsDataSource(this._http, {SecureStorageService? storage, AuthService? authService})
      : _storage = storage ?? SecureStorageService(),
        _authService = authService ?? AuthService();

  @override
  String get baseUrl {
    const bool isAndroid = bool.fromEnvironment('dart.vm.android');
    final host = isAndroid ? 'http://10.0.2.2:8080' : 'http://localhost:8080';
    return '$host/consultas';
  }

  /// Obtém o ID do paciente a partir do armazenamento
  Future<String?> _getPacienteId() async {
    return await _storage.getUserId();
  }

  /// Obtém o ID do psicólogo vinculado ao paciente
  Future<String?> _getPsicologoId() async {
    final pacienteId = await _getPacienteId();
    if (pacienteId == null) return null;
    
    // Endpoint para obter o vínculo do paciente com o psicólogo
    final vinculoUrl = 'http://localhost:8080/vinculos/paciente/$pacienteId';
    final headers = await _authService.getAuthHeaders();
    
    try {
      final response = await _http.get(vinculoUrl, headers: headers);
      
      if (response.statusCode == 200 && response.body['dado'] != null) {
        // Extrai o ID do psicólogo do vínculo
        return response.body['dado']['idPsicologo']?.toString();
      }
      return null;
    } catch (e) {
      print('Erro ao obter vínculo do paciente: $e');
      return null;
    }
  }

  @override
  Future<HttpResponse> getSessions() async {
    final pacienteId = await _getPacienteId();
    final psicologoId = await _getPsicologoId();
    
    if (pacienteId == null || psicologoId == null) {
      throw Exception('Não foi possível obter os IDs necessários');
    }
    
    // Endpoint para consultas históricas
    final url = '$baseUrl/historico/$pacienteId/$psicologoId';
    final headers = await _authService.getAuthHeaders();
    
    print('Buscando consultas históricas de: $url');
    return _http.get(url, headers: headers);
  }

  @override
  Future<HttpResponse> getNextSession() async {
    final pacienteId = await _getPacienteId();
    final psicologoId = await _getPsicologoId();
    
    if (pacienteId == null || psicologoId == null) {
      throw Exception('Não foi possível obter os IDs necessários');
    }
    
    // Endpoint para consultas futuras (próximas)
    final url = '$baseUrl/futuras/$pacienteId/$psicologoId';
    final headers = await _authService.getAuthHeaders();
    
    print('Buscando próximas consultas de: $url');
    final response = await _http.get(url, headers: headers);
    
    if (response.statusCode == 200 && response.body['dado'] != null) {
      // A API retorna uma página de consultas, pegamos a primeira como a próxima
      final consultasPage = response.body['dado'];
      final consultas = consultasPage['content'] as List<dynamic>?;
      
      if (consultas != null && consultas.isNotEmpty) {
        // Retorna a primeira consulta futura como a próxima
        return HttpResponse(
          statusCode: 200,
          body: consultas.first,
        );
      }
    }
    
    // Se não houver consultas futuras
    return HttpResponse(
      statusCode: 200,
      body: {},
    );
  }
}