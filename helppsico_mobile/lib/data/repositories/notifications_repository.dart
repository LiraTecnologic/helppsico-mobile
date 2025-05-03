import '../../domain/entities/notification_entity.dart';
import '../datasource/notification_datasource.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getNotifications();
}

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationDatasource _datasource;

  NotificationRepositoryImpl(this._datasource);

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    try {
      return await _datasource.getNotifications();
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }
}