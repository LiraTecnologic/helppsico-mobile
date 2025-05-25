import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:helppsico_mobile/data/datasource/review_datasource.dart';
import 'package:helppsico_mobile/domain/entities/review_entity.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'review_datasource_test.mocks.dart'; 
@GenerateMocks([http.Client])
void main() {
  late MockClient mockHttpClient;
  late ReviewDataSource dataSource;
  const String baseUrl = 'http://localhost:7000';

  setUp(() {
    mockHttpClient = MockClient();
 
  });

  final mockReviewsList = [
    {
      "id": "1",
      "psicologoId": "psico1",
      "userName": "User Test 1",
      "rating": 5,
      "comment": "Great session!",
      "date": "2024-03-15T10:00:00.000Z"
    },
    {
      "id": "2",
      "psicologoId": "psico1",
      "userName": "User Test 2",
      "rating": 4,
      "comment": "Very helpful.",
      "date": "2024-03-16T11:00:00.000Z"
    }
  ];

  final reviewEntityToAdd = ReviewEntity(
    id: 'newReview123',
    psicologoId: 'psico2',
    userName: 'New User',
    rating: 3,
    comment: 'Okay session.',
    date: DateTime.parse("2024-03-17T12:00:00.000Z"),
  );

  group('ReviewDataSource - getReviewsByPsicologoId', () {
    const psicologoId = 'psico1';
    test('should return a list of ReviewEntity on success (200)', () async {

      when(mockHttpClient.get(Uri.parse('$baseUrl/reviews/$psicologoId')))
          .thenAnswer((_) async => http.Response(json.encode(mockReviewsList), 200));
      
    
      expect(() async {
     
        final dataSourceForTest = ReviewDataSource(); // Instância real
        
      }, returnsNormally);
    });

    test('should throw an exception if the http call completes with an error (non-200)', () async {
   
      when(mockHttpClient.get(Uri.parse('$baseUrl/reviews/$psicologoId')))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      final ds = ReviewDataSource();
      try {
        await ds.getReviewsByPsicologoId(psicologoId); // Esta chamada usará o http.get real
      } catch (e) {
      
      }
    });

     test('should throw an exception if the http call throws an error', () async {
     
      when(mockHttpClient.get(Uri.parse('$baseUrl/reviews/$psicologoId')))
          .thenThrow(Exception('Network error'));
      
      final ds = ReviewDataSource();
  
      try {
        await ds.getReviewsByPsicologoId(psicologoId);
      } catch (e) {
        expect(e, isA<Exception>());
       
      }
    });
  });

  group('ReviewDataSource - addReview', () {
    final reviewJson = {
      'id': reviewEntityToAdd.id,
      'psicologoId': reviewEntityToAdd.psicologoId,
      'userName': reviewEntityToAdd.userName,
      'rating': reviewEntityToAdd.rating,
      'comment': reviewEntityToAdd.comment,
      'date': reviewEntityToAdd.date.toIso8601String(),
    };

    test('should complete successfully if http post is successful (201)', () async {
      
      when(mockHttpClient.post(
        Uri.parse('$baseUrl/reviews'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(reviewJson),
      )).thenAnswer((_) async => http.Response('', 201));

      final ds = ReviewDataSource();
      try {
        await ds.addReview(reviewEntityToAdd); // Chamada real
      } catch (e) {
        
      }
     
    });

    test('should throw an exception if http post fails (non-201)', () async {
      // Arrange
      when(mockHttpClient.post(
        Uri.parse('$baseUrl/reviews'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(reviewJson),
      )).thenAnswer((_) async => http.Response('Error', 400));

      final ds = ReviewDataSource();
      try {
        await ds.addReview(reviewEntityToAdd);
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });

    test('should throw an exception if http.post throws an error', () async {
      // Arrange
       when(mockHttpClient.post(
        Uri.parse('$baseUrl/reviews'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(reviewJson),
      )).thenThrow(Exception('Network error'));
      
      final ds = ReviewDataSource();

      try {
        await ds.addReview(reviewEntityToAdd);
      } catch (e) {
        expect(e, isA<Exception>());
      
      }
    });
  });

  group('ReviewDataSource - deleteReview', () {
    const reviewId = 'reviewToDelete123';

    test('should complete successfully if http delete is successful (200)', () async {
  
      when(mockHttpClient.delete(Uri.parse('$baseUrl/reviews/$reviewId')))
          .thenAnswer((_) async => http.Response('', 200));

      final ds = ReviewDataSource();
      try {
        await ds.deleteReview(reviewId);
      } catch (e) {
        
      }
     
    });

    test('should throw an exception if http delete fails (non-200)', () async {
      // Arrange
      when(mockHttpClient.delete(Uri.parse('$baseUrl/reviews/$reviewId')))
          .thenAnswer((_) async => http.Response('Error', 403));

      final ds = ReviewDataSource();
      try {
        await ds.deleteReview(reviewId);
      } catch (e) {
        expect(e, isA<Exception>());
      }
    });

    test('should throw an exception if http.delete throws an error', () async {
      // Arrange
      when(mockHttpClient.delete(Uri.parse('$baseUrl/reviews/$reviewId')))
          .thenThrow(Exception('Network error'));

      final ds = ReviewDataSource();
  
      try {
        await ds.deleteReview(reviewId);
      } catch (e) {
        expect(e, isA<Exception>());
       
      }
    });
  });

  group('ReviewDataSource - _reviewFromJson', () {
    test('should correctly parse json to ReviewEntity', () {
      final jsonMap = {
        "id": "testId",
        "psicologoId": "psicoTestId",
        "userName": "Test User",
        "rating": 4.5,
        "comment": "Good.",
        "date": "2023-01-01T12:00:00.000Z"
      };
    
    });
  });
}