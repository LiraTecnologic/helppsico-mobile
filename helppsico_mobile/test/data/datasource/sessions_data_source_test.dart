import 'package:flutter_test/flutter_test.dart';
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';
import 'package:helppsico_mobile/core/services/storage/secure_storage_service.dart';
import 'package:helppsico_mobile/data/datasource/sessions_data_source.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'sessions_data_source_test.mocks.dart';

// Mock IGenericHttp e SecureStorageService
@GenerateMocks([IGenericHttp, SecureStorageService])
void main() {
  late MockIGenericHttp mockHttp;
  late MockSecureStorageService mockSecureStorageService;
  late SessionsDataSource dataSource;

  const String expectedBaseUrl = 'http://localhost:7000/sessions';
  const String mockToken = 'mock_token';

  setUp(() {
    mockHttp = MockIGenericHttp();
    mockSecureStorageService = MockSecureStorageService();
    dataSource = SessionsDataSource(mockHttp);

  });

  final mockSessionsList = [
    {'id': '1', 'psicologoName': 'Dr. Teste', 'data': '2024-07-20T10:00:00Z'},
    {'id': '2', 'psicologoName': 'Dra. Exemplo', 'data': '2024-07-21T14:30:00Z'},
  ];

  final mockNextSession = {
    'id': '3',
    'psicologoName': 'Dr. Proximo',
    'data': '2024-07-22T09:00:00Z'
  };


  test('baseUrl should return correct url for non-Android', () {
   
    expect(dataSource.baseUrl, expectedBaseUrl);
  });

  group('getSessions', () {
    test('should return HttpResponse with sessions on success', () async {
    
      final successResponse = HttpResponse(statusCode: 200, body: mockSessionsList);
      when(mockHttp.get(
        expectedBaseUrl,
        headers: {'Authorization': 'Bearer $mockToken'},
      )).thenAnswer((_) async => successResponse);

     
      when(mockHttp.get(expectedBaseUrl, headers: anyNamed('headers')))
          .thenAnswer((_) async => successResponse);
      
      final result = await dataSource.getSessions(); // Esta chamada usará o mockHttp
      expect(result.statusCode, 200);
      expect(result.body, mockSessionsList);
     
      verify(mockHttp.get(expectedBaseUrl, headers: argThat(containsPair('Authorization', startsWith('Bearer '))))).called(1);
    });

    test('should throw an exception if http.get fails', () async {
    
      when(mockHttp.get(expectedBaseUrl, headers: anyNamed('headers')))
          .thenThrow(Exception('Network error'));

      
      expect(dataSource.getSessions(), throwsA(isA<Exception>()));
    });
  });

  group('getNextSession', () {
    final String nextSessionUrl = '$expectedBaseUrl/next';

    test('should return HttpResponse with the next session on success', () async {

      final successResponse = HttpResponse(statusCode: 200, body: mockNextSession);
      when(mockHttp.get(
        nextSessionUrl,
        headers: anyNamed('headers'), // Similar ao getSessions, o token é um desafio
      )).thenAnswer((_) async => successResponse);


     
      final result = await dataSource.getNextSession();

      // Assert
      expect(result.statusCode, 200);
      expect(result.body, mockNextSession);
      verify(mockHttp.get(nextSessionUrl, headers: argThat(containsPair('Authorization', startsWith('Bearer '))))).called(1);
    });

    test('should throw an exception if http.get for next session fails', () async {
    
      when(mockHttp.get(nextSessionUrl, headers: anyNamed('headers')))
          .thenThrow(Exception('Network error'));

    
      expect(dataSource.getNextSession(), throwsA(isA<Exception>()));
    });
  });
}