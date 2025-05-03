import '../../domain/entities/review_entity.dart';
import '../datasource/review_datasource.dart';

class ReviewRepository {
  final ReviewDataSource _dataSource;

  ReviewRepository({ReviewDataSource? dataSource})
      : _dataSource = dataSource ?? MockReviewDataSource();

  List<ReviewEntity> getReviewsByPsicologoId(String psicologoId) {
    return _dataSource.getReviewsByPsicologoId(psicologoId);
  }

  void addReview(ReviewEntity review) {
    _dataSource.addReview(review);
  }

  void deleteReview(String reviewId) {
    _dataSource.deleteReview(reviewId);
  }
}