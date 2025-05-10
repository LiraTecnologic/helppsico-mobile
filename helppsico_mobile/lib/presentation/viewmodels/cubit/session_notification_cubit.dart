import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:helppsico_mobile/domain/entities/session_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

abstract class SessionNotificationState {}

class SessionNotificationInitial extends SessionNotificationState {}

class SessionNotificationLoading extends SessionNotificationState {}

class SessionNotificationSuccess extends SessionNotificationState {}

class SessionNotificationError extends SessionNotificationState {
  final String message;
  SessionNotificationError(this.message);
}

class SessionNotificationCubit extends Cubit<SessionNotificationState> {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  
  static const int _defaultSessionDuration = 50;
  
  SessionNotificationCubit() : super(SessionNotificationInitial());
  
  Future<void> init() async {
    emit(SessionNotificationLoading());
    try {
      tz_data.initializeTimeZones();
      const AndroidInitializationSettings androidSettings = 
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings = 
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
            defaultPresentAlert: true,
            defaultPresentBadge: true,
            defaultPresentSound: true,
          );
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      await _requestPermissions();
      await _createNotificationChannel();
      emit(SessionNotificationSuccess());
    } catch (e) {
      emit(SessionNotificationError('Erro ao inicializar notificações: $e'));
    }
  }
  
  Future<void> _requestPermissions() async {
    await _notificationsPlugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
  
  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'sessoes',
      'Sessões',
      description: 'Notificações de sessões agendadas',
      importance: Importance.high,
    );
    
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
  
  void _onNotificationTapped(NotificationResponse response) {
    print('Notificação tocada: ${response.payload}');
  }
  
  Future<void> scheduleSessionNotifications(SessionModel session) async {
    if (session.finalizada) return;
    
    try {
      final bool enabled = await isSessionNotificationEnabled(session.id);
      if (!enabled) return;
      
      final int sessionDurationMinutes = _calculateSessionDuration(session.valor);
      
      await _scheduleNotification(
        id: int.parse(session.id) * 3 - 2,
        title: session.psicologoName,
        body: 'Faltam 5 minutos para sua sessão',
        scheduledDate: session.data.subtract(const Duration(minutes: 5)),
        payload: session.id,
      );
      
      await _scheduleNotification(
        id: int.parse(session.id) * 3 - 1,
        title: session.psicologoName,
        body: 'Sua sessão começou',
        scheduledDate: session.data,
        payload: session.id,
      );
      
      await _scheduleNotification(
        id: int.parse(session.id) * 3,
        title: session.psicologoName,
        body: 'Sua sessão terminou',
        scheduledDate: session.data.add(Duration(minutes: sessionDurationMinutes)),
        payload: session.id,
      );
      
    } catch (e) {
      emit(SessionNotificationError('Erro ao agendar notificações: $e'));
    }
  }
  
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String payload,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) return;
    
    final NotificationDetails details = NotificationDetails(
      android:  AndroidNotificationDetails(
        'sessoes',
        'Sessões',
        channelDescription: 'Notificações de sessões agendadas',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        categoryIdentifier: 'sessoes',
      ),
    );
    
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      details,
      androidScheduleMode:AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }
  

  Future<void> cancelSessionNotifications(String sessionId) async {
    try {
      final int baseId = int.parse(sessionId) * 3;
      await _notificationsPlugin.cancel(baseId - 2); 
      await _notificationsPlugin.cancel(baseId - 1); 
      await _notificationsPlugin.cancel(baseId);     
    } catch (e) {
      emit(SessionNotificationError('Erro ao cancelar notificações: $e'));
    }
  }
  
  Future<void> cancelAllNotifications() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      emit(SessionNotificationError('Erro ao cancelar todas as notificações: $e'));
    }
  }
  
 
  Future<void> updateAllSessionsNotifications(List<SessionModel> sessions) async {
    try {
      
      await cancelAllNotifications();
      
      
      for (final session in sessions) {
        if (!session.finalizada) {
          await scheduleSessionNotifications(session);
        }
      }
    } catch (e) {
      emit(SessionNotificationError('Erro ao atualizar notificações: $e'));
    }
  }
  

  Future<void> toggleSessionNotification(String sessionId, bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('session_notification_$sessionId', enabled);
      
      emit(SessionNotificationSuccess());
    } catch (e) {
      emit(SessionNotificationError('Erro ao salvar preferência: $e'));
    }
  }
  
  
  Future<bool> isSessionNotificationEnabled(String sessionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('session_notification_$sessionId') ?? true;
    } catch (e) {
      emit(SessionNotificationError('Erro ao verificar preferência: $e'));
      return true; 
    }
  }
  
  
  int _calculateSessionDuration(String valor) {
    try {

      final double valorDouble = double.parse(valor.replaceAll(',', '.'));
      final int duration = (valorDouble / 3).round();
      
      
      return duration < 30 ? _defaultSessionDuration : duration;
    } catch (e) {
     
      return _defaultSessionDuration;
    }
  }
}
