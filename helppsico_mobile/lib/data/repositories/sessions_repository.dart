
import 'package:helppsico_mobile/data/datasource/sessions_data_source.dart';
import '../../domain/entities/session_model.dart';

class SessionRepository {
  final SessionsDataSource _sessionsDataSource;
  SessionRepository(this._sessionsDataSource);

  Future<List<SessionModel>> getSessions() async {
    try {
      final response = await _sessionsDataSource.getSessions();
      
      if (response.statusCode == 200) {
        // A API Java encapsula as respostas em um objeto ResponseDto<T> com o dado principal no campo 'dado'
        final responseData = response.body['dado'];
        
        if (responseData == null) {
          return [];
        }
        
        // A API retorna uma página de consultas
        final consultasPage = responseData;
        final List<dynamic> consultas = consultasPage['content'] ?? [];
        
        // Converte cada consulta para o modelo SessionModel
        final List<SessionModel> sessions = consultas.map((json) {
          // Adapta o formato da API Java para o formato esperado pelo app
          final adaptedJson = _adaptConsultaToSessionModel(json);
          return SessionModel.fromJson(adaptedJson);
        }).toList();
        
        return sessions;
      } else {
        final errorMessage = response.body['mensagem'] ?? 'Falha ao carregar sessões';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Erro ao buscar sessões: $e');
      throw Exception('Falha ao carregar sessões: $e');
    }
  }
  
  /// Adapta o formato da ConsultaDto da API Java para o formato esperado pelo SessionModel
  Map<String, dynamic> _adaptConsultaToSessionModel(Map<String, dynamic> consultaDto) {
    return {
      'id': consultaDto['id']?.toString() ?? '',
      'psicologoName': consultaDto['nomePsicologo'] ?? '',
      'pacienteId': consultaDto['idPaciente']?.toString() ?? '',
      'data': consultaDto['dataHora'] ?? DateTime.now().toIso8601String(),
      'valor': consultaDto['valor']?.toString() ?? '',
      'endereco': consultaDto['endereco'] ?? '',
      'finalizada': consultaDto['finalizada'] ?? false,
    };
  }

  Future<SessionModel?> getNextSession() async {
    try {
      final response = await _sessionsDataSource.getNextSession();
      print('Response received: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final dynamic jsonData = response.body;
        print('JSON data: $jsonData');
        
        if (jsonData is Map<String, dynamic> && jsonData.isNotEmpty) {
          // Adapta o formato da API Java para o formato esperado pelo app
          final adaptedJson = _adaptConsultaToSessionModel(jsonData);
          return SessionModel.fromJson(adaptedJson);
        }
        print('No session data found');
        return null;
      } else {
        final errorMessage = response.body['mensagem'] ?? 'Falha ao carregar próxima sessão';
        print('Failed to load next session: ${response.statusCode} - $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Error encountered: $e');
      rethrow;
    }
  }
  }
