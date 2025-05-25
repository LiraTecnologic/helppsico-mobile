import 'package:flutter_test/flutter_test.dart';
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';
import 'package:helppsico_mobile/data/datasource/sessions_data_source.dart';
import 'package:helppsico_mobile/data/repositories/sessions_repository.dart';
import 'package:helppsico_mobile/domain/entities/session_model.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'sessions_repository_test.mocks.dart'; 

@GenerateMocks([SessionsDataSource])
void main() {
  late MockSessionsDataSource mockDataSource;
  late SessionRepository repository;

  setUp(() {
    mockDataSource = MockSessionsDataSource();
    repository = SessionRepository(mockDataSource);
  });

  final tSessionJson = {
    'id': '1',
    'psicologoName': 'Dr. Teste',
    'pacienteId': 'p1',
    'data': '2024-07-20T10:00:00Z',
    'valor': '150.00',
    'endereco': 'Rua Teste, 123',
    'finalizada': false,
  };

  final tSessionModel = SessionModel.fromJson(tSessionJson);

  final tSessionsListJson = [tSessionJson, tSessionJson];
  final tSessionsListModel = [tSessionModel, tSessionModel];

  group('getSessions', () {
    test('should return list of SessionModel when call to data source is successful (200)', () async {

      when(mockDataSource.getSessions())
          .thenAnswer((_) async => HttpResponse(statusCode: 200, body: tSessionsListJson));

      final result = await repository.getSessions();

      expect(result, isA<List<SessionModel>>());
      expect(result.length, tSessionsListModel.length);
      expect(result.first.id, tSessionModel.id);
      verify(mockDataSource.getSessions()).called(1);
    });

    test('should throw an exception when call to data source is unsuccessful (non-200)', () async {

      when(mockDataSource.getSessions())
          .thenAnswer((_) async => HttpResponse(statusCode: 404, body: 'Not Found'));

      expect(() => repository.getSessions(), throwsA(isA<Exception>()));
      verify(mockDataSource.getSessions()).called(1);
    });

    test('should throw an exception when data source call throws an error', () async {

      when(mockDataSource.getSessions()).thenThrow(Exception('DataSource Error'));

      expect(() => repository.getSessions(), throwsA(isA<Exception>()));
      verify(mockDataSource.getSessions()).called(1);
    });
  });

  group('getNextSession', () {
    test('should return SessionModel when call to data source is successful (200) and body is not empty', () async {

      when(mockDataSource.getNextSession())
          .thenAnswer((_) async => HttpResponse(statusCode: 200, body: tSessionJson));
     
      final result = await repository.getNextSession();

      expect(result, isA<SessionModel>());
      expect(result?.id, tSessionModel.id);
      verify(mockDataSource.getNextSession()).called(1);
    });

    test('should return null when call to data source is successful (200) but body is empty map', () async {

      when(mockDataSource.getNextSession())
          .thenAnswer((_) async => HttpResponse(statusCode: 200, body: {}));
     
      final result = await repository.getNextSession();

      expect(result, isNull);
      verify(mockDataSource.getNextSession()).called(1);
    });

    test('should return null when call to data source is successful (200) but body is null', () async {

      when(mockDataSource.getNextSession())
          .thenAnswer((_) async => HttpResponse(statusCode: 200, body: null));
     
      final result = await repository.getNextSession();

      expect(result, isNull);
      verify(mockDataSource.getNextSession()).called(1);
    });

    test('should throw an exception when call to data source is unsuccessful (non-200)', () async {

      when(mockDataSource.getNextSession())
          .thenAnswer((_) async => HttpResponse(statusCode: 500, body: 'Server Error'));

      expect(() => repository.getNextSession(), throwsA(isA<Exception>()));
      verify(mockDataSource.getNextSession()).called(1);
    });

    test('should rethrow exception when data source call throws an error', () async {

      when(mockDataSource.getNextSession()).thenThrow(Exception('DataSource Error'));

      expect(() => repository.getNextSession(), throwsA(isA<Exception>()));
      verify(mockDataSource.getNextSession()).called(1);
    });
  });
}