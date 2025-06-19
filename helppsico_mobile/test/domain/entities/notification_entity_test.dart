import 'package:flutter_test/flutter_test.dart';
import 'package:helppsico_mobile/domain/entities/notification_entity.dart';

void main() {
  group('NotificationEntity Tests', () {
    late Map<String, dynamic> validNotificationJson;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime.parse('2024-01-15T10:00:00.000Z');
      validNotificationJson = {
        'id': 1,
        'title': 'Lembrete de Consulta',
        'body': 'Você tem uma consulta agendada para hoje às 10:00',
        'scheduledDate': '2024-01-15T10:00:00.000Z',
        'payload': 'session_123',
      };
    });

    test('should create NotificationEntity instance with all fields', () {
      final notification = NotificationEntity(
        id: 1,
        title: 'Lembrete de Consulta',
        body: 'Você tem uma consulta agendada para hoje às 10:00',
        scheduledDate: testDate,
        payload: 'session_123',
      );

      expect(notification.id, 1);
      expect(notification.title, 'Lembrete de Consulta');
      expect(notification.body, 'Você tem uma consulta agendada para hoje às 10:00');
      expect(notification.scheduledDate, testDate);
      expect(notification.payload, 'session_123');
    });

    test('should create NotificationEntity from valid JSON', () {
      final notification = NotificationEntity.fromJson(validNotificationJson);

      expect(notification.id, 1);
      expect(notification.title, 'Lembrete de Consulta');
      expect(notification.body, 'Você tem uma consulta agendada para hoje às 10:00');
      expect(notification.scheduledDate, testDate);
      expect(notification.payload, 'session_123');
    });

    test('should convert NotificationEntity to JSON correctly', () {
      final notification = NotificationEntity(
        id: 1,
        title: 'Lembrete de Consulta',
        body: 'Você tem uma consulta agendada para hoje às 10:00',
        scheduledDate: testDate,
        payload: 'session_123',
      );

      final json = notification.toJson();

      expect(json['id'], 1);
      expect(json['title'], 'Lembrete de Consulta');
      expect(json['body'], 'Você tem uma consulta agendada para hoje às 10:00');
      expect(json['scheduledDate'], '2024-01-15T10:00:00.000Z');
      expect(json['payload'], 'session_123');
    });

    test('should handle different date formats in JSON', () {
      final jsonWithDifferentDate = {
        ...validNotificationJson,
        'scheduledDate': '2024-01-15T10:00:00',
      };

      final notification = NotificationEntity.fromJson(jsonWithDifferentDate);
      expect(notification.scheduledDate, DateTime.parse('2024-01-15T10:00:00'));
    });

    test('should maintain equality for same values', () {
      final notification1 = NotificationEntity(
        id: 1,
        title: 'Test',
        body: 'Test body',
        scheduledDate: testDate,
        payload: 'test_payload',
      );

      final notification2 = NotificationEntity(
        id: 1,
        title: 'Test',
        body: 'Test body',
        scheduledDate: testDate,
        payload: 'test_payload',
      );

      expect(notification1.id, notification2.id);
      expect(notification1.title, notification2.title);
      expect(notification1.body, notification2.body);
      expect(notification1.scheduledDate, notification2.scheduledDate);
      expect(notification1.payload, notification2.payload);
    });

    test('should handle empty strings in JSON', () {
      final jsonWithEmptyStrings = {
        'id': 1,
        'title': '',
        'body': '',
        'scheduledDate': '2024-01-15T10:00:00.000Z',
        'payload': '',
      };

      final notification = NotificationEntity.fromJson(jsonWithEmptyStrings);

      expect(notification.id, 1);
      expect(notification.title, '');
      expect(notification.body, '');
      expect(notification.scheduledDate, testDate);
      expect(notification.payload, '');
    });

    test('should convert to JSON and back correctly', () {
      final originalNotification = NotificationEntity(
        id: 1,
        title: 'Lembrete de Consulta',
        body: 'Você tem uma consulta agendada para hoje às 10:00',
        scheduledDate: testDate,
        payload: 'session_123',
      );

      final json = originalNotification.toJson();
      final recreatedNotification = NotificationEntity.fromJson(json);

      expect(recreatedNotification.id, originalNotification.id);
      expect(recreatedNotification.title, originalNotification.title);
      expect(recreatedNotification.body, originalNotification.body);
      expect(recreatedNotification.scheduledDate, originalNotification.scheduledDate);
      expect(recreatedNotification.payload, originalNotification.payload);
    });

    test('should handle negative id values', () {
      final jsonWithNegativeId = {
        ...validNotificationJson,
        'id': -1,
      };

      final notification = NotificationEntity.fromJson(jsonWithNegativeId);
      expect(notification.id, -1);
    });

    test('should handle zero id values', () {
      final jsonWithZeroId = {
        ...validNotificationJson,
        'id': 0,
      };

      final notification = NotificationEntity.fromJson(jsonWithZeroId);
      expect(notification.id, 0);
    });
  });
}