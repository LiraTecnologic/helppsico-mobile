import 'package:helppsico_mobile/data/datasource/review_datasource.dart';
import '../../domain/entities/review_entity.dart';


class ReviewRepository {
  final ReviewDataSource _dataSource;

  ReviewRepository({ReviewDataSource? dataSource})
      : _dataSource = dataSource ?? ReviewDataSource();

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