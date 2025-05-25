import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';
import 'package:helppsico_mobile/core/services/storage/secure_storage_service.dart';

abstract class ISessionsDataSource {
  String get baseUrl;
  Future<HttpResponse> getSessions();
  Future<HttpResponse> getNextSession();
}

class SessionsDataSource implements ISessionsDataSource {
  final IGenericHttp _http;
  
  SessionsDataSource(this._http);

  @override
  String get baseUrl {
    const bool isAndroid = bool.fromEnvironment('dart.vm.android');
    final host = isAndroid ? 'http://10.0.2.2:7000' : 'http://localhost:7000';
    return '$host/sessions';
  }

  @override
  Future<HttpResponse> getSessions() async {
    final token = await SecureStorageService().getToken();
    print('Attempting to fetch sessions from $baseUrl');
    return _http.get(
      baseUrl,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }

  @override
  Future<HttpResponse> getNextSession() async {
    final token = await SecureStorageService().getToken();
    print('Attempting to fetch next session from $baseUrl/next');
    return _http.get(
      '$baseUrl/next',
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }
}