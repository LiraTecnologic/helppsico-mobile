import 'package:flutter_test/flutter_test.dart';
import 'package:helppsico_mobile/domain/entities/review_entity.dart';

void main() {
  final tDateTime = DateTime.now();
  final tReviewEntity = ReviewEntity(
    id: 'review1',
    psicologoId: 'psico123',
    userName: 'John Doe',
    rating: 5,
    comment: 'Great psychologist!',
    date: tDateTime,
  );

  group('ReviewEntity', () {
    test('should correctly instantiate with given values', () {
      // Assert
      expect(tReviewEntity.id, 'review1');
      expect(tReviewEntity.psicologoId, 'psico123');
      expect(tReviewEntity.userName, 'John Doe');
      expect(tReviewEntity.rating, 5);
      expect(tReviewEntity.comment, 'Great psychologist!');
      expect(tReviewEntity.date, tDateTime);
    });

    test('two instances with the same values should not be equal by default', () {
      final anotherReviewEntity = ReviewEntity(
        id: 'review1',
        psicologoId: 'psico123',
        userName: 'John Doe',
        rating: 5,
        comment: 'Great psychologist!',
        date: tDateTime,
      );
    
      expect(tReviewEntity == anotherReviewEntity, isFalse);
    });

    test('an instance should be equal to itself', () {
      expect(tReviewEntity == tReviewEntity, isTrue);
    });
  });
}