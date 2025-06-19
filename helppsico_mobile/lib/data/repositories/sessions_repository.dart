
import 'package:helppsico_mobile/data/datasource/sessions_data_source.dart';
import '../../domain/entities/session_model.dart';

class SessionRepository {
  final SessionsDataSource _sessionsDataSource;
  SessionRepository(this._sessionsDataSource);

  Future<List<SessionModel>> getSessions() async {
    try {
      final response = await _sessionsDataSource.getSessions();

      if (response.statusCode == 200) {
        final responseData = response.body['dado'];

        if (responseData == null) {
          return [];
        }

        final consultasPage = responseData;
        final List<dynamic> consultas = consultasPage['content'] ?? [];

        final List<SessionModel> sessions = consultas.map((json) {
          final adaptedJson = _adaptConsultaToSessionModel(json);
          return SessionModel.fromJson(adaptedJson);
        }).toList();

        return sessions;
      } else {
        final errorMessage = response.body['mensagem'] ?? 'Falha ao carregar sessões';
        throw Exception(errorMessage);
      }
    } catch (e) {
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
    try {
      final response = await _sessionsDataSource.getNextSession();

      if (response.statusCode == 200) {
        final dynamic jsonData = response.body;

        if (jsonData is Map<String, dynamic> && jsonData.isNotEmpty) {
          final adaptedJson = _adaptConsultaToSessionModel(jsonData);
          return SessionModel.fromJson(adaptedJson);
        }

        return null;
      } else {
        final errorMessage = response.body['mensagem'] ?? 'Falha ao carregar próxima sessão';
        throw Exception(errorMessage);
      }
    } catch (e) {
      rethrow;
    }
  }
}

