import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:helppsico_mobile/data/repositories/sessions_repository.dart';


void main() {
  group('SessionRepository', () {
    late SessionRepository repository;
    late MockClient mockClient;
    const baseUrl = 'http://localhost:7000';

    setUp(() {
      mockClient = MockClient((request) async {
        throw UnimplementedError('Mock not implemented for this test');
      });
      repository = SessionRepository(client: mockClient);
    });

    test('getSessions should return list of sessions on successful response', () async {
      mockClient = MockClient((request) async {
      
        expect(request.url.toString(), '$baseUrl/sessions');
        expect(request.method, 'GET');

       
        return http.Response(
          json.encode([
            {
              'id': '1',
              'psicologoId': 'Dr. Test',
              'pacienteId': 'patient123',
              'data': '2024-04-05 14:30:00',
              'valor': '150.00',
              'endereco': 'Test Address',
              'finalizada': 'false',
            },
            {
              'id': '2',
              'psicologoId': 'Dr. Test 2',
              'pacienteId': 'patient456',
              'data': '2024-04-06 15:30:00',
              'valor': '200.00',
              'endereco': 'Test Address 2',
              'finalizada': 'true',
            },
          ]),
          200,
        );
      });
      repository = SessionRepository(client: mockClient);

      final sessions = await repository.getSessions();

      expect(sessions.length, 2);
      expect(sessions[0].id, '1');
      expect(sessions[0].psicologoName, 'Dr. Test');
      expect(sessions[0].finalizada, false);
      expect(sessions[1].id, '2');
      expect(sessions[1].psicologoName, 'Dr. Test 2');
      expect(sessions[1].finalizada, true);
    });

    test('getSessions should throw exception on 404 response', () async {
      mockClient = MockClient((request) async {
        return http.Response('Not Found', 404);
      });
      repository = SessionRepository(client: mockClient);

      expect(
        () => repository.getSessions(),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Sessions not found'),
        )),
      );
    });

    test('getSessions should throw exception on 500 response', () async {
      mockClient = MockClient((request) async {
        return http.Response('Server Error', 500);
      });
      repository = SessionRepository(client: mockClient);

      expect(
        () => repository.getSessions(),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Server error'),
        )),
      );
    });

    test('getSessions should throw exception on unexpected status code', () async {
      mockClient = MockClient((request) async {
        return http.Response('Bad Request', 400);
      });
      repository = SessionRepository(client: mockClient);

      expect(
        () => repository.getSessions(),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Failed to load sessions with status code: 400'),
        )),
      );
    });

    test('getSessions should throw exception on network error', () async {
      mockClient = MockClient((request) async {
        throw Exception('Network error');
      });
      repository = SessionRepository(client: mockClient);

      expect(
        () => repository.getSessions(),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Failed to fetch sessions'),
        )),
      );
    });

    test('getSessions should throw exception on invalid JSON response', () async {
      mockClient = MockClient((request) async {
        return http.Response('invalid json', 200);
      });
      repository = SessionRepository(client: mockClient);

      expect(
        () => repository.getSessions(),
        throwsA(isA<Exception>()),
      );
    });
  });
} 