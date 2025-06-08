

import 'package:get_it/get_it.dart';
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
      : _storage =  GetIt.instance.get<SecureStorageService>(),
        _authService = authService ?? AuthService();

  @override
  String get baseUrl {

    const bool isAndroid = bool.fromEnvironment('dart.vm.android');
    const host = isAndroid ? 'http://10.0.2.2:8080' : 'http://localhost:8080';
    return '$host/consultas';
    
  }

  Future<String?> _getPacienteId() async {
    try {
      final pacienteId = await _storage.getUserId();
      print('Paciente ID obtained: $pacienteId');
      return pacienteId;
    } catch (e) {
      print('Error obtaining Paciente ID: $e');
      return null;
    }
  }

  Future<String?> _getPsicologoId() async {
    final pacienteId = await _getPacienteId();
    if (pacienteId == null) {
      print('Paciente ID is null');
      return null;
    }

    final vinculoUrl = 'http://localhost:8080/vinculos/paciente/$pacienteId';
    final headers = await _authService.getAuthHeaders();
    
    try {
      final response = await _http.get(vinculoUrl, headers: headers);
      print('Response from vinculo URL: ${response.statusCode}');
      
      if (response.statusCode == 200 && response.body['dado'] != null) {
        final psicologoId = response.body['dado']['idPsicologo']?.toString();
        print('Psicologo ID obtained: $psicologoId');
        return psicologoId;
      }
      return null;
    } catch (e) {
      print('Error obtaining Psicologo ID: $e');
      return null;
    }
  }

  
  @override
  Future<HttpResponse> getSessions() async {
    final pacienteId = await _getPacienteId();
    
    if (pacienteId == null) {
      print('Paciente ID necessary for getSessions is null');
      throw Exception('Não foi possível obter o ID do paciente');
    }

    // Endpoint atualizado conforme o controller Java: /paciente/historico/{idPaciente}
    final url = '$baseUrl/paciente/futuras/$pacienteId';
    final headers = await _authService.getAuthHeaders();
    
    print('Fetching historical sessions from: $url');
    return _http.get(url, headers: headers);
  }


  @override
  Future<HttpResponse> getNextSession() async {
    final pacienteId = await _getPacienteId();
    
    if (pacienteId == null) {
      print('Paciente ID necessary for getNextSession is null');
      throw Exception('Não foi possível obter o ID do paciente');
    }

    // Endpoint atualizado conforme o controller Java: /paciente/futuras/{idPaciente}
    final url = '$baseUrl/paciente/futuras/$pacienteId';
    final headers = await _authService.getAuthHeaders();
    
    print('Fetching next sessions from: $url');
    final response = await _http.get(url, headers: headers);
    print('Response from next sessions URL: ${response.statusCode}');
    
    // A lógica de tratamento da resposta para pegar a primeira futura sessão permanece
    // Assumindo que a API retorna uma página de consultas e queremos a primeira.
    if (response.statusCode == 200 && response.body['dado'] != null) {
      final consultasPage = response.body['dado'];
      final consultas = consultasPage['content'] as List<dynamic>?;
      
      if (consultas != null && consultas.isNotEmpty) {
        print('Next session found');
        // Retorna a primeira consulta da lista de futuras sessões
        return HttpResponse(
          statusCode: 200,
          body: consultas.first, 
        );
      }
    }
    
    print('No upcoming sessions found');
    return HttpResponse(
      statusCode: 200, // Mantém 200 OK mesmo sem sessões, mas com corpo vazio
      body: {}, 
    );
  }
}

