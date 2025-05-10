import 'dart:convert';
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';

class SessionsDataSource {
  String get baseUrl {
    
    const bool isAndroid = bool.fromEnvironment('dart.vm.android');
    return isAndroid ? 'http://10.0.2.2:7000' : 'http://localhost:7000';
  }
  final IGenericHttp _http;

  SessionsDataSource(this._http);

  Future<HttpResponse> getSessions() async {
    try {
      final response = await _http.get('$baseUrl/sessions');
      if (response.statusCode != 200) {
        throw Exception('Falha ao obter sessões: ${response.statusCode}');
      }
      return response;
    } catch (e) {
      throw Exception('Erro ao conectar com o servidor: $e');
    }
  }

  Future<HttpResponse> getNextSession() async {
    try {
      final response = await _http.get('$baseUrl/sessions');
      if (response.statusCode != 200) {
        throw Exception('Falha ao obter próxima sessão: ${response.statusCode}');
      }

      final List<dynamic> sessions = response.body;
      if (sessions.isEmpty) {
        return HttpResponse(statusCode: 200, body: {}, headers: {});
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
    } catch (e) {
      throw Exception('Erro ao conectar com o servidor: $e');
    }
  }
}