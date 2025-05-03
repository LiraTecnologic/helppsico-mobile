import '../../domain/entities/review_entity.dart';
import '../mock_reviews.dart';

abstract class ReviewDataSource {
  List<ReviewEntity> getReviewsByPsicologoId(String psicologoId);
  void addReview(ReviewEntity review);
  void deleteReview(String reviewId);
}

class MockReviewDataSource implements ReviewDataSource {
  @override
  List<ReviewEntity> getReviewsByPsicologoId(String psicologoId) {
    return MockReviews.getReviewsByPsicologoId(psicologoId);
  }

  @override
  void addReview(ReviewEntity review) {
    MockReviews.addReview(review);
  }

  @override
  void deleteReview(String reviewId) {
    MockReviews.deleteReview(reviewId);
  }
}