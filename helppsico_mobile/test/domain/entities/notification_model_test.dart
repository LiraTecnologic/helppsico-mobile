import 'package:flutter_test/flutter_test.dart';
import 'package:helppsico_mobile/domain/entities/notification_model.dart';

void main() {
  final tDateTime = DateTime.now();
  final tNotificationModel = NotificationModel(
    id: 'notif123',
    title: 'Nova Sessão Agendada',
    message: 'Sua sessão com Dr. Exemplo foi agendada para 20/07/2024.',
    createdAt: tDateTime,
    isRead: false,
    type: 'session_reminder',
    actionText: 'Ver Detalhes',
  );

  final tNotificationJson = {
    'id': 'notif123',
    'title': 'Nova Sessão Agendada',
    'message': 'Sua sessão com Dr. Exemplo foi agendada para 20/07/2024.',
    'createdAt': tDateTime.toIso8601String(),
    'isRead': false,
    'type': 'session_reminder',
    'actionText': 'Ver Detalhes',
  };

  group('NotificationModel', () {
    test('should create a NotificationModel from json', () {
      // Act
      final result = NotificationModel.fromJson(tNotificationJson);
      // Assert
      expect(result, isA<NotificationModel>());
      expect(result.id, tNotificationModel.id);
      expect(result.title, tNotificationModel.title);
      expect(result.message, tNotificationModel.message);
      expect(result.createdAt.toIso8601String(), tNotificationModel.createdAt.toIso8601String());
      expect(result.isRead, tNotificationModel.isRead);
      expect(result.type, tNotificationModel.type);
      expect(result.actionText, tNotificationModel.actionText);
    });

    test('should convert NotificationModel to json', () {
      // Act
      final result = tNotificationModel.toJson();
      // Assert
      expect(result, tNotificationJson);
    });

    group('copyWith', () {
      test('should return a new NotificationModel with updated values', () {
        // Arrange
        final updatedTitle = 'Sessão Atualizada';
        final updatedIsRead = true;

        // Act
        final copiedModel = tNotificationModel.copyWith(
          title: updatedTitle,
          isRead: updatedIsRead,
        );

        // Assert
        expect(copiedModel.id, tNotificationModel.id); // Unchanged
        expect(copiedModel.title, updatedTitle); // Changed
        expect(copiedModel.message, tNotificationModel.message); // Unchanged
        expect(copiedModel.createdAt, tNotificationModel.createdAt); // Unchanged
        expect(copiedModel.isRead, updatedIsRead); // Changed
        expect(copiedModel.type, tNotificationModel.type); // Unchanged
        expect(copiedModel.actionText, tNotificationModel.actionText); // Unchanged
      });

      test('should return an identical NotificationModel if no parameters are provided', () {
        // Act
        final copiedModel = tNotificationModel.copyWith();
        // Assert
        expect(copiedModel.id, tNotificationModel.id);
        expect(copiedModel.title, tNotificationModel.title);
        expect(copiedModel.message, tNotificationModel.message);
        expect(copiedModel.createdAt.toIso8601String(), tNotificationModel.createdAt.toIso8601String());
        expect(copiedModel.isRead, tNotificationModel.isRead);
        expect(copiedModel.type, tNotificationModel.type);
        expect(copiedModel.actionText, tNotificationModel.actionText);
        // For a more robust check, especially if not using Equatable:
        expect(copiedModel.toJson(), tNotificationModel.toJson());
      });
    });
  });
}