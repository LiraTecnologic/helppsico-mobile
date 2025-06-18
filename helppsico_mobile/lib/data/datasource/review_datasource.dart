
import '../../domain/entities/review_entity.dart';
import '../../core/services/http/generic_http_service.dart';
import '../../core/services/auth/auth_service.dart';
import '../../core/services/storage/secure_storage_service.dart';

class ReviewDataSource {
  String get baseUrl => 'http://10.0.2.2:8080';

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
      final id = userInfo?['id'] ?? '';
      return id;
    } catch (e) {
      return '';
    }
  }

  Future<Map<String, String>?> _extractPsicologoInfoFromVinculo(dynamic responseData) {
    if (responseData != null &&
        responseData.containsKey('dado') &&
        responseData['dado'] != null &&
        responseData['dado'].containsKey('content') &&
        responseData['dado']['content'] is List &&
        (responseData['dado']['content'] as List).isNotEmpty) {
      final vinculo = responseData['dado']['content'][0];
      if (vinculo != null && vinculo['psicologo'] != null) {
        final psicologoData = vinculo['psicologo'];
        if (psicologoData['id'] != null && psicologoData['nome'] != null) {
          return Future.value({
            'id': psicologoData['id'].toString(),
            'nome': psicologoData['nome'].toString(),
          });
        }
      }
    }
    return Future.value(null);
  }

  Future<Map<String, String>?> _getPsicologoInfo() async {
    try {
      final pacienteId = await _getPacienteId();
      if (pacienteId.isEmpty) {
        return null;
      }
      final response = await _http.get('$baseUrl/vinculos/listar/paciente/$pacienteId');
      if (response.statusCode == 200) {
        return await _extractPsicologoInfoFromVinculo(response.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, String>?> getPsicologoInfo() async {
    return await _getPsicologoInfo();
  }

  List<ReviewEntity> _mapAvaliacoesToEntities(List<dynamic> avaliacoes) {
    return avaliacoes.map((json) => _adaptAvaliacaoToReviewEntity(json)).toList();
  }

  Future<List<ReviewEntity>> getReviewsByPsicologoId(String psicologoId) async {
    try {
      final response = await _http.get('$baseUrl/avaliacoes/psicologo/$psicologoId');
      if (response.statusCode == 200) {
        final responseData = response.body;
        if (responseData == null || !responseData.containsKey('dado')) {
          throw Exception('Formato de resposta inválido');
        }
        final avaliacoesPage = responseData['dado'];
        final List<dynamic> avaliacoes = avaliacoesPage['content'] ?? [];
        return _mapAvaliacoesToEntities(avaliacoes);
      } else {
        final errorMessage = response.body['mensagem'] ?? 'Falha ao carregar avaliações';
        throw Exception('Erro ao buscar avaliações: $errorMessage');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  ReviewEntity _adaptAvaliacaoToReviewEntity(Map<String, dynamic> dto) {
    final psicologo = dto['psicologo'] as Map<String, dynamic>? ?? {};
    final psicologoId = psicologo['id']?.toString() ?? '';
    final paciente = dto['paciente'] as Map<String, dynamic>? ?? {};
    final pacienteId = paciente['id']?.toString() ?? '';
    final pacienteNome = paciente['nome']?.toString() ?? '';
    final rating = (dto['nota'] is num) ? (dto['nota'] as num).toInt() : 0;
    final comment = dto['comentario']?.toString() ?? '';
    DateTime date;
    if (dto.containsKey('dataCriacao') && dto['dataCriacao'] != null) {
      date = DateTime.parse(dto['dataCriacao']);
    } else {
      date = DateTime.now();
    }
    return ReviewEntity(
      id: dto['id']?.toString() ?? '',
      psicologoId: psicologoId,
      pacienteId: pacienteId,
      userName: pacienteNome,
      rating: rating,
      comment: comment,
      date: date,
    );
  }

  Future<void> addReview(ReviewEntity review) async {
    try {
      final pacienteId = await _getPacienteId();
      if (pacienteId.isEmpty) {
        throw Exception('ID do paciente não encontrado');
      }
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
      final response = await _http.post(
        '$baseUrl/avaliacoes',
        avaliacaoDto,
      );
      if (response.statusCode != 201 && response.statusCode != 200) {
        final errorMessage = response.body['mensagem'] ?? 'Falha ao adicionar avaliação';
        throw Exception(errorMessage);
      }
    } catch (e) {
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
      throw Exception('Erro de conexão: $e');
    }
  }
}
