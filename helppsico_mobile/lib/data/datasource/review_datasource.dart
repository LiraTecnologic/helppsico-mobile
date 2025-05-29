
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
  
  ReviewDataSource(this._http, this._secureStorage, this._authService);


  Future<String> _getPacienteId() async {
    try {
      
      final userId = await _secureStorage.getUserId();
      if (userId != null && userId.isNotEmpty) {
        return userId;
      }
      
      
      final userInfo = await _authService.getUserInfo();
      return userInfo?['id'] ?? '';
    } catch (e) {
      print('Erro ao obter ID do paciente: $e');
      return '';
    }
  }

  /// Obtém o ID do psicólogo vinculado ao paciente
  Future<String> _getPsicologoId() async {
    try {
      final pacienteId = await _getPacienteId();
      if (pacienteId.isEmpty) {
        throw Exception('ID do paciente não encontrado');
      }
      
      // Na implementação real, deveria buscar o vínculo do paciente para obter o ID do psicólogo
      // Endpoint: /vinculos/paciente/{id}
      final response = await _http.get('$baseUrl/vinculos/paciente/$pacienteId');
      
      if (response.statusCode == 200) {
        final responseData = response.body;
        if (responseData != null && responseData.containsKey('dado')) {
          final vinculoDto = responseData['dado'];
          return vinculoDto['idPsicologo'] ?? '';
        }
      }
      
      // Caso não encontre o vínculo, retorna vazio
      return '';
    } catch (e) {
      print('Erro ao obter ID do psicólogo: $e');
      return '';
    }
  }
  
  Future<List<ReviewEntity>> getReviewsByPsicologoId(String psicologoId) async {
    try {
      final response = await _http.get('$baseUrl/avaliacoes/psicologo/$psicologoId');
      
      if (response.statusCode == 200) {
        // A API Java encapsula as respostas em um objeto ResponseDto<T> com o dado principal no campo 'dado'
        final responseData = response.body;
        if (responseData == null || !responseData.containsKey('dado')) {
          throw Exception('Formato de resposta inválido');
        }
        
        // A API retorna uma página de avaliações
        final avaliacoesPage = responseData['dado'];
        final List<dynamic> avaliacoes = avaliacoesPage['content'] ?? [];
        
        // Converte cada avaliação para o modelo ReviewEntity
        return avaliacoes.map((json) => _adaptAvaliacaoToReviewEntity(json)).toList();
      } else {
        final errorMessage = response.body['mensagem'] ?? 'Falha ao carregar avaliações';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Erro ao buscar avaliações: $e');
      throw Exception('Erro de conexão: $e');
    }
  }
  
  /// Adapta o formato da AvaliacaoDto da API Java para o formato esperado pelo ReviewEntity
  ReviewEntity _adaptAvaliacaoToReviewEntity(Map<String, dynamic> avaliacaoDto) {
    return ReviewEntity(
      id: avaliacaoDto['id']?.toString() ?? '',
      psicologoId: avaliacaoDto['idPsicologo']?.toString() ?? '',
      userName: avaliacaoDto['nomePaciente'] ?? '',
      rating: avaliacaoDto['nota'] ?? 0,
      comment: avaliacaoDto['comentario'] ?? '',
      date: avaliacaoDto['dataCriacao'] != null ? 
          DateTime.parse(avaliacaoDto['dataCriacao']) : 
          DateTime.now(),
    );
  }


  Future<void> addReview(ReviewEntity review) async {
    try {
      final pacienteId = await _getPacienteId();
      if (pacienteId.isEmpty) {
        throw Exception('ID do paciente não encontrado');
      }
      
      // Adapta o formato para o esperado pela API Java
      final avaliacaoDto = {
        'idPsicologo': review.psicologoId,
        'idPaciente': pacienteId,
        'nota': review.rating,
        'comentario': review.comment,
      };

      final response = await _http.post(
        '$baseUrl/avaliacoes',
        avaliacaoDto,
      );
      
      if (response.statusCode != 201 && response.statusCode != 200) {
        final errorMessage = response.body['mensagem'] ?? 'Falha ao adicionar avaliação';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Erro ao adicionar avaliação: $e');
      throw Exception('Erro de conexão: $e');
    }
  }


  Future<void> deleteReview(String reviewId) async {
    try {
      final pacienteId = await _getPacienteId();
      if (pacienteId.isEmpty) {
        throw Exception('ID do paciente não encontrado');
      }
      
      final response = await _http.delete('$baseUrl/avaliacoes/$reviewId');
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        final errorMessage = response.body != null && response.body is Map ? 
            response.body['mensagem'] ?? 'Falha ao excluir avaliação' : 
            'Falha ao excluir avaliação';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Erro ao excluir avaliação: $e');
      throw Exception('Erro de conexão: $e');
    }
  }
}