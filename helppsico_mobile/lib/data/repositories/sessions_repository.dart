
import 'package:helppsico_mobile/data/datasource/sessions_data_source.dart';

import '../../domain/entities/session_model.dart';

class SessionRepository {
  final SessionsDataSource _sessionsDataSource;
  SessionRepository(this._sessionsDataSource);

  Future<List<SessionModel>> getSessions() async {
    final response = await _sessionsDataSource.getSessions();
    
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = response.body;
      final List<SessionModel> sessions = jsonList.map((json) => SessionModel.fromJson(json as Map<String, dynamic>)).toList();
      
      return sessions;
    } else {
      throw Exception('Falha ao carregar sessões');
    }
  }

  Future<SessionModel?> getNextSession() async {
    final response = await _sessionsDataSource.getNextSession();
    
    if (response.statusCode == 200) {
      final dynamic jsonData = response.body;
      if (jsonData is Map<String, dynamic> && jsonData.isNotEmpty) {
        return SessionModel.fromJson(jsonData);
      }
      return null;
    } else {
      throw Exception('Falha ao carregar próxima sessão');
    }
  }
}