import 'package:helppsico_mobile/data/datasource/sessionsDataSource.dart';
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
      throw Exception('Failed to load sessions');
    }
  }
}