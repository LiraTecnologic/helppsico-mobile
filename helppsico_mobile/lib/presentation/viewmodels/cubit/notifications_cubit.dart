import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helppsico_mobile/domain/entities/notification_entity.dart';
import 'package:helppsico_mobile/presentation/viewmodels/state/notifications_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit() : super(NotificationsInitial());

 
  final List<NotificationEntity> _notifications = [];


  Future<void> loadNotifications() async {
    emit(NotificationsLoading());
    try {
    
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getStringList('notifications') ?? [];
      
   
      final notifications = notificationsJson
          .map((json) => NotificationEntity.fromJson(
              Map<String, dynamic>.from(jsonDecode(json))))
          .toList();
      
      
      notifications.sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
      
      _notifications.clear();
      _notifications.addAll(notifications);
      
      emit(NotificationsLoaded(_notifications));
    } catch (e) {
      emit(NotificationsError('Erro ao carregar notificações: $e'));
    }
  }

  
  Future<void> addNotification(NotificationEntity notification) async {
    try {
     
      _notifications.add(notification);
      
      
      await _saveNotifications();
      
     
      emit(NotificationsLoaded(_notifications));
    } catch (e) {
      emit(NotificationsError('Erro ao adicionar notificação: $e'));
    }
  }

 
  Future<void> removeNotification(int id) async {
    try {
      _notifications.removeWhere((notification) => notification.id == id);
      await _saveNotifications();
      emit(NotificationsLoaded(_notifications));
    } catch (e) {
      emit(NotificationsError('Erro ao remover notificação: $e'));
    }
  }

  
  Future<void> clearNotifications() async {
    try {
      _notifications.clear();
      await _saveNotifications();
      emit(NotificationsLoaded(_notifications));
    } catch (e) {
      emit(NotificationsError('Erro ao limpar notificações: $e'));
    }
  }

 
  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = _notifications
        .map((notification) => jsonEncode(notification.toJson()))
        .toList();
    await prefs.setStringList('notifications', notificationsJson);
    print('Notifications saved in SharedPreferences:');
    print(prefs.getStringList('notifications'));
    print("notifications count: ${prefs.getStringList('notifications')?.length}");
  }


  int getNotificationsCount() {
    return _notifications.length;
  }
}