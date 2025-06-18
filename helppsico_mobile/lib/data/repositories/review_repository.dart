import 'package:get_it/get_it.dart';
import 'package:helppsico_mobile/core/services/auth/auth_service.dart';
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';
import 'package:helppsico_mobile/core/services/storage/secure_storage_service.dart' show SecureStorageService, StorageService;
import 'package:helppsico_mobile/data/datasource/review_datasource.dart';

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
           http ?? GenericHttp(),
           secureStorage ?? GetIt.instance.get<SecureStorageService>(),
           authService ?? AuthService(),
         );

  Future<List<ReviewEntity>> getReviews() async {
    try {
      final psicologoInfo = await getPsicologoInfo();
      if (psicologoInfo == null || psicologoInfo['id'] == null) {
        throw Exception('Informações do psicólogo não encontradas');
      }
      final psicologoId = psicologoInfo['id']!;
      return await _dataSource.getReviewsByPsicologoId(psicologoId);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ReviewEntity>> getReviewsByPsicologoId(String psicologoId) async {
    return await _dataSource.getReviewsByPsicologoId(psicologoId);
  }

  Future<void> addReview(ReviewEntity review) async {
    try {
      await _dataSource.addReview(review);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      await _dataSource.deleteReview(reviewId);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, String>?> getPsicologoInfo() async {
    try {
      return await _dataSource.getPsicologoInfo();
    } catch (e) {
      rethrow;
    }
  }
}