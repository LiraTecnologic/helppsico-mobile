import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';
import 'package:helppsico_mobile/data/datasource/sessions_data_source.dart';

@GenerateNiceMocks([MockSpec<IGenericHttp>()])
import 'sessions_data_source_test.mocks.dart';

void main() {
  late MockIGenericHttp mockHttp;
  late SessionsDataSource dataSource;

  setUp(() {
    mockHttp = MockIGenericHttp();
    dataSource = SessionsDataSource(mockHttp);
  });

  group('SessionsDataSource', () {
    test('getSessions should call http.get with correct URL', () async {
      final mockResponse = HttpResponse(
        statusCode: 200,
        body: [],
        headers: {'content-type': 'application/json'},
      );

      when(mockHttp.get(dataSource.baseUrl))
          .thenAnswer((_) async => mockResponse);

      final result = await dataSource.getSessions();

      verify(mockHttp.get(dataSource.baseUrl)).called(1);
      expect(result, equals(mockResponse));
    });

    test('getSessions should propagate errors from http client', () {
      when(mockHttp.get(dataSource.baseUrl))
          .thenThrow(Exception('Network error'));

      expect(
        () => dataSource.getSessions(),
        throwsA(isA<Exception>()),
      );
    });
  });
}