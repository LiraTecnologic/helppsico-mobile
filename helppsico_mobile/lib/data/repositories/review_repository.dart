import 'package:get_it/get_it.dart';
import 'package:helppsico_mobile/core/services/auth/auth_service.dart';
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';
import 'package:helppsico_mobile/core/services/storage/secure_storage_service.dart' show SecureStorageService;
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
       ) {
    print('[ReviewRepository] Instance created');
  }

  Future<List<ReviewEntity>> getReviews() async {
    print('[ReviewRepository] getReviews called');
    try {
      // Primeiro, obter informações do psicólogo
      print('[ReviewRepository] Getting psicologo info from datasource');
      final psicologoInfo = await _dataSource.getPsicologoInfo();
      
      if (psicologoInfo == null || psicologoInfo['id'] == null) {
        print('[ReviewRepository] Psicologo info is null or missing id: $psicologoInfo');
        throw Exception('Informações do psicólogo não encontradas');
      }
      
      final psicologoId = psicologoInfo['id']!;
      print('[ReviewRepository] Found psicologoId: $psicologoId, getting reviews');
      
      // Buscar avaliações do psicólogo
      final reviews = await _dataSource.getReviewsByPsicologoId(psicologoId);
      print('[ReviewRepository] Retrieved ${reviews.length} reviews from datasource');
      return reviews;
    } catch (e) {
      print('[ReviewRepository] Erro no repositório ao buscar avaliações: $e');
      rethrow;
    }
  }

  Future<List<ReviewEntity>> getReviewsByPsicologoId(String psicologoId) async {
    return await _dataSource.getReviewsByPsicologoId(psicologoId);
  }

  Future<void> addReview(ReviewEntity review) async {
    print('[ReviewRepository] addReview called with review: id=${review.id}, rating=${review.rating}');
    try {
      await _dataSource.addReview(review);
      print('[ReviewRepository] Review added successfully via datasource');
    } catch (e) {
      print('[ReviewRepository] Erro no repositório ao adicionar avaliação: $e');
      rethrow;
    }
  }

  Future<void> deleteReview(String reviewId) async {
    print('[ReviewRepository] deleteReview called with reviewId: $reviewId');
    try {
      await _dataSource.deleteReview(reviewId);
      print('[ReviewRepository] Review deleted successfully via datasource');
    } catch (e) {
      print('[ReviewRepository] Erro no repositório ao excluir avaliação: $e');
      rethrow;
    }
  }

  Future<Map<String, String>?> getPsicologoInfo() async {
    print('[ReviewRepository] getPsicologoInfo called');
    try {
      final psicologoInfo = await _dataSource.getPsicologoInfo();
      print('[ReviewRepository] Retrieved psicologo info: $psicologoInfo');
      return psicologoInfo;
    } catch (e) {
      print('[ReviewRepository] Erro no repositório ao obter informações do psicólogo: $e');
      rethrow;
    }
  }
}