import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late GenericHttp genericHttp;
  late MockHttpClient mockClient;

  setUp(() {
    mockClient = MockHttpClient();
    genericHttp = GenericHttp(client: mockClient);
    registerFallbackValue(Uri.parse('http://example.com'));
  });

  group('GenericHttp', () {
    group('constructor', () {
      test('should use provided client when given', () {
        final client = MockHttpClient();
        final http = GenericHttp(client: client);
        
       
        expect(http, isA<GenericHttp>());
      });

      test('should create default client when not provided', () {
        final http = GenericHttp();
        
        
        expect(http, isA<GenericHttp>());
      });
    });

    group('get', () {
      const testUrl = 'http://example.com';
      final testHeaders = {'Authorization': 'Bearer token'};
      final testResponseBody = {'data': 'test data'};
      
      test('should make GET request with correct parameters', () async {
        
        when(() => mockClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response(
                  json.encode(testResponseBody),
                  200,
                  headers: {'content-type': 'application/json'},
                ));

        
        final response = await genericHttp.get(testUrl, headers: testHeaders);

       
        verify(() => mockClient.get(Uri.parse(testUrl), headers: testHeaders)).called(1);
        expect(response.statusCode, equals(200));
        expect(response.body, equals(testResponseBody));
      });

      test('should handle GET request errors', () async {
        
        when(() => mockClient.get(any(), headers: any(named: 'headers')))
            .thenThrow(Exception('Network error'));

        expect(
          () => genericHttp.get(testUrl, headers: testHeaders),
          throwsA(isA<Exception>()),
        );
        verify(() => mockClient.get(Uri.parse(testUrl), headers: testHeaders)).called(1);
      });

      test('should handle GET response with invalid JSON', () async {
        when(() => mockClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response(
                  'invalid json',
                  200,
                  headers: {'content-type': 'application/json'},
                ));

       
        expect(
          () => genericHttp.get(testUrl, headers: testHeaders),
          throwsA(isA<FormatException>()),
        );
      });
    });

    group('post', () {
      const testUrl = 'http://example.com';
      final testBody = {'name': 'test', 'value': 123};
      final testHeaders = {'Authorization': 'Bearer token'};
      final testResponseBody = {'status': 'success'};
      
      test('should make POST request with correct parameters', () async {
        
        when(() => mockClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => http.Response(
                  json.encode(testResponseBody),
                  201,
                  headers: {'content-type': 'application/json'},
                ));


        final response = await genericHttp.post(testUrl, testBody, headers: testHeaders);

        
        final expectedHeaders = {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer token',
        };
        
        verify(() => mockClient.post(
              Uri.parse(testUrl),
              headers: expectedHeaders,
              body: json.encode(testBody),
            )).called(1);
            
        expect(response.statusCode, equals(201));
        expect(response.body, equals(testResponseBody));
      });

      test('should make POST request with default headers when none provided', () async {
        
        when(() => mockClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => http.Response(
                  json.encode(testResponseBody),
                  201,
                  headers: {'content-type': 'application/json'},
                ));


        final response = await genericHttp.post(testUrl, testBody);

       
        final expectedHeaders = {
          'Content-Type': 'application/json',
        };
        
        verify(() => mockClient.post(
              Uri.parse(testUrl),
              headers: expectedHeaders,
              body: json.encode(testBody),
            )).called(1);
            
        expect(response.statusCode, equals(201));
        expect(response.body, equals(testResponseBody));
      });

      test('should handle POST request errors', () async {
        
        when(() => mockClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenThrow(Exception('Network error'));

       
        expect(
          () => genericHttp.post(testUrl, testBody, headers: testHeaders),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle POST response with invalid JSON', () async {
        
        when(() => mockClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((_) async => http.Response(
                  'invalid json',
                  201,
                  headers: {'content-type': 'application/json'},
                ));

       
        expect(
          () => genericHttp.post(testUrl, testBody, headers: testHeaders),
          throwsA(isA<FormatException>()),
        );
      });
    });

    group('HttpResponse', () {
      test('should create instance with required parameters', () {
        final response = HttpResponse(
          statusCode: 200,
          body: {'data': 'test'},
        );

        expect(response.statusCode, equals(200));
        expect(response.body, equals({'data': 'test'}));
        expect(response.headers, isNull);
      });

      test('should create instance with all parameters', () {
        final headers = {'content-type': 'application/json'};
        final response = HttpResponse(
          statusCode: 200,
          body: {'data': 'test'},
          headers: headers,
        );
        expect(response.statusCode, equals(200));
        expect(response.body, equals({'data': 'test'}));
        expect(response.headers, equals(headers));
      });
    });
  });
}