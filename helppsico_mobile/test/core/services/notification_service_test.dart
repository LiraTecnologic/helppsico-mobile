import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:helppsico_mobile/core/services/notification/notification_service.dart';
import 'package:helppsico_mobile/core/services/storage/secure_storage_service.dart';
import 'package:helppsico_mobile/domain/entities/notification_entity.dart';
import 'package:helppsico_mobile/presentation/viewmodels/cubit/notifications_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationsCubit extends Mock implements NotificationsCubit {}

void main() {
  group('NotificationService Tests', () {
    late NotificationService notificationService;
    late MockNotificationsCubit mockNotificationsCubit;
    
    setUp(() {
      mockNotificationsCubit = MockNotificationsCubit();
      // Registrar o mock no GetIt
      GetIt.instance.registerSingleton<NotificationsCubit>(mockNotificationsCubit);
      notificationService = NotificationService();
    });
    
    test('should create instance with dependencies', () {
      expect(notificationService, isNotNull);
      expect(notificationService, isA<NotificationService>());
    });

    group('saveNotification', () {
      test('should save notification successfully', () async {
        final now = DateTime.now();
        when(() => mockNotificationsCubit.addNotification(any()))
            .thenAnswer((_) async {});

        await notificationService.saveNotification(
          id: 1,
          title: 'Test Notification',
          body: 'Test Body',
          scheduledDate: now,
          payload: 'test_payload',
        );

        verify(() => mockNotificationsCubit.addNotification(any())).called(1);
      });
    });

      
    group('clearNotifications', () {
      test('should clear all notifications', () async {
        // Arrange
        await notificationService.saveNotification(
          id: 1,
          title: 'Test 1',
          body: 'Body 1',
          scheduledDate: DateTime.now(),
          payload: 'payload1',
        );
        await notificationService.saveNotification(
          id: 2,
          title: 'Test 2',
          body: 'Body 2',
          scheduledDate: DateTime.now(),
          payload: 'payload2',
        );
        
        // Act
        await notificationService.clearAllNotifications();
        
        // Assert
        expect(notificationService.notificationsCubit.getNotificationsCount(), isEmpty);
      });
        test('testShouldThrowExceptionWhenTokenIsNull', () async {
  // Arrange
  const notificationId = '123';
  // Don't save token
  
  // Act & Assert
  expect(
    () async => await notificationService.clearAllNotifications(),
    throwsA(isA<Exception>().having(
      (e) => e.toString(),
      'message',
      contains('Token de autenticação não encontrado'),
    )),
  );
});
      
      test('should handle HTTP request exception', () async {

        const notificationId = '123';
        var mockStorage = await SecureStorageService.create();
       
        notificationService = NotificationService();;
        String token = '123456';
        await mockStorage.saveToken(token);
        
        // Don't set any response, will trigger default 404
        
        // Act
        final result = await notificationService.clearAllNotifications();
        
        // Assert
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Erro ao limpar notificações'),
        ));
      });

     
  

    });

    
  });
}

      

