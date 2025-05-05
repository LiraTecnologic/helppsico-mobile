import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';

abstract class ISessionsDataSource {
  Future<HttpResponse> getSessions();
}

class SessionsDataSource implements ISessionsDataSource {
  final IGenericHttp _http;
  final String baseUrl = 'http://localhost:3000/sessions';

  SessionsDataSource(this._http);

  Future<HttpResponse> getSessions() async {
    try {
      final response = await _http.get(baseUrl);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}