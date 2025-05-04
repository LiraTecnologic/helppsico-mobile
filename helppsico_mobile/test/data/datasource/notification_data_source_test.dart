import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';
import 'package:helppsico_mobile/data/datasource/notification_data_source.dart';

@GenerateNiceMocks([MockSpec<IGenericHttp>()])
import 'notification_data_source_test.mocks.dart';

void main() {
  late MockIGenericHttp mockHttp;
  late NotificationDataSource dataSource;

  setUp(() {
    mockHttp = MockIGenericHttp();
    dataSource = NotificationDataSource(mockHttp);
  });

  group('NotificationDataSource', () {
    test('getNotifications should call http.get with correct URL', () async {
      final mockResponse = HttpResponse(
        statusCode: 200,
        body: [],
        headers: {'content-type': 'application/json'},
      );

      when(mockHttp.get(baseUrl))
          .thenAnswer((_) async => mockResponse);

      final result = await dataSource.getNotifications();

      verify(mockHttp.get(baseUrl)).called(1);
      expect(result, equals(mockResponse));
    });

    test('getNotifications should propagate errors from http client', () {
      when(mockHttp.get(baseUrl))
          .thenThrow(Exception('Network error'));

      expect(
        () => dataSource.getNotifications(),
        throwsA(isA<Exception>()),
      );
    });
  });
}