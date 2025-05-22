import '../../domain/entities/review_entity.dart';
import '../datasource/review_datasource.dart';
import '../datasource/api_review_datasource.dart';

class ReviewRepository {
  final ReviewDataSource _dataSource;

  ReviewRepository({ReviewDataSource? dataSource})
      : _dataSource = dataSource ?? ApiReviewDataSource();

  Future<List<ReviewEntity>> getReviewsByPsicologoId(String psicologoId) async {
    return await _dataSource.getReviewsByPsicologoId(psicologoId);
  }

  Future<void> addReview(ReviewEntity review) async {
    await _dataSource.addReview(review);
  }

  Future<void> deleteReview(String reviewId) async {
    await _dataSource.deleteReview(reviewId);
  }
}