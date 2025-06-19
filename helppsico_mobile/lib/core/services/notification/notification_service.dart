import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:helppsico_mobile/domain/entities/notification_entity.dart';
import 'package:helppsico_mobile/presentation/viewmodels/cubit/notifications_cubit.dart';
import 'package:get_it/get_it.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  late final NotificationsCubit _notificationsCubit;

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal() {
    _notificationsCubit = _initNotificationsCubit();
  }

  NotificationsCubit _initNotificationsCubit() {
    if (GetIt.instance.isRegistered<NotificationsCubit>()) {
      return GetIt.instance<NotificationsCubit>();
    } else {
      final cubit = NotificationsCubit();
      GetIt.instance.registerSingleton<NotificationsCubit>(cubit);
      return cubit;
    }
  }

  NotificationsCubit get notificationsCubit => _notificationsCubit;

  void init() {
    _notificationsCubit.loadNotifications();
  }

  Future<void> saveNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String payload,
  }) async {
    final notification = _createNotificationEntity(id, title, body, scheduledDate, payload);
    await _notificationsCubit.addNotification(notification);
  }

  NotificationEntity _createNotificationEntity(
    int id,
    String title,
    String body,
    DateTime scheduledDate,
    String payload,
  ) {
    return NotificationEntity(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      payload: payload,
    );
  }

  void onNotificationReceived(NotificationResponse response) {
    print('Notificação tocada: ${response.payload}');
  }

  Future<void> clearAllNotifications() async {
    await _notificationsCubit.clearNotifications();
  }
}
