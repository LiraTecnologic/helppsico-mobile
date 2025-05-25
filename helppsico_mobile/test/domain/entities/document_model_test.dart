import 'package:flutter_test/flutter_test.dart';
import 'package:helppsico_mobile/domain/entities/document_model.dart';

void main() {
  final tDateTime = DateTime.now();
  final tDocumentModel = DocumentModel(
    id: '1',
    title: 'Test Document',
    description: 'This is a test document.',
    date: tDateTime,
    fileSize: '1.5MB',
    fileType: 'PDF',
    type: DocumentType.RELATORIO_PSICOLOGICO,
    isFavorite: true,
    patientId: 'patient123',
    patientName: 'John Doe',
    fileUrl: 'http://example.com/doc.pdf',
  );
}