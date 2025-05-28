import 'package:helppsico_mobile/data/datasource/review_datasource.dart';
import 'package:helppsico_mobile/data/services/auth_service.dart';
import 'package:helppsico_mobile/data/services/generic_http_service.dart';
import 'package:helppsico_mobile/data/services/secure_storage_service.dart';
import '../../domain/entities/review_entity.dart';


class ReviewRepository {
  final ReviewDataSource _dataSource;

  ReviewRepository({
    ReviewDataSource? dataSource,
    IGenericHttp? http,
    SecureStorageService? secureStorage,
    AuthService? authService,
  }) : _dataSource = dataSource ?? 
       ReviewDataSource(
         http ?? GenericHttpService(),
         secureStorage ?? SecureStorageService(),
         authService ?? AuthService(),
       );

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