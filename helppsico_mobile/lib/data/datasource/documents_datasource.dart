
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';
import 'package:helppsico_mobile/core/services/auth/auth_service.dart';
import 'package:helppsico_mobile/core/services/storage/secure_storage_service.dart';

class DocumentsDataSource {
  String get baseUrl {
    const bool isAndroid = bool.fromEnvironment('dart.vm.android');

    return isAndroid ? 'http://10.0.2.2:8080' : 'http://localhost:8080';
  }
  
  final IGenericHttp _http;
  final SecureStorageService _secureStorage;
  final AuthService _authService;
  
  DocumentsDataSource(this._http, this._secureStorage, this._authService);

  
  Future<String> _getPacienteId() async {
    try {
   
      final userId = await _secureStorage.getUserId();
      if (userId != null && userId.isNotEmpty) {
        return userId;
      }
      
  
      final userInfo = await _authService.getUserInfo();
      return userInfo?['id'] ?? '';
    } catch (e) {
      print('Erro ao obter ID do paciente: $e');
      return '';
    }
  }

  Future<HttpResponse> getDocuments() async {
    try {
      final pacienteId = await _getPacienteId();
      if (pacienteId.isEmpty) {
        throw Exception('ID do paciente não encontrado');
      }
      
      final endpoint = '$baseUrl/documentos/$pacienteId';
      print('Attempting to fetch documents from $endpoint');
      
      final response = await _http.get(endpoint);
      print('Received response with status code: ${response.statusCode}\n');
      print("[DocumentsDataSource] Response body: ${response.body}\n");
      
      if (response.statusCode != 200) {
        print('Failed to fetch documents: ${response.statusCode}');
        final errorMessage = response.body['mensagem'] ?? 'Falha ao obter documentos';
        throw Exception(errorMessage);
      }
      
   
      final responseData = response.body;
      if (responseData == null || !responseData.containsKey('dado')) {
        throw Exception('Formato de resposta inválido');
      }
      
  
      final adaptedResponse = HttpResponse(
        statusCode: response.statusCode,
        body: responseData['dado'],
      );
      
      print('Successfully fetched documents');
      return adaptedResponse;
    } catch (e) {
      print('Error connecting to server: $e');
      throw Exception('Erro ao conectar com o servidor: $e');
    }
  }

  Future<HttpResponse> uploadDocument(String filePath, Map<String, dynamic> metadata) async {
    try {
      final pacienteId = await _getPacienteId();
      if (pacienteId.isEmpty) {
        throw Exception('ID do paciente não encontrado');
      }
      

      final solicitacaoDocumentoDto = {
        'idPaciente': pacienteId,
        'titulo': metadata['title'] ?? '',
        'descricao': metadata['description'] ?? '',
        'tipo': metadata['type'] ?? 'OUTRO',
        'urlArquivo': filePath, 
      };
      
      final response = await _http.post(
        '$baseUrl/solicitacoes-documentos',
        solicitacaoDocumentoDto,
      );
      
      if (response.statusCode != 201 && response.statusCode != 200) {
        final errorMessage = response.body['mensagem'] ?? 'Falha ao enviar documento';
        throw Exception(errorMessage);
      }
      

      final responseData = response.body;
      if (responseData == null || !responseData.containsKey('dado')) {
        throw Exception('Formato de resposta inválido');
      }
      
      final adaptedResponse = HttpResponse(
        statusCode: response.statusCode,
        body: responseData['dado'],
      );
      
      return adaptedResponse;
    } catch (e) {
      throw Exception('Erro ao conectar com o servidor: $e');
    }
  }

  Future<HttpResponse> updateDocument(String documentId, Map<String, dynamic> data) async {
    try {
      final pacienteId = await _getPacienteId();
      if (pacienteId.isEmpty) {
        throw Exception('ID do paciente não encontrado');
      }
      
  
      final solicitacaoDocumentoDto = {
        'id': documentId,
        'idPaciente': pacienteId,
        'titulo': data['title'] ?? '',
        'descricao': data['description'] ?? '',
        'tipo': data['type'] ?? 'OUTRO',
        'urlArquivo': data['fileUrl'] ?? '',
      };
      
      final response = await _http.put(
        '$baseUrl/solicitacoes-documentos/$documentId',
        solicitacaoDocumentoDto,
      );
      
      if (response.statusCode != 200) {
        final errorMessage = response.body['mensagem'] ?? 'Falha ao atualizar documento';
        throw Exception(errorMessage);
      }
      
     
      final responseData = response.body;
      if (responseData == null || !responseData.containsKey('dado')) {
        throw Exception('Formato de resposta inválido');
      }
      
    
      final adaptedResponse = HttpResponse(
        statusCode: response.statusCode,
        body: responseData['dado'],
      );
      
      return adaptedResponse;
    } catch (e) {
      throw Exception('Erro ao conectar com o servidor: $e');
    }
  }

  Future<HttpResponse> deleteDocument(String documentId) async {
    try {
      final pacienteId = await _getPacienteId();
      if (pacienteId.isEmpty) {
        throw Exception('ID do paciente não encontrado');
      }
      
      final response = await _http.delete('$baseUrl/solicitacoes-documentos/$documentId');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode != 204 && response.statusCode != 200) {
        final errorMessage = response.body != null && response.body is Map ? 
            response.body['mensagem'] ?? 'Falha ao deletar documento' : 
            'Falha ao deletar documento';
        throw Exception(errorMessage);
      }
      

      final adaptedResponse = HttpResponse(
        statusCode: 204, 
        body: {},
      );
      
      return adaptedResponse;
    } catch (e) {
      print('Error connecting to server: $e');
      throw Exception('Erro ao conectar com o servidor: $e');
    }
  }

  Future<HttpResponse> toggleFavorite(String documentId) async {
    try {
      final pacienteId = await _getPacienteId();
      if (pacienteId.isEmpty) {
        throw Exception('ID do paciente não encontrado');
      }
      
 
      final response = await _http.put(
        '$baseUrl/solicitacoes-documentos/$documentId/favorito',
        {},
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode != 200) {
        final errorMessage = response.body != null && response.body is Map ? 
            response.body['mensagem'] ?? 'Falha ao atualizar favorito' : 
            'Falha ao atualizar favorito';
        throw Exception(errorMessage);
      }
      

      final responseData = response.body;
      if (responseData == null || !responseData.containsKey('dado')) {
        throw Exception('Formato de resposta inválido');
      }
      

      final adaptedResponse = HttpResponse(
        statusCode: response.statusCode,
        body: responseData['dado'],
      );
      
      return adaptedResponse;
    } catch (e) {
      print('Error connecting to server: $e');
      throw Exception('Erro ao conectar com o servidor: $e');
    }
  }
}