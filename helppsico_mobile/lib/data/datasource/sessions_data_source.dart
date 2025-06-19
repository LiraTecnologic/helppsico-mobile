

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
      : _storage = storage ?? GetIt.instance.get<SecureStorageService>(),
        _authService = authService ?? AuthService();

  @override
  String get baseUrl {
    const isTest = bool.fromEnvironment('IS_TEST');
    final host = isTest ? 'http://10.0.2.2:8080' : 'http://localhost:8080';
    return '$host/consultas';
  }

  Future<String?> _getPacienteId() async {
    try {
      final pacienteId = await _storage.getUserId();
      return pacienteId;
    } catch (e) {
      return null;
    }
  }


  @override
  Future<HttpResponse> getSessions() async {
    final pacienteId = await _getPacienteId();

    if (pacienteId == null) {
      throw Exception('Não foi possível obter o ID do paciente');
    }

    final url = '$baseUrl/paciente/futuras/$pacienteId';
    final headers = await _authService.getAuthHeaders();

    return _http.get(url, headers: headers);
  }

  @override
  Future<HttpResponse> getNextSession() async {
    final pacienteId = await _getPacienteId();

    if (pacienteId == null) {
      throw Exception('Não foi possível obter o ID do paciente');
    }

    final url = '$baseUrl/paciente/futuras/$pacienteId';
    final headers = await _authService.getAuthHeaders();

    final response = await _http.get(url, headers: headers);

    if (response.statusCode == 200 && response.body['dado'] != null) {
      final consultasPage = response.body['dado'];
      final consultas = consultasPage['content'] as List<dynamic>?;

      if (consultas != null && consultas.isNotEmpty) {
        return HttpResponse(
          statusCode: 200,
          body: consultas.first,
        );
      }
    }

    return HttpResponse(
      statusCode: 200,
      body: {},
    );
  }
}

