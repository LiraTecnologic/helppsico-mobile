import 'package:flutter_test/flutter_test.dart';
import 'package:helppsico_mobile/domain/entities/notification_entity.dart';

void main() {
  final tDateTime = DateTime.now();
  final tNotificationEntity = NotificationEntity(
    id: 1,
    title: 'Test Notification',
    body: 'This is a test notification body.',
    scheduledDate: tDateTime,
    payload: 'test_payload',
  );

  final tNotificationJson = {
    'id': 1,
    'title': 'Test Notification',
    'body': 'This is a test notification body.',
    'scheduledDate': tDateTime.toIso8601String(),
    'payload': 'test_payload',
  };

  group('NotificationEntity', () {
    test('should create a NotificationEntity from json', () {
     
      final result = NotificationEntity.fromJson(tNotificationJson);

      expect(result, isA<NotificationEntity>());
      expect(result.id, tNotificationEntity.id);
      expect(result.title, tNotificationEntity.title);
      expect(result.body, tNotificationEntity.body);
     
      expect(result.scheduledDate.toIso8601String(), tNotificationEntity.scheduledDate.toIso8601String());
      expect(result.payload, tNotificationEntity.payload);
    });

    test('should convert NotificationEntity to json', () {
     
      final result = tNotificationEntity.toJson();

      expect(result, tNotificationJson);
    });

    test('props should include all fields for equatable', () {
     
      final sameNotificationEntity = NotificationEntity(
        id: 1,
        title: 'Test Notification',
        body: 'This is a test notification body.',
        scheduledDate: tDateTime,
        payload: 'test_payload',
      );
      expect(tNotificationEntity, sameNotificationEntity);

      final differentNotificationEntity = NotificationEntity(
        id: 2, // Diferente
        title: 'Test Notification',
        body: 'This is a test notification body.',
        scheduledDate: tDateTime,
        payload: 'test_payload',
      );
      expect(tNotificationEntity == differentNotificationEntity, isFalse);
    });
  });
}