import './models/document_model.dart';

class MockDocumentRepository {
  static List<DocumentModel> _documents = [
    DocumentModel(
      id: '1',
      title: 'Relatório Psicológico',
      description: 'Relatório detalhado do paciente',
      date: DateTime.now(),
      fileSize: '2.4 MB',
      fileType: 'PDF',
      type: DocumentType.RELATORIO_PSICOLOGICO,
      isFavorite: true,
      patientId: '1',
      patientName: 'João Silva',
      fileUrl: '',
    ),
    DocumentModel(
      id: '2',
      title: 'Laudo Psicológico',
      description: 'Laudo de avaliação psicológica',
      date: DateTime.now().subtract(const Duration(days: 1)),
      fileSize: '1.2 MB',
      fileType: 'DOC',
      type: DocumentType.LAUDO_PSICOLOGICO,
      isFavorite: false,
      patientId: '2',
      patientName: 'Maria Santos',
      fileUrl: '',
    ),
    DocumentModel(
      id: '3',
      title: 'Atestado',
      description: 'Atestado para afastamento',
      date: DateTime.now().subtract(const Duration(days: 2)),
      fileSize: '0.8 MB',
      fileType: 'PDF',
      type: DocumentType.ATESTADO,
      isFavorite: false,
      patientId: '1',
      patientName: 'João Silva',
      fileUrl: '',
    ),
  ];

  Future<List<DocumentModel>> getDocuments() async {
    
    await Future.delayed(const Duration(seconds: 1));
    return _documents;
  }

  Future<DocumentModel> uploadDocument(DocumentModel document) async {
    await Future.delayed(const Duration(seconds: 1));
    _documents.insert(0, document);
    return document;
  }

  Future<void> deleteDocument(String documentId) async {
    await Future.delayed(const Duration(seconds: 1));
    _documents.removeWhere((doc) => doc.id == documentId);
  }

  Future<DocumentModel> updateDocument(DocumentModel document) async {
    await Future.delayed(const Duration(seconds: 1));
    final index = _documents.indexWhere((doc) => doc.id == document.id);
    if (index != -1) {
      _documents[index] = document;
    }
    return document;
  }
}