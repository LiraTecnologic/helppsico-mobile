
import '../../domain/entities/review_entity.dart';
import '../../core/services/http/generic_http_service.dart';
import '../../core/services/auth/auth_service.dart';
import '../../core/services/storage/secure_storage_service.dart';

class ReviewDataSource  {
  String get baseUrl {
    const bool isAndroid = bool.fromEnvironment('dart.vm.android');
    
    return isAndroid ? 'http://10.0.2.2:8080' : 'http://localhost:8080';
  }
  
  final IGenericHttp _http;
  final SecureStorageService _secureStorage;
  final AuthService _authService;
  
  ReviewDataSource(this._http, this._secureStorage, this._authService) {
    print('[ReviewDataSource] Instance created with baseUrl: $baseUrl');
  }


  Future<String> _getPacienteId() async {
    print('[ReviewDataSource] _getPacienteId called');
    try {
      print('[ReviewDataSource] Attempting to get userId from secure storage');
      final userId = await _secureStorage.getUserId();
      if (userId != null && userId.isNotEmpty) {
        print('[ReviewDataSource] UserId found in storage: $userId');
        return userId;
      }
      
      print('[ReviewDataSource] UserId not found in storage, trying AuthService.getUserInfo()');
      final userInfo = await _authService.getUserInfo();
      final id = userInfo?['id'] ?? '';
      print('[ReviewDataSource] UserInfo from AuthService: $userInfo, extracted id: $id');
      return id;
    } catch (e) {
      print('[ReviewDataSource] Erro ao obter ID do paciente: $e');
      return '';
    }
  }


  Future<Map<String, String>?> _getPsicologoInfo() async {
    print('[ReviewDataSource] _getPsicologoInfo called');
    try {
      final pacienteId = await _getPacienteId();
      if (pacienteId.isEmpty) {
        print('[ReviewDataSource] ID do paciente não encontrado ao buscar informações do psicólogo.');
        return null;
      }

      print('[ReviewDataSource] Making API call to get vinculos for pacienteId: $pacienteId');
      final response = await _http.get('$baseUrl/vinculos/listar/paciente/$pacienteId');

      print('[ReviewDataSource] Vinculos API response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final responseData = response.body;
        print('[ReviewDataSource] Vinculos API response data: $responseData');
        if (responseData != null &&
            responseData.containsKey('dado') &&
            responseData['dado'] != null &&
            responseData['dado'].containsKey('content') &&
            responseData['dado']['content'] is List &&
            (responseData['dado']['content'] as List).isNotEmpty) {
          // The provided JSON shows 'psicologo' directly under the first element of 'content'
          final vinculo = responseData['dado']['content'][0];
          print('[ReviewDataSource] First vinculo data: $vinculo');
          if (vinculo != null && vinculo['psicologo'] != null) {
            final psicologoData = vinculo['psicologo'];
            print('[ReviewDataSource] Psicologo data from vinculo: $psicologoData');
            if (psicologoData['id'] != null && psicologoData['nome'] != null) {
              final result = {
                'id': psicologoData['id'].toString(),
                'nome': psicologoData['nome'].toString(),
              };
              print('[ReviewDataSource] Returning psicologo info: $result');
              return result;
            } else {
              print('[ReviewDataSource] Dados do psicólogo (id ou nome) ausentes no objeto psicologo.');
              return null;
            }
          } else {
            print('[ReviewDataSource] Objeto psicologo não encontrado no primeiro vínculo.');
            return null;
          }
        } else {
          print('[ReviewDataSource] Nenhum conteúdo de vínculo encontrado para o paciente.');
          return null;
        }
      } else {
        print('[ReviewDataSource] Falha ao buscar vínculos do paciente: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('[ReviewDataSource] Erro ao obter informações do psicólogo: $e');
      return null;
    }
  }
   Future<Map<String, String>?> getPsicologoInfo() async{
     print('[ReviewDataSource] getPsicologoInfo (public method) called');
     return await _getPsicologoInfo();
   }
  
  Future<List<ReviewEntity>> getReviewsByPsicologoId(String psicologoId) async {
    print('[ReviewDataSource] getReviewsByPsicologoId called with psicologoId: $psicologoId');
    try {
      print('[ReviewDataSource] Making API call to get reviews for psicologo: $psicologoId');
      final response = await _http.get('$baseUrl/avaliacoes/psicologo/$psicologoId');
      
      print('[ReviewDataSource] Reviews API response status: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('[ReviewDataSource] Reviews API response body: ${response.body}');
        
        final responseData = response.body;
        if (responseData == null || !responseData.containsKey('dado')) {
          print('[ReviewDataSource] Invalid response format - missing dado field');
          throw Exception('Formato de resposta inv lido');
        }
        
        final avaliacoesPage = responseData['dado'];
        final List<dynamic> avaliacoes = avaliacoesPage['content'] ?? [];
        print('[ReviewDataSource] Found ${avaliacoes.length} reviews in response');
        
        final reviewEntities = avaliacoes.map((json) => _adaptAvaliacaoToReviewEntity(json)).toList();
        print('[ReviewDataSource] Converted to ${reviewEntities.length} ReviewEntity objects');
        return reviewEntities;
      } else {
        final errorMessage = response.body['mensagem'] ?? 'Falha ao carregar avalia es';
        print('[ReviewDataSource] API error: $errorMessage');
        throw Exception('Erro ao buscar avalia es: $errorMessage');
      }
    } catch (e) {
      print('[ReviewDataSource] Exception in getReviewsByPsicologoId: $e');
      throw Exception('Erro de conex o: $e');
    }
  }
  
  ReviewEntity _adaptAvaliacaoToReviewEntity(Map<String, dynamic> avaliacaoDto) {
    print('[ReviewDataSource] Adapting avaliacaoDto to ReviewEntity: $avaliacaoDto');
    final reviewEntity = ReviewEntity(
      id: avaliacaoDto['id']?.toString() ?? '',
      psicologoId: avaliacaoDto['idPsicologo']?.toString() ?? '',
      userName: avaliacaoDto['nomePaciente'] ?? '',
      rating: avaliacaoDto['nota'] ?? 0,
      comment: avaliacaoDto['comentario'] ?? '',
      date: avaliacaoDto['dataCriacao'] != null ? 
          DateTime.parse(avaliacaoDto['dataCriacao']) : 
          DateTime.now(),
    );
    print('[ReviewDataSource] Created ReviewEntity: id=${reviewEntity.id}, userName=${reviewEntity.userName}, rating=${reviewEntity.rating}');
    return reviewEntity;
  }
  Future<void> addReview(ReviewEntity review) async {
    print('[ReviewDataSource] addReview called with review: id=${review.id}, psicologoId=${review.psicologoId}, rating=${review.rating}');
    try {
      final pacienteId = await _getPacienteId();
      if (pacienteId.isEmpty) {
        print('[ReviewDataSource] Cannot add review - pacienteId is empty');
        throw Exception('ID do paciente não encontrado');
      }
      

      print("avaliacaoDto: ${review.psicologoId}, ${pacienteId}, ${review.rating}, ${review.comment}");
      final avaliacaoDto = {
        'psicologo': {
          'id': review.psicologoId
        },
        'paciente': {
          'id': pacienteId
        },
        'nota': review.rating,
        'comentario': review.comment,
      };
      print('[ReviewDataSource] Sending avaliacaoDto to API: $avaliacaoDto');

      final response = await _http.post(
        '$baseUrl/avaliacoes',
        avaliacaoDto,
      );
      
      print('[ReviewDataSource] Add review API response status: ${response.statusCode}');
      print('[ReviewDataSource] Add review API response body: ${response.body}');
      if (response.statusCode != 201 && response.statusCode != 200) {
        final errorMessage = response.body['mensagem'] ?? 'Falha ao adicionar avaliação';
        print('[ReviewDataSource] Failed to add review: $errorMessage');
        throw Exception(errorMessage);
      }
      print('[ReviewDataSource] Review added successfully');
    } catch (e) {
      print('[ReviewDataSource] Exception in addReview: $e');
      throw Exception('Erro de conexão: $e');
    }
  }

  Future<void> deleteReview(String reviewId) async {
    print('[ReviewDataSource] deleteReview called with reviewId: $reviewId');
    try {
      final pacienteId = await _getPacienteId();
      if (pacienteId.isEmpty) {
        print('[ReviewDataSource] Cannot delete review - pacienteId is empty');
        throw Exception('ID do paciente não encontrado');
      }
      
      print('[ReviewDataSource] Making DELETE request to: $baseUrl/avaliacoes/$reviewId');
      final response = await _http.delete('$baseUrl/avaliacoes/$reviewId');
      
      print('[ReviewDataSource] Delete review API response status: ${response.statusCode}');
      print('[ReviewDataSource] Delete review API response body: ${response.body}');
      if (response.statusCode != 200 && response.statusCode != 204) {
        final errorMessage = response.body != null && response.body is Map ? 
            response.body['mensagem'] ?? 'Falha ao excluir avaliação' : 
            'Falha ao excluir avaliação';
        print('[ReviewDataSource] Failed to delete review: $errorMessage');
        throw Exception(errorMessage);
      }
      print('[ReviewDataSource] Review deleted successfully');
    } catch (e) {
      print('[ReviewDataSource] Exception in deleteReview: $e');
      throw Exception('Erro de conexão: $e');
    }
  }
}
