import '../mock_notifications.dart';
import '../../domain/entities/notification_entity.dart';

abstract class NotificationDatasource {
  Future<List<NotificationEntity>> getNotifications();
}

class NotificationDatasourceImpl implements NotificationDatasource {
  @override
  Future<List<NotificationEntity>> getNotifications() async {
    // Simulando um delay de rede
    await Future.delayed(const Duration(milliseconds: 800));
    
    return mockNotifications.map((json) => NotificationEntity.fromJson(json)).toList();
  }
}