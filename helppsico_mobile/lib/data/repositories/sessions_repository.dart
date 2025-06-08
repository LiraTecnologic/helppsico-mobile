
import 'package:helppsico_mobile/data/datasource/sessions_data_source.dart';
import '../../domain/entities/session_model.dart';


class SessionRepository {
  final SessionsDataSource _sessionsDataSource;
  SessionRepository(this._sessionsDataSource);

  Future<List<SessionModel>> getSessions() async {
    print('Fetching sessions...');
    try {
      final response = await _sessionsDataSource.getSessions();
      print('Response received: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = response.body['dado'];
        print('Response data: $responseData');

        if (responseData == null) {
          print('No data found in response');
          return [];
        }

        final consultasPage = responseData;
        final List<dynamic> consultas = consultasPage['content'] ?? [];
        print('Consultas found: ${consultas.length}');

        final List<SessionModel> sessions = consultas.map((json) {
          final adaptedJson = _adaptConsultaToSessionModel(json);
          return SessionModel.fromJson(adaptedJson);
        }).toList();

        print('Sessions mapped: ${sessions.length}');
        return sessions;
      } else {
        final errorMessage = response.body['mensagem'] ?? 'Falha ao carregar sessões';
        print('Error: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Erro ao buscar sessões: $e');
      throw Exception('Falha ao carregar sessões: $e');
    }
  }

  Map<String, dynamic> _adaptConsultaToSessionModel(Map<String, dynamic> consultaDto) {
    
    return {
      'id': consultaDto['id']?.toString() ?? '',
      'psicologoName': consultaDto['nomePsicologo'] ?? '',
      'pacienteId': consultaDto['idPaciente']?.toString() ?? '',
      'data': (consultaDto['data'] != null && consultaDto['horario']?['inicio'] != null) ? '${consultaDto['data']}T${consultaDto['horario']['inicio']}' : DateTime.now().toIso8601String(),
      'valor': consultaDto['psicologo']?['valorSessao']?.toString() ?? '',
      'endereco': consultaDto['endereco'] ?? '',
      'finalizada': consultaDto['finalizada'] ?? false,
    };
  }

  Future<SessionModel?> getNextSession() async {
    print('Fetching next session...');
    try {
      final response = await _sessionsDataSource.getNextSession();
      print('Response received: ${response.statusCode}');

      if (response.statusCode == 200) {
        final dynamic jsonData = response.body;
        print('JSON data: $jsonData');

        if (jsonData is Map<String, dynamic> && jsonData.isNotEmpty) {
          final adaptedJson = _adaptConsultaToSessionModel(jsonData);
          return SessionModel.fromJson(adaptedJson);
        }
    
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

