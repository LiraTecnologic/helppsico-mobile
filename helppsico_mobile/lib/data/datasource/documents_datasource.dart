
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';
import 'package:helppsico_mobile/core/services/auth/auth_service.dart';
import 'package:helppsico_mobile/core/services/storage/secure_storage_service.dart';

class DocumentsDataSource {
  String get baseUrl {
    
    return 'http://10.0.2.2:8080'; 
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
      final patientId = userInfo?['id'] as String?;
      if (patientId != null && patientId.isNotEmpty) {
        await _secureStorage.saveUserId(patientId);
        return patientId;
      }
      throw Exception('ID do paciente não encontrado no SecureStorage nem via AuthService.');
    } catch (e) {
      print('DocumentsDataSource._getPacienteId(): Erro ao obter ID do paciente: $e');
      throw Exception('Erro ao obter ID do paciente: $e');
    }
  }

  Future<HttpResponse> getDocuments() async {
    try {
     
      final endpoint = 'http://10.0.2.2:8080/documentos/57d106c1-2d28-4dbc-a295-da993de10704';
      print('DocumentsDataSource.getDocuments(): Tentando buscar documentos de $endpoint');

      final response = await _http.get(endpoint);
      print('DocumentsDataSource.getDocuments(): Recebida resposta com status: ${response.statusCode}');

      if (response.statusCode != 200) {
        print('DocumentsDataSource.getDocuments(): Falha ao buscar documentos: ${response.statusCode}');
        final errorMessage = (response.body is Map && response.body.containsKey('mensagem')) 
                           ? response.body['mensagem'] 
                           : 'Falha ao obter documentos do servidor.';
        throw Exception(errorMessage);
      }

    
      return HttpResponse(
        statusCode: response.statusCode,
        body: response.body, 
      );

    } catch (e) {
      print('DocumentsDataSource.getDocuments(): Erro ao conectar com o servidor: $e');
      throw Exception('Erro ao conectar com o servidor: $e');
    }
  }

  
  Future<HttpResponse> uploadDocument(String filePath, Map<String, dynamic> metadata) async {
    try {
      final pacienteId = await _getPacienteId();
      
     
      final solicitacaoDocumentoDto = {
        'idPaciente': pacienteId,
        'titulo': metadata['title'] ?? '', 
        'descricao': metadata['description'] ?? '',
        'tipo': metadata['type'] ?? 'OUTRO', 
        'urlArquivo': filePath, 

      };
      
  
      final endpoint = '$baseUrl/solicitacoes-documentos'; 
      print('DocumentsDataSource.uploadDocument(): Enviando para $endpoint');

      final response = await _http.post(endpoint, solicitacaoDocumentoDto);
      
      if (response.statusCode != 201 && response.statusCode != 200) { 
        final errorMessage = (response.body is Map && response.body.containsKey('mensagem'))
                           ? response.body['mensagem']
                           : 'Falha ao enviar documento.';
        throw Exception(errorMessage);
      }
      
      final responseData = response.body as Map<String, dynamic>; 
      if (!responseData.containsKey('dado') || responseData['dado'] == null) {
        throw Exception('Formato de resposta inválido após upload.');
      }
      
      return HttpResponse(
        statusCode: response.statusCode,
        body: responseData['dado'], 
      );
    } catch (e) {
      print('DocumentsDataSource.uploadDocument(): Erro: $e');
      throw Exception('Erro ao fazer upload do documento: $e');
    }
  }

  Future<HttpResponse> deleteDocument(String documentId) async {
    try {
     
      final endpoint = '$baseUrl/documentos/$documentId'; 
      print('DocumentsDataSource.deleteDocument(): Deletando $endpoint');

      final response = await _http.delete(endpoint);
      
    
      if (response.statusCode != 204 && response.statusCode != 200) {
         final errorMessage = (response.body is Map && response.body.containsKey('mensagem'))
                           ? response.body['mensagem']
                           : 'Falha ao deletar documento.';
        throw Exception(errorMessage);
      }
      
      return HttpResponse(
        statusCode: response.statusCode, 
        body: response.body ?? {}, 
      );
    } catch (e) {
      print('DocumentsDataSource.deleteDocument(): Erro: $e');
      throw Exception('Erro ao deletar documento: $e');
    }
  }

}