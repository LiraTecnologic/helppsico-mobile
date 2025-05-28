import '../../domain/entities/document_model.dart';
import '../datasource/documents_datasource.dart';

class DocumentRepository {
  final DocumentsDataSource _dataSource;

  DocumentRepository(this._dataSource);

  Future<List<DocumentModel>> getDocuments() async {
    try {
      final response = await _dataSource.getDocuments();
      
      // Verifica se a resposta é uma lista ou um objeto paginado
      if (response.body is List) {
        final List<dynamic> jsonList = response.body;
        return jsonList.map((json) => _adaptSolicitacaoToDocumentModel(json)).toList();
      } else if (response.body is Map && response.body.containsKey('content')) {
        // Resposta paginada da API Java
        final List<dynamic> jsonList = response.body['content'] ?? [];
        return jsonList.map((json) => _adaptSolicitacaoToDocumentModel(json)).toList();
      } else {
        // Caso a resposta não seja nem lista nem objeto paginado
        return [];
      }
    } catch (e) {
      print('Erro ao buscar documentos: $e');
      throw Exception('Erro ao buscar documentos: $e');
    }
  }
  
  /// Adapta o formato da SolicitacaoDocumentoDto da API Java para o formato esperado pelo DocumentModel
  DocumentModel _adaptSolicitacaoToDocumentModel(Map<String, dynamic> solicitacaoDto) {
    // Mapeia o tipo de documento da API Java para o enum DocumentType
    DocumentType _mapDocumentType(String? tipo) {
      if (tipo == null) return DocumentType.other;
      
      switch (tipo.toUpperCase()) {
        case 'LAUDO':
          return DocumentType.report;
        case 'RECEITA':
          return DocumentType.prescription;
        case 'ATESTADO':
          return DocumentType.certificate;
        case 'EXAME':
          return DocumentType.exam;
        default:
          return DocumentType.other;
      }
    }
    
    return DocumentModel(
      id: solicitacaoDto['id']?.toString() ?? '',
      title: solicitacaoDto['titulo'] ?? '',
      description: solicitacaoDto['descricao'] ?? '',
      date: solicitacaoDto['dataCriacao'] ?? DateTime.now().toIso8601String(),
      fileSize: solicitacaoDto['tamanhoArquivo']?.toString() ?? '0',
      fileType: solicitacaoDto['tipoArquivo'] ?? '',
      type: _mapDocumentType(solicitacaoDto['tipo']),
      isFavorite: solicitacaoDto['favorito'] ?? false,
      patientId: solicitacaoDto['idPaciente']?.toString() ?? '',
      patientName: solicitacaoDto['nomePaciente'] ?? '',
      fileUrl: solicitacaoDto['urlArquivo'] ?? '',
    );
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
      return _adaptSolicitacaoToDocumentModel(response.body);
    } catch (e) {
      print('Erro ao fazer upload do documento: $e');
      throw Exception('Erro ao fazer upload do documento: $e');
    }
  }

  Future<void> deleteDocument(String documentId) async {
    print('Attempting to delete document with id: $documentId');
    try {
      await _dataSource.deleteDocument(documentId);
      print('Successfully deleted document with id: $documentId');
    } catch (e) {
      print('Error when attempting to delete document with id: $documentId: $e');
      throw Exception('Erro ao deletar documento: $e');
    }
  }

  Future<DocumentModel> updateDocument(DocumentModel document) async {
    try {
      final response = await _dataSource.updateDocument(
        document.id!,
        document.toJson(),
      );
      return _adaptSolicitacaoToDocumentModel(response.body);
    } catch (e) {
      print('Erro ao atualizar documento: $e');
      throw Exception('Erro ao atualizar documento: $e');
    }
  }

  Future<void> toggleFavorite(String documentId) async {
    try {
      print('Attempting to toggle favorite for document with id: $documentId');
      final response = await _dataSource.toggleFavorite(documentId);
      if (response.statusCode != 200) {
        print(
            'Error when attempting to toggle favorite for document with id: $documentId: ${response.statusCode}');
        throw Exception('Falha ao atualizar favorito: ${response.statusCode}');
      } else {
        print('Successfully toggled favorite for document with id: $documentId');
      }
    } catch (e) {
      print('Error when attempting to toggle favorite for document with id: $documentId: $e');
      throw Exception('Erro ao atualizar favorito: $e');
    }
  }
}