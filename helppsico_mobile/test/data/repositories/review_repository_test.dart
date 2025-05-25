import 'package:flutter_test/flutter_test.dart';
import 'package:helppsico_mobile/data/datasource/review_datasource.dart';
import 'package:helppsico_mobile/data/repositories/review_repository.dart';
import 'package:helppsico_mobile/domain/entities/review_entity.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'review_repository_test.mocks.dart'; 

@GenerateMocks([ReviewDataSource])
void main() {
  late MockReviewDataSource mockDataSource;
  late ReviewRepository repository;

  setUp(() {
    mockDataSource = MockReviewDataSource();
    repository = ReviewRepository(dataSource: mockDataSource);
  });

  final tReviewEntity = ReviewEntity(
    id: '1',
    psicologoId: 'psico1',
    userName: 'Test User',
    rating: 5,
    comment: 'Excellent!',
    date: DateTime.now(),
  );

  final tReviewList = [tReviewEntity];
  const tPsicologoId = 'psico1';
  const tReviewId = '1';

  group('getReviewsByPsicologoId', () {
    test('should return list of ReviewEntity when call to data source is successful', () async {

      when(mockDataSource.getReviewsByPsicologoId(tPsicologoId)).thenAnswer((_) async => tReviewList);

      final result = await repository.getReviewsByPsicologoId(tPsicologoId);

      expect(result, tReviewList);
      verify(mockDataSource.getReviewsByPsicologoId(tPsicologoId)).called(1);
      verifyNoMoreInteractions(mockDataSource);
    });

    test('should throw an exception when call to data source is unsuccessful', () async {

      when(mockDataSource.getReviewsByPsicologoId(tPsicologoId)).thenThrow(Exception('Error'));

      expect(() => repository.getReviewsByPsicologoId(tPsicologoId), throwsA(isA<Exception>()));
      verify(mockDataSource.getReviewsByPsicologoId(tPsicologoId)).called(1);
      verifyNoMoreInteractions(mockDataSource);
    });
  });

  group('addReview', () {
    test('should call addReview on the data source', () async {

      when(mockDataSource.addReview(tReviewEntity)).thenAnswer((_) async => Future.value());

      await repository.addReview(tReviewEntity);

      verify(mockDataSource.addReview(tReviewEntity)).called(1);
      verifyNoMoreInteractions(mockDataSource);
    });

    test('should throw an exception when call to data source is unsuccessful', () async {

      when(mockDataSource.addReview(tReviewEntity)).thenThrow(Exception('Error'));

      expect(() => repository.addReview(tReviewEntity), throwsA(isA<Exception>()));
      verify(mockDataSource.addReview(tReviewEntity)).called(1);
      verifyNoMoreInteractions(mockDataSource);
    });
  });

  group('deleteReview', () {
    test('should call deleteReview on the data source', () async {

      when(mockDataSource.deleteReview(tReviewId)).thenAnswer((_) async => Future.value());

      await repository.deleteReview(tReviewId);

      verify(mockDataSource.deleteReview(tReviewId)).called(1);
      verifyNoMoreInteractions(mockDataSource);
    });

    test('should throw an exception when call to data source is unsuccessful', () async {
   
      when(mockDataSource.deleteReview(tReviewId)).thenThrow(Exception('Error'));
  
      expect(() => repository.deleteReview(tReviewId), throwsA(isA<Exception>()));
      verify(mockDataSource.deleteReview(tReviewId)).called(1);
      verifyNoMoreInteractions(mockDataSource);
    });
  });

  test('constructor should use provided dataSource or create a new one', () {

    expect(repository, isNotNull);

    final defaultRepository = ReviewRepository();
    expect(defaultRepository, isNotNull);
    
  
  });
}