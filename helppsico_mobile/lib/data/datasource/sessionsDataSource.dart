import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';

String baseUrl = "http://192.168.18.40:7000/sessions";

abstract class ISessionsDataSource {
  Future<HttpResponse> getSessions();
}

class SessionsDataSource implements ISessionsDataSource {
  final IGenericHttp _http;
  SessionsDataSource(this._http);

  @override
  Future<HttpResponse> getSessions() {
    return _http.get(baseUrl);
  }
}