import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';
import 'package:helppsico_mobile/core/services/auth/auth_service.dart';
import 'package:helppsico_mobile/core/services/storage/secure_storage_service.dart';

class DocumentsDataSource {
  String baseUrl = 'http://localhost:8080';
  final IGenericHttp _http;
  final SecureStorageService _secureStorage;
  final AuthService _authService;

  DocumentsDataSource(
    this._http,
    this._secureStorage,
    this._authService,
  ) {
    if (const bool.fromEnvironment('IS_TEST')) {
      baseUrl = 'http://10.0.2.2:8080';
    }
  }

  Future<String> _getPacienteId() async {
    final userId = await _secureStorage.getUserId(); 
    if (userId != null && userId.isNotEmpty) {
      return userId;
    }
    final userInfo = await _authService.getUserInfo(); 
    final patientId = userInfo?['id'] as String?;
    if (patientId != null && patientId.isNotEmpty) {
      await _secureStorage.saveUserId(patientId);
      return patientId;
    }
    throw Exception('ID do paciente não encontrado no SecureStorage nem via AuthService.');
  }

  Future<HttpResponse> _handleHttpRequest(Future<HttpResponse> Function() httpRequest) async {
    final response = await httpRequest();
    if (response.statusCode != 200 && response.statusCode != 201 && response.statusCode != 204) {
      final errorMessage = (response.body is Map && response.body.containsKey('mensagem'))
        ? response.body['mensagem']
        : 'Falha na operação HTTP.';
      throw Exception(errorMessage);
    }
    return response;
  }

  Future<HttpResponse> getDocuments() async {
    final pacienteId = await _getPacienteId();
    final endpoint = '$baseUrl/documentos/$pacienteId';
    return _handleHttpRequest(() => _http.get(endpoint));
  }

  Future<HttpResponse> uploadDocument(String filePath, Map<String, dynamic> metadata) async {
    final pacienteId = await _getPacienteId();
    final solicitacaoDocumentoDto = {
      'idPaciente': pacienteId,
      'titulo': metadata['title'] ?? '', 
      'descricao': metadata['description'] ?? '',
      'tipo': metadata['type'] ?? 'OUTRO', 
      'urlArquivo': filePath, 
    };
    final endpoint = '$baseUrl/solicitacoes-documentos'; 
    return _handleHttpRequest(() => _http.post(endpoint, solicitacaoDocumentoDto));
  }

  Future<HttpResponse> deleteDocument(String documentId) async {
    final endpoint = '$baseUrl/documentos/$documentId'; 
    return _handleHttpRequest(() => _http.delete(endpoint));
  }
}
