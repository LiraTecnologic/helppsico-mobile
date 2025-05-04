import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';
import 'package:helppsico_mobile/data/datasource/sessions_data_source.dart';
import 'package:helppsico_mobile/data/repositories/sessions_repository.dart';
import 'package:helppsico_mobile/domain/entities/session_model.dart';

@GenerateNiceMocks([MockSpec<SessionsDataSource>()])
import 'sessions_repository_test.mocks.dart';

void main() {
  late MockSessionsDataSource mockDataSource;
  late SessionRepository repository;

  setUp(() {
    mockDataSource = MockSessionsDataSource();
    repository = SessionRepository(mockDataSource);
  });

  group('SessionRepository', () {
    final mockSessionData = {
      'id': '123',
      'psicologoId': 'Dr. Smith',
      'pacienteId': 'patient123',
      'data': '2024-01-01T10:00:00.000Z',
      'valor': '150.00',
      'endereco': 'Rua Example, 123',
      'finalizada': 'false'
    };

    test('getSessions should return list of SessionModel on success', () async {
      final mockResponse = HttpResponse(
        statusCode: 200,
        body: [mockSessionData],
      );

      when(mockDataSource.getSessions())
          .thenAnswer((_) async => mockResponse);

      final result = await repository.getSessions();

      expect(result, isA<List<SessionModel>>());
      expect(result.length, equals(1));
      expect(result.first.id, equals('123'));
      expect(result.first.psicologoName, equals('Dr. Smith'));
      expect(result.first.pacienteId, equals('patient123'));
      expect(result.first.valor, equals('150.00'));
      expect(result.first.endereco, equals('Rua Example, 123'));
      expect(result.first.finalizada, equals(false));
      expect(result.first.data, isA<DateTime>());
    });

    test('getSessions should throw exception on non-200 status code', () async {
      final mockResponse = HttpResponse(
        statusCode: 404,
        body: {'error': 'Not found'},
      );

      when(mockDataSource.getSessions())
          .thenAnswer((_) async => mockResponse);

      expect(
        () => repository.getSessions(),
        throwsA(isA<Exception>()),
      );
    });

    test('getSessions should handle empty response', () async {
      final mockResponse = HttpResponse(
        statusCode: 200,
        body: [],
      );

      when(mockDataSource.getSessions())
          .thenAnswer((_) async => mockResponse);

      final result = await repository.getSessions();
      expect(result, isEmpty);
    });

    test('getSessions should handle malformed date', () async {
      final malformedData = Map<String, dynamic>.from(mockSessionData);
      malformedData['data'] = 'invalid-date';

      final mockResponse = HttpResponse(
        statusCode: 200,
        body: [malformedData],
      );

      when(mockDataSource.getSessions())
          .thenAnswer((_) async => mockResponse);

      expect(
        () => repository.getSessions(),
        throwsA(isA<FormatException>()),
      );
    });

    test('getSessions should propagate data source errors', () {
      when(mockDataSource.getSessions())
          .thenThrow(Exception('Network error'));

      expect(
        () => repository.getSessions(),
        throwsA(isA<Exception>()),
      );
    });
  });
}