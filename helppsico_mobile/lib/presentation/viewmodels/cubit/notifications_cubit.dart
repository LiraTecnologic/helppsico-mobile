import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helppsico_mobile/domain/entities/notification_entity.dart';
import 'package:helppsico_mobile/presentation/viewmodels/state/notifications_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit() : super(NotificationsInitial());

  // Lista local para armazenar as notificações
  final List<NotificationEntity> _notifications = [];

  // Método para carregar as notificações
  Future<void> loadNotifications() async {
    emit(NotificationsLoading());
    try {
      // Recupera as notificações do SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getStringList('notifications') ?? [];
      
      // Converte as strings JSON para objetos NotificationEntity
      final notifications = notificationsJson
          .map((json) => NotificationEntity.fromJson(
              Map<String, dynamic>.from(jsonDecode(json))))
          .toList();
      
      // Ordena as notificações por data (mais recentes primeiro)
      notifications.sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
      
      _notifications.clear();
      _notifications.addAll(notifications);
      
      emit(NotificationsLoaded(_notifications));
    } catch (e) {
      emit(NotificationsError('Erro ao carregar notificações: $e'));
    }
  }

  // Método para adicionar uma nova notificação
  Future<void> addNotification(NotificationEntity notification) async {
    try {
      // Adiciona à lista local
      _notifications.add(notification);
      
      // Salva no SharedPreferences
      await _saveNotifications();
      
      // Emite o novo estado
      emit(NotificationsLoaded(_notifications));
    } catch (e) {
      emit(NotificationsError('Erro ao adicionar notificação: $e'));
    }
  }

  // Método para remover uma notificação
  Future<void> removeNotification(int id) async {
    try {
      _notifications.removeWhere((notification) => notification.id == id);
      await _saveNotifications();
      emit(NotificationsLoaded(_notifications));
    } catch (e) {
      emit(NotificationsError('Erro ao remover notificação: $e'));
    }
  }

  // Método para limpar todas as notificações
  Future<void> clearNotifications() async {
    try {
      _notifications.clear();
      await _saveNotifications();
      emit(NotificationsLoaded(_notifications));
    } catch (e) {
      emit(NotificationsError('Erro ao limpar notificações: $e'));
    }
  }

  // Método auxiliar para salvar as notificações no SharedPreferences
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

  // Método para obter a quantidade de notificações
  int getNotificationsCount() {
    return _notifications.length;
  }
}