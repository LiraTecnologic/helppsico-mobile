import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:helppsico_mobile/core/services/notification/notification_service.dart';
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
    });

    
  });
}

      

test('testShouldThrowExceptionWhenTokenIsNull', () async {
  // Arrange
  const notificationId = '123';
  // Don't save token
  
  // Act & Assert
  expect(
    () async => await notificationService.deleteNotification(notificationId),
    throwsA(isA<Exception>().having(
      (e) => e.toString(),
      'message',
      contains('Token de autenticação não encontrado'),
    )),
  );
});
      
      test('should handle HTTP request exception', () async {

        const notificationId = '123';
        await mockStorage.saveToken(token);
        
        // Don't set any response, will trigger default 404
        
        // Act
        final result = await notificationService.deleteNotification(notificationId);
        
        // Assert
        expect(result, false);
      });

     
  
    
    group('Edge Cases', () {
      test('should handle notification with special characters', () async {

        const userId = '123';
        await mockStorage.saveToken(token);
        await mockStorage.saveUserId(userId);
        
        final notification = NotificationEntity(
          id: '',
          titulo: 'Título com acentos: ção, ã, é',
          corpo: 'Corpo com caracteres especiais: @#\$%^&*()',
          dataAgendada: DateTime.parse('2024-01-20T15:00:00Z'),
          payload: {'message': 'Mensagem com ção'},
        );
        
        final createResponse = HttpResponse(
          statusCode: 201,
          body: {
            'dado': {
              'id': 'special123',
              'titulo': 'Título com acentos: ção, ã, é',
              'corpo': 'Corpo com caracteres especiais: @#\$%^&*()',
              'dataAgendada': '2024-01-20T15:00:00Z',
              'payload': {'message': 'Mensagem com ção'},
            },
          },
          headers: {},
        );
        
        mockHttp.setResponse('http://10.0.2.2:8080/notificacoes', createResponse);
        
        // Act
        final result = await notificationService.createNotification(notification);
        
        // Assert
        expect(result.titulo, 'Título com acentos: ção, ã, é');
        expect(result.corpo, 'Corpo com caracteres especiais: @#\$%^&*()');
        expect(result.payload!['message'], 'Mensagem com ção');
      });
      
      test('Edge cases should handle empty notification ID for deletion', () async {

        await mockStorage.saveToken(token);
        
        // Act
        final result = await notificationService.deleteNotification('');
        
        // Assert
        expect(result, false);
      });
      
      test('should handle very long notification content', () async {

        const userId = '123';
        await mockStorage.saveToken(token);
        await mockStorage.saveUserId(userId);
        
        final longTitle = 'A' * 1000;
        final longBody = 'B' * 5000;
        
        final notification = NotificationEntity(
          id: '',
          titulo: longTitle,
          corpo: longBody,
          dataAgendada: DateTime.now(),
        );
        
        final createResponse = HttpResponse(
          statusCode: 201,
          body: {
            'dado': {
              'id': 'long123',
              'titulo': longTitle,
              'corpo': longBody,
              'dataAgendada': DateTime.now().toIso8601String(),
            },
          },
          headers: {},
        )};
        
        mockHttp.setResponse('http://10.0.2.2:8080/notificacoes', createResponse);
        
        // Act
        final result = await notificationService.createNotification(notification);
        
        // Assert
        expect(result.titulo, longTitle);
        expect(result.corpo, longBody);
      );
    })
    
    
    group('Workflow', () {
      test('should complete full notification workflow', () async {

        const userId = '123';
        await mockStorage.saveToken(token);
        await mockStorage.saveUserId(userId);
        
        // Setup responses for the workflow
        final createResponse = HttpResponse(
          statusCode: 201,
          body: {
            'dado': {
              'id': 'workflow123',
              'titulo': 'Workflow Test',
              'corpo': 'Test body',
              'dataAgendada': '2024-01-20T15:00:00Z',
            },
          },
          headers: {},
        );
        
        final getResponse = HttpResponse(
          statusCode: 200,
          body: {
            'dados': [
              {
                'id': 'workflow123',
                'titulo': 'Workflow Test',
                'corpo': 'Test body',
                'dataAgendada': '2024-01-20T15:00:00Z',
              },
            ],
          },
          headers: {},
        );
        
        final deleteResponse = HttpResponse(
          statusCode: 200,
          body: {
            'mensagem': 'Notificação excluída com sucesso',
          },
          headers: {},
        );
        
        mockHttp.setResponse('http://10.0.2.2:8080/notificacoes', createResponse);
        mockHttp.setResponse('http://10.0.2.2:8080/notificacoes/usuario/123', getResponse);
        mockHttp.setResponse('http://10.0.2.2:8080/notificacoes/workflow123', deleteResponse);
        
        // Act & Assert
        
        // 1. Create notification
        final notification = NotificationEntity(
          id: '',
          titulo: 'Workflow Test',
          corpo: 'Test body',
          dataAgendada: DateTime.parse('2024-01-20T15:00:00Z'),
        );
        
        final created = await notificationService.createNotification(notification);
        expect(created.id, 'workflow123');
        expect(created.titulo, 'Workflow Test');
        
        // 2. Get notifications
        final notifications = await notificationService.getNotifications();
        expect(notifications, hasLength(1));
        expect(notifications.first.id, 'workflow123');
        
        // 3. Delete notification
        final deleted = await notificationService.deleteNotification('workflow123');
        expect(deleted, true);
        
        // Verify all requests were made
        expect(mockHttp.requests, hasLength(3));
        expect(mockHttp.requests[0]['method'], 'POST');
        expect(mockHttp.requests[1]['method'], 'GET');
        expect(mockHttp.requests[2]['method'], 'DELETE');
      });
    })
  
 