import '../../domain/entities/document_model.dart';
import '../datasource/documents_datasource.dart';

class DocumentRepository {
  final DocumentsDataSource _dataSource;

  DocumentRepository(this._dataSource);

  Future<List<DocumentModel>> getDocuments() async {
    try {
      final response = await _dataSource.getDocuments();
      final List<dynamic> jsonList = response.body;
      return jsonList.map((json) => DocumentModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erro ao buscar documentos: $e');
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
      return DocumentModel.fromJson(response.body);
    } catch (e) {
      throw Exception('Erro ao fazer upload do documento: $e');
    }
  }

  Future<void> deleteDocument(String documentId) async {
    try {
      await _dataSource.deleteDocument(documentId);
    } catch (e) {
      throw Exception('Erro ao deletar documento: $e');
    }
  }

  Future<DocumentModel> updateDocument(DocumentModel document) async {
    try {
      final response = await _dataSource.updateDocument(
        document.id!,
        document.toJson(),
      );
      return DocumentModel.fromJson(response.body);
    } catch (e) {
      throw Exception('Erro ao atualizar documento: $e');
    }
  }

  Future<void> toggleFavorite(String documentId) async {
    try {
      final response = await _dataSource.toggleFavorite(documentId);
      if (response.statusCode != 200) {
        throw Exception('Falha ao atualizar favorito: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao atualizar favorito: $e');
    }
  }
}