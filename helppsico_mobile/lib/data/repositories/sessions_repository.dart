
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
    try {
      final response = await _sessionsDataSource.getNextSession();
      print('Response received: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final dynamic jsonData = response.body;
        print('JSON data: $jsonData');
        
        if (jsonData is Map<String, dynamic> && jsonData.isNotEmpty) {
          return SessionModel.fromJson(jsonData);
        }
        print('No session data found');
        return null;
      } else {
        print('Failed to load next session: ${response.statusCode}');
        throw Exception('Falha ao carregar próxima sessão');
      }
    } catch (e) {
      print('Error encountered: $e');
      rethrow;
    }
  }
  }
