import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';
import 'package:helppsico_mobile/core/services/storage/secure_storage_service.dart';

String baseUrl = "https://api-mobile-render.onrender.com/sessions";

abstract class ISessionsDataSource {
  Future<HttpResponse> getSessions();
}

class SessionsDataSource implements ISessionsDataSource {
  

  
  
  final IGenericHttp _http;
  SessionsDataSource(
    this._http, 
  );

  @override
  Future<HttpResponse> getSessions() async {
    final token = await SecureStorageService().getToken();
    return _http.get(
      baseUrl,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
  }
}