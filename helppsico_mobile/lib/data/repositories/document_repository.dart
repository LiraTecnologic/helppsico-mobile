import '../../domain/entities/document_model.dart';
import '../datasource/documents_datasource.dart';

class DocumentRepository {
  final DocumentsDataSource _dataSource;

  DocumentRepository(this._dataSource);

  Future<List<DocumentModel>> getDocuments() async {
  try {
    print('DocumentRepository.getDocuments(): Entrando\n');
    final response = await _dataSource.getDocuments();

   
    final body = response.body as Map<String, dynamic>;
    print('DocumentRepository.getDocuments(): Response.body keys: ${body.keys}\n');

   
    final List<dynamic> rawList = body['content'] as List<dynamic>;

    print('DocumentRepository.getDocuments(): encontrou ${rawList.length} itens em dado.content\n');

    
    return rawList
        .map((json) => _adaptDocumentToDocumentModel(json as Map<String, dynamic>))
        .toList();
  } catch (e) {
    print('DocumentRepository.getDocuments(): Erro ao buscar documentos: $e');
    throw Exception('Erro ao buscar documentos: $e');
  }
}
  
  DocumentModel _adaptDocumentToDocumentModel(Map<String, dynamic> dto) {
  DocumentType _mapDocumentType(String finalidade) {
    switch (finalidade.toUpperCase()) {
      case 'LAUDO':
        return DocumentType.LAUDO_PSICOLOGICO;
      case 'RECEITA':
        return DocumentType.DECLARACAO;
      case 'ATESTADO':
        return DocumentType.ATESTADO;
      case 'EXAME':
        return DocumentType.RELATORIO_PSICOLOGICO;
      default:
        return DocumentType.PARECER_PSICOLOGICO;
    }
  }

  // Pega o paciente aninhado
  final paciente = dto['paciente'] as Map<String, dynamic>?;

  // Usa dataEmissao como data “principal”
  final rawDate = dto['dataEmissao'] as String? ?? DateTime.now().toIso8601String();
  final parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();

  return DocumentModel(
    id: dto['id'] as String? ?? '',
    title: dto['finalidade'] as String? ?? '',           // ex: “string” no seu JSON
    description: dto['descricao'] as String? ?? '',
    date: parsedDate,
    fileSize: '',                                        // não vem no JSON
    fileType: '',                                        // não vem no JSON
    type: _mapDocumentType(dto['finalidade'] as String? ?? ''),
    isFavorite: false,                                   // não há no JSON
    patientId: paciente?['id'] as String? ?? '',
    patientName: paciente?['nome'] as String? ?? '',
    fileUrl: '',                                         // não vem no JSON
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
      return _adaptDocumentToDocumentModel(response.body);
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
      return _adaptDocumentToDocumentModel(response.body);
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