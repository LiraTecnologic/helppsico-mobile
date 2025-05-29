import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';
import 'package:helppsico_mobile/core/services/storage/secure_storage_service.dart';
import 'package:helppsico_mobile/core/services/auth/auth_service.dart';

abstract class IVinculosDataSource {
  String get baseUrl;
  Future<HttpResponse> getVinculoByPacienteId();
  Future<HttpResponse> solicitarVinculo(String psicologoId);
  Future<HttpResponse> cancelarVinculo(String vinculoId);

}

class VinculosDataSource implements IVinculosDataSource {
  final IGenericHttp _http;
  final SecureStorageService _secureStorage;
  final AuthService _authService;
  
  VinculosDataSource(this._http, {SecureStorageService? storage, AuthService? authService})
      : _secureStorage = storage ?? SecureStorageService(),
        _authService = authService ?? AuthService();

  @override
  String get baseUrl {
    const bool isAndroid = bool.fromEnvironment('dart.vm.android');
    final host = isAndroid ? 'http://10.0.2.2:8080' : 'http://localhost:8080';
    return '$host/vinculos';
  }

  /// Obtém o ID do paciente a partir do armazenamento
  Future<String?> _getPacienteId() async {
    try {
      // Primeiro tenta obter do SecureStorage
      final userId = await _secureStorage.getUserId();
      if (userId != null && userId.isNotEmpty) {
        return userId;
      }
      
      // Como fallback, tenta obter do AuthService
      final userId2 = await _authService.getCurrentUser();
      return userId2;
    } catch (e) {
      print('Erro ao obter ID do paciente: $e');
      return null;
    }
  }

  @override
  Future<HttpResponse> getVinculoByPacienteId() async {
    final pacienteId = await _getPacienteId();
    if (pacienteId == null) {
      throw Exception('Não foi possível obter o ID do paciente');
    }
    
    // Endpoint para obter o vínculo do paciente com o psicólogo
    final url = '$baseUrl/paciente/$pacienteId';
    final headers = await _authService.getAuthHeaders();
    
    try {
      final response = await _http.get(url, headers: headers);
      
      if (response.statusCode == 200) {
        return response;
      } else {
        final errorMessage = response.body['mensagem'] ?? 'Falha ao obter vínculo';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Erro ao obter vínculo do paciente: $e');
      throw Exception('Erro de conexão: $e');
    }
  }

  @override
  Future<HttpResponse> solicitarVinculo(String psicologoId) async {
    final pacienteId = await _getPacienteId();
    if (pacienteId == null) {
      throw Exception('Não foi possível obter o ID do paciente');
    }
    
    final vinculoDto = {
      'idPaciente': pacienteId,
      'idPsicologo': psicologoId,
    };
    
    final headers = await _authService.getAuthHeaders();
    
    try {
      final response = await _http.post(baseUrl, vinculoDto, headers: headers);
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return response;
      } else {
        final errorMessage = response.body['mensagem'] ?? 'Falha ao solicitar vínculo';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Erro ao solicitar vínculo: $e');
      throw Exception('Erro de conexão: $e');
    }
  }

  @override
  Future<HttpResponse> cancelarVinculo(String vinculoId) async {
    final headers = await _authService.getAuthHeaders();
    
    try {
      final response = await _http.delete('$baseUrl/$vinculoId', headers: headers);
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        return response;
      } else {
        final errorMessage = response.body != null && response.body is Map ? 
            response.body['mensagem'] ?? 'Falha ao cancelar vínculo' : 
            'Falha ao cancelar vínculo';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Erro ao cancelar vínculo: $e');
      throw Exception('Erro de conexão: $e');
    }
  }
}