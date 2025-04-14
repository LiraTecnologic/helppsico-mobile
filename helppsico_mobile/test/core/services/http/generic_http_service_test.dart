import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';

@GenerateNiceMocks([MockSpec<http.Client>()])
import 'generic_http_service_test.mocks.dart';

void main() {
  late MockClient mockClient;
  late GenericHttp genericHttp;
  const testUrl = 'http://test.com';

  setUp(() {
    mockClient = MockClient();
    genericHttp = GenericHttp(client: mockClient);
  });

  group('GenericHttp', () {
    test('get should return HttpResponse on success', () async {
      final responseData = {'key': 'value'};
      final headers = {'content-type': 'application/json'};

      when(mockClient.get(Uri.parse(testUrl), headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(
                json.encode(responseData),
                200,
                headers: headers,
              ));

      final response = await genericHttp.get(testUrl);

      expect(response.statusCode, equals(200));
      expect(response.body, equals(responseData));
      expect(response.headers, equals(headers));
    });

    test('get should throw exception on error', () async {
      when(mockClient.get(Uri.parse(testUrl), headers: anyNamed('headers')))
          .thenThrow(Exception('Network error'));

      expect(
        () => genericHttp.get(testUrl),
        throwsA(isA<Exception>()),
      );
    });

    test('get should handle invalid JSON response', () async {
      when(mockClient.get(Uri.parse(testUrl), headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(
                'invalid json',
                200,
              ));

      expect(
        () => genericHttp.get(testUrl),
        throwsA(isA<FormatException>()),
      );
    });
  });
}