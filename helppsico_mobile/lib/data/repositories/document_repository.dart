import '../../domain/entities/document_model.dart';
import '../datasource/documents_datasource.dart';
import '../../core/services/storage/secure_storage_service.dart';

class DocumentRepository {
  final DocumentsDataSource _dataSource;
  final SecureStorageService _secureStorage;

  DocumentRepository(this._dataSource, this._secureStorage);

  Future<List<DocumentModel>> getDocuments() async {
    try {
      final response = await _dataSource.getDocuments();
      if (response.body is! Map<String, dynamic>) {
        throw Exception('Formato de resposta inesperado do servidor.');
      }
      final Map<String, dynamic> responseMap = response.body as Map<String, dynamic>;
      List<dynamic> rawList;
      if (responseMap.containsKey('dado') && responseMap['dado'] is Map<String, dynamic>) {
        final Map<String, dynamic> dado = responseMap['dado'] as Map<String, dynamic>;
        if (dado.containsKey('content') && dado['content'] is List) {
          rawList = dado['content'] as List<dynamic>;
        } else {
          throw Exception('Lista de documentos não encontrada em dado.content');
        }
      } else {
        throw Exception('Formato de resposta do servidor não reconhecido');
      }
      final favoriteIds = await _secureStorage.getFavoriteDocumentIds();
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
      throw Exception('Erro ao buscar documentos: $e');
    }
  }

  Future<void> toggleFavorite(String documentId) async {
    try {
      await _secureStorage.toggleFavoriteDocumentId(documentId);
    } catch (e) {
      throw Exception('Erro ao alternar favorito: $e');
    }
  }

  Future<bool> isFavorite(String documentId) async {
    try {
      return await _secureStorage.isDocumentFavorite(documentId);
    } catch (e) {
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
      return DocumentModel.fromJson(
        response.body as Map<String, dynamic>,
        isFavorite: document.isFavorite,
      );
    } catch (e) {
      throw Exception('Erro ao fazer upload do documento: $e');
    }
  }

  Future<void> deleteDocument(String documentId) async {
    try {
      await _dataSource.deleteDocument(documentId);
      await _secureStorage.removeFavoriteDocumentId(documentId);
    } catch (e) {
      throw Exception('Erro ao deletar documento: $e');
    }
  }
}