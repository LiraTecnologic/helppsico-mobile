import '../../domain/entities/review_entity.dart';

abstract class ReviewDataSource {
  Future<List<ReviewEntity>> getReviewsByPsicologoId(String psicologoId);
  Future<void> addReview(ReviewEntity review);
  Future<void> deleteReview(String reviewId);
}