import '../../domain/entities/document_model.dart';
import '../datasource/documents_datasource.dart';
import '../../core/services/storage/secure_storage_service.dart';

class DocumentRepository {
  final DocumentsDataSource _dataSource;
  final SecureStorageService _secureStorage;

  DocumentRepository(this._dataSource, this._secureStorage);

  Future<List<DocumentModel>> getDocuments() async {
    try {
      print('DocumentRepository.getDocuments(): Iniciando busca de documentos');
      final response = await _dataSource.getDocuments();
     
      if (response.body is! Map<String, dynamic>) {
        print('DocumentRepository.getDocuments(): Resposta inesperada, não é um Map: ${response.body.runtimeType}');
        throw Exception('Formato de resposta inesperado do servidor.');
      }

      final Map<String, dynamic> responseMap = response.body as Map<String, dynamic>;
      
  
      List<dynamic> rawList;
      if (responseMap.containsKey('dado') && responseMap['dado'] is Map<String, dynamic>) {
        final Map<String, dynamic> dado = responseMap['dado'] as Map<String, dynamic>;
        if (dado.containsKey('content') && dado['content'] is List) {
          rawList = dado['content'] as List<dynamic>;
          print('DocumentRepository.getDocuments(): Lista encontrada em dado.content');
        } else {
          print('DocumentRepository.getDocuments(): Nenhuma lista encontrada em dado.content: $dado');
          throw Exception('Lista de documentos não encontrada em dado.content');
        }
      } else {
        print('DocumentRepository.getDocuments(): Resposta não contém chave "dado" ou não é um Map: $responseMap');
        throw Exception('Formato de resposta do servidor não reconhecido');
      }

      print('DocumentRepository.getDocuments(): Processando ${rawList.length} documento(s)');

  
      final favoriteIds = await _secureStorage.getFavoriteDocumentIds();
      print('DocumentRepository.getDocuments(): ${favoriteIds.length} documentos favoritos encontrados localmente');

 
      final documents = await Future.wait(
        rawList.map((json) async {
          final doc = DocumentModel.fromJson(
            json as Map<String, dynamic>,
            isFavorite: favoriteIds.contains(json['id']),
          );
          return doc;
        }),
      );

      return documents;
    } catch (e) {
      print('DocumentRepository.getDocuments(): Erro: $e');
      throw Exception('Erro ao buscar documentos: $e');
    }
  }

  Future<void> toggleFavorite(String documentId) async {
    try {
      print('DocumentRepository.toggleFavorite(): Alternando favorito para documento $documentId');
      await _secureStorage.toggleFavoriteDocumentId(documentId);
      print('DocumentRepository.toggleFavorite(): Favorito alternado com sucesso');
    } catch (e) {
      print('DocumentRepository.toggleFavorite(): Erro: $e');
      throw Exception('Erro ao alternar favorito: $e');
    }
  }

  Future<bool> isFavorite(String documentId) async {
    try {
      return await _secureStorage.isDocumentFavorite(documentId);
    } catch (e) {
      print('DocumentRepository.isFavorite(): Erro: $e');
      return false;
    }
  }

  Future<DocumentModel> uploadDocument(DocumentModel document) async {
    try {
      final metadata = {
        'title': document.title,
        'description': document.description,
        'type': document.type.toString().split('.').last,
        'patientId': document.patientId,
        'patientName': document.patientName,
      };

      final response = await _dataSource.uploadDocument(document.fileUrl, metadata);
      // O documento retornado da API não terá status de favorito, então mantemos o status atual
      return DocumentModel.fromJson(
        response.body as Map<String, dynamic>,
        isFavorite: document.isFavorite,
      );
    } catch (e) {
      print('DocumentRepository.uploadDocument(): Erro: $e');
      throw Exception('Erro ao fazer upload do documento: $e');
    }
  }

  Future<void> deleteDocument(String documentId) async {
    try {
      print('DocumentRepository.deleteDocument(): Deletando documento $documentId');
      await _dataSource.deleteDocument(documentId);
      // Remover dos favoritos se estiver marcado
      await _secureStorage.removeFavoriteDocumentId(documentId);
      print('DocumentRepository.deleteDocument(): Documento deletado com sucesso');
    } catch (e) {
      print('DocumentRepository.deleteDocument(): Erro: $e');
      throw Exception('Erro ao deletar documento: $e');
    }
  }
}