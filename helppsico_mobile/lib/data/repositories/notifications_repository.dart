
import 'package:helppsico_mobile/data/datasource/notificationDataSource.dart';
import '../../domain/entities/notification_model.dart';

class NotificationRepository {
  final NotificationDataSource _notificationDataSource;
  NotificationRepository(this._notificationDataSource);

  Future<List<NotificationModel>> getNotifications() async {
    final response = await _notificationDataSource.getNotifications();
   
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = response.body;
      final List<NotificationModel> notifications = jsonList
          .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
          .toList();
      
      return notifications;
    } else {
      throw Exception('Failed to load notifications');
    }
  }
}