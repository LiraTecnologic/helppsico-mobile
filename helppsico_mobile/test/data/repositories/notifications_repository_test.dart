import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';
import 'package:helppsico_mobile/data/datasource/notification_data_source.dart';
import 'package:helppsico_mobile/data/repositories/notifications_repository.dart';
import 'package:helppsico_mobile/domain/entities/notification_model.dart';

@GenerateNiceMocks([MockSpec<NotificationDataSource>()])
import 'notifications_repository_test.mocks.dart';

void main() {
  late MockNotificationDataSource mockDataSource;
  late NotificationRepository repository;

  setUp(() {
    mockDataSource = MockNotificationDataSource();
    repository = NotificationRepository(mockDataSource);
  });

  group('NotificationRepository', () {
    test('getNotifications should return list of NotificationModel on success', () async {
      final mockResponse = HttpResponse(
        statusCode: 200,
        body: [
          {
            'id': '1',
            'title': 'Test Notification',
            'message': 'Test Message',
            'createdAt': '2024-01-01T00:00:00.000Z',
            'isRead': false,
            'type': 'info',
            'actionText': 'View'
          }
        ],
      );

      when(mockDataSource.getNotifications())
          .thenAnswer((_) async => mockResponse);

      final result = await repository.getNotifications();

      expect(result, isA<List<NotificationModel>>());
      expect(result.length, equals(1));
      expect(result.first.id, equals('1'));
      expect(result.first.title, equals('Test Notification'));
      expect(result.first.message, equals('Test Message'));
    });

    test('getNotifications should throw exception on non-200 status code', () async {
      final mockResponse = HttpResponse(
        statusCode: 404,
        body: {'error': 'Not found'},
      );

      when(mockDataSource.getNotifications())
          .thenAnswer((_) async => mockResponse);

      expect(
        () => repository.getNotifications(),
        throwsA(isA<Exception>()),
      );
    });

    test('getNotifications should propagate data source errors', () {
      when(mockDataSource.getNotifications())
          .thenThrow(Exception('Network error'));

      expect(
        () => repository.getNotifications(),
        throwsA(isA<Exception>()),
      );
    });
  });
}