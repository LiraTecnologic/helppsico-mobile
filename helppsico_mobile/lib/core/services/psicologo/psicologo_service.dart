
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';
import 'package:helppsico_mobile/core/services/storage/secure_storage_service.dart';

class PsicologoService {
  final IGenericHttp _http;
  final SecureStorageService _storage;

  PsicologoService(this._http, this._storage);

 Future<Map<String, String>?> getPsicologoByPacienteId(String pacienteId) async {
    
    final token = await _storage.getToken();
  
     
    
    if (token == null) {
      
      return null;
    }

    final response = await _http.get(
      'http://localhost:8080/vinculos/listar/paciente/$pacienteId',
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      return null;
    }

    
    final data = response.body as Map<String, dynamic>;
    final content = (data['dado']['content'] as List).cast<Map<String, dynamic>>();

    if (content.isEmpty) {
    
      return null;
    }

    final psicologoData = content.first['psicologo'] as Map<String, dynamic>;
    return {
      'id': psicologoData['id']?.toString() ?? '',
      'nome': psicologoData['nome']?.toString() ?? '',
      'crp': psicologoData['crp']?.toString()?? '',
    };
  }

}