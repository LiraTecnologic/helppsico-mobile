
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';
String baseUrl = "http://localhost:7000/notifications";

abstract class INotificationDataSource {
  Future<HttpResponse> getNotifications();
}

class NotificationDataSource implements INotificationDataSource {

  final IGenericHttp _http;
  NotificationDataSource(this._http);

 @override
  Future<HttpResponse> getNotifications() {
    return _http.get(baseUrl); 
  } 
}
