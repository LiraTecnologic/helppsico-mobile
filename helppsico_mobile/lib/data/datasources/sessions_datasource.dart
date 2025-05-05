import 'dart:convert';
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';

class SessionsDataSource {
  final String baseUrl = 'http://localhost:3000';
  final IGenericHttp _http;

  SessionsDataSource(this._http);

  Future<HttpResponse> getSessions() async {
    final response = await _http.get('$baseUrl/sessions');
    return response;
  }

  Future<HttpResponse> getNextSession() async {
    final response = await _http.get('$baseUrl/sessions');
    if (response.statusCode == 200) {
      final List<dynamic> sessions = response.body;
      if (sessions.isEmpty) {
        return HttpResponse(statusCode: 200, body: [], headers: {});
      }
      
      final now = DateTime.now();
      final nextSession = sessions.firstWhere(
        (session) => DateTime.parse(session['data']).isAfter(now),
        orElse: () => null,
      );
      
      return HttpResponse(
        statusCode: 200,
        body: nextSession ?? {},
        headers: {},
      );
    }
    return response;
  }
}