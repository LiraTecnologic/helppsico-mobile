
import 'package:helppsico_mobile/data/datasource/notification_data_source.dart';
import 'package:helppsico_mobile/domain/entities/notification_entity.dart';


class NotificationRepository {
  final NotificationDataSource _notificationDataSource;
  NotificationRepository(this._notificationDataSource);

  Future<List<NotificationEntity>> getNotifications() async {
    final response = await _notificationDataSource.getNotifications();
   
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = response.body;
      final List<NotificationEntity> notifications = jsonList
          .map((json) => NotificationEntity.fromJson(json as Map<String, dynamic>))
          .toList();
      
      return notifications;
    } else {
      throw Exception('Failed to load notifications');
    }
  }
}