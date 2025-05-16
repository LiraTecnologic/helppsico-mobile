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
    // Use a singleton instance of NotificationsCubit
    _notificationsCubit = GetIt.instance.isRegistered<NotificationsCubit>() 
        ? GetIt.instance<NotificationsCubit>() 
        : NotificationsCubit();
    
    if (!GetIt.instance.isRegistered<NotificationsCubit>()) {
      GetIt.instance.registerSingleton<NotificationsCubit>(_notificationsCubit);
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
    final notification = NotificationEntity(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      payload: payload,
    );

    await _notificationsCubit.addNotification(notification);
  }

  void onNotificationReceived(NotificationResponse response) {
    // Aqui podemos adicionar lógica para quando uma notificação é tocada
    print('Notificação tocada: ${response.payload}');
  }

  Future<void> clearAllNotifications() async {
    await _notificationsCubit.clearNotifications();
  }
}