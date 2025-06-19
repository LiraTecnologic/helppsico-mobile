import 'package:flutter_test/flutter_test.dart';
import 'package:helppsico_mobile/domain/entities/document_model.dart';

void main() {
  group('DocumentType Tests', () {
    test('should have all expected document types', () {
      expect(DocumentType.values.length, 5);
      expect(DocumentType.values, contains(DocumentType.ATESTADO));
      expect(DocumentType.values, contains(DocumentType.DECLARACAO));
      expect(DocumentType.values, contains(DocumentType.RELATORIO_PSICOLOGICO));
      expect(DocumentType.values, contains(DocumentType.LAUDO_PSICOLOGICO));
      expect(DocumentType.values, contains(DocumentType.PARECER_PSICOLOGICO));
    });
  });

  group('DocumentModel Tests', () {
    late Map<String, dynamic> validDocumentJson;
    late Map<String, dynamic> documentJsonWithPatient;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime.parse('2024-01-15T10:00:00.000Z');
      
      validDocumentJson = {
        'id': 'doc123',
        'finalidade': 'Atestado Médico',
        'descricao': 'Atestado para justificar ausência',
        'dataEmissao': '2024-01-15T10:00:00.000Z',
      };

      documentJsonWithPatient = {
        ...validDocumentJson,
        'paciente': {
          'id': 'pac456',
          'nome': 'João Silva',
        },
      };
    });

    test('should create DocumentModel instance with all fields', () {
      final document = DocumentModel(
        id: 'doc123',
        title: 'Atestado Médico',
        description: 'Atestado para justificar ausência',
        date: testDate,
        fileSize: '1.2 MB',
        fileType: 'PDF',
        type: DocumentType.ATESTADO,
        isFavorite: true,
        patientId: 'pac456',
        patientName: 'João Silva',
        fileUrl: 'https://example.com/document.pdf',
      );

      expect(document.id, 'doc123');
      expect(document.title, 'Atestado Médico');
      expect(document.description, 'Atestado para justificar ausência');
      expect(document.date, testDate);
      expect(document.fileSize, '1.2 MB');
      expect(document.fileType, 'PDF');
      expect(document.type, DocumentType.ATESTADO);
      expect(document.isFavorite, true);
      expect(document.patientId, 'pac456');
      expect(document.patientName, 'João Silva');
      expect(document.fileUrl, 'https://example.com/document.pdf');
    });

    test('should create DocumentModel with default isFavorite false', () {
      final document = DocumentModel(
        id: 'doc123',
        title: 'Atestado Médico',
        description: 'Atestado para justificar ausência',
        date: testDate,
        fileSize: '1.2 MB',
        fileType: 'PDF',
        type: DocumentType.ATESTADO,
        patientId: 'pac456',
        patientName: 'João Silva',
        fileUrl: 'https://example.com/document.pdf',
      );

      expect(document.isFavorite, false);
    });

    test('should create DocumentModel from valid JSON', () {
      final document = DocumentModel.fromJson(validDocumentJson);

      expect(document.id, 'doc123');
      expect(document.title, 'Atestado Médico');
      expect(document.description, 'Atestado para justificar ausência');
      expect(document.date, testDate);
      expect(document.fileSize, '');
      expect(document.fileType, '');
      expect(document.type, DocumentType.ATESTADO);
      expect(document.isFavorite, false);
      expect(document.patientId, '');
      expect(document.patientName, '');
      expect(document.fileUrl, '');
    });

    test('should create DocumentModel from JSON with patient info', () {
      final document = DocumentModel.fromJson(documentJsonWithPatient);

      expect(document.id, 'doc123');
      expect(document.title, 'Atestado Médico');
      expect(document.description, 'Atestado para justificar ausência');
      expect(document.date, testDate);
      expect(document.patientId, 'pac456');
      expect(document.patientName, 'João Silva');
    });

    test('should create DocumentModel from JSON with isFavorite parameter', () {
      final document = DocumentModel.fromJson(validDocumentJson, isFavorite: true);
      expect(document.isFavorite, true);
    });

    test('should handle missing fields in JSON', () {
      final incompleteJson = {
        'id': null,
        'finalidade': null,
        'descricao': null,
        'dataEmissao': null,
      };

      final document = DocumentModel.fromJson(incompleteJson);

      expect(document.id, '');
      expect(document.title, '');
      expect(document.description, '');
      expect(document.date, isA<DateTime>());
      expect(document.fileSize, '');
      expect(document.fileType, '');
      expect(document.type, DocumentType.ATESTADO);
      expect(document.isFavorite, false);
      expect(document.patientId, '');
      expect(document.patientName, '');
      expect(document.fileUrl, '');
    });

    test('should handle invalid date in JSON', () {
      final jsonWithInvalidDate = {
        ...validDocumentJson,
        'dataEmissao': 'invalid-date',
      };

      final document = DocumentModel.fromJson(jsonWithInvalidDate);
      expect(document.date, isA<DateTime>());
    });

    test('should map document types correctly', () {
      final testCases = [
        {'finalidade': 'Atestado', 'expected': DocumentType.ATESTADO},
        {'finalidade': 'Declaração', 'expected': DocumentType.DECLARACAO},
        {'finalidade': 'Relatório Psicológico', 'expected': DocumentType.RELATORIO_PSICOLOGICO},
        {'finalidade': 'Laudo Psicológico', 'expected': DocumentType.LAUDO_PSICOLOGICO},
        {'finalidade': 'Parecer Psicológico', 'expected': DocumentType.PARECER_PSICOLOGICO},
        {'finalidade': 'Unknown Type', 'expected': DocumentType.ATESTADO}, // default
      ];

      for (final testCase in testCases) {
        final json = {
          ...validDocumentJson,
          'finalidade': testCase['finalidade'],
        };
        final document = DocumentModel.fromJson(json);
        expect(document.type, testCase['expected']);
      }
    });

    test('should toggle isFavorite correctly', () {
      final document = DocumentModel(
        id: 'doc123',
        title: 'Atestado Médico',
        description: 'Atestado para justificar ausência',
        date: testDate,
        fileSize: '1.2 MB',
        fileType: 'PDF',
        type: DocumentType.ATESTADO,
        isFavorite: false,
        patientId: 'pac456',
        patientName: 'João Silva',
        fileUrl: 'https://example.com/document.pdf',
      );

      expect(document.isFavorite, false);
      
      document.isFavorite = true;
      expect(document.isFavorite, true);
      
      document.isFavorite = false;
      expect(document.isFavorite, false);
    });

    test('should convert DocumentModel to JSON correctly', () {
      final document = DocumentModel(
        id: 'doc123',
        title: 'Atestado Médico',
        description: 'Atestado para justificar ausência',
        date: testDate,
        fileSize: '1.2 MB',
        fileType: 'PDF',
        type: DocumentType.ATESTADO,
        isFavorite: true,
        patientId: 'pac456',
        patientName: 'João Silva',
        fileUrl: 'https://example.com/document.pdf',
      );

      final json = document.toJson();

      expect(json['id'], 'doc123');
      expect(json['title'], 'Atestado Médico');
      expect(json['description'], 'Atestado para justificar ausência');
      expect(json['date'], testDate.toIso8601String());
      expect(json['fileSize'], '1.2 MB');
      expect(json['fileType'], 'PDF');
      expect(json['type'], 'ATESTADO');
      expect(json['isFavorite'], true);
      expect(json['patientId'], 'pac456');
      expect(json['patientName'], 'João Silva');
      expect(json['fileUrl'], 'https://example.com/document.pdf');
    });

    test('should handle empty patient object in JSON', () {
      final jsonWithEmptyPatient = {
        ...validDocumentJson,
        'paciente': {},
      };

      final document = DocumentModel.fromJson(jsonWithEmptyPatient);
      expect(document.patientId, '');
      expect(document.patientName, '');
    });

    test('should handle null patient object in JSON', () {
      final jsonWithNullPatient = {
        ...validDocumentJson,
        'paciente': null,
      };

      final document = DocumentModel.fromJson(jsonWithNullPatient);
      expect(document.patientId, '');
      expect(document.patientName, '');
    });

    test('should convert to JSON and back correctly', () {
      final originalDocument = DocumentModel(
        id: 'doc123',
        title: 'Atestado Médico',
        description: 'Atestado para justificar ausência',
        date: testDate,
        fileSize: '1.2 MB',
        fileType: 'PDF',
        type: DocumentType.DECLARACAO,
        isFavorite: true,
        patientId: 'pac456',
        patientName: 'João Silva',
        fileUrl: 'https://example.com/document.pdf',
      );

      final json = originalDocument.toJson();
      
      // Simular o processo de fromJson com os dados do toJson
      final recreatedJson = {
        'id': json['id'],
        'finalidade': json['title'], // fromJson usa 'finalidade' para title
        'descricao': json['description'],
        'dataEmissao': json['date'],
        'paciente': {
          'id': json['patientId'],
          'nome': json['patientName'],
        },
      };
      
      final recreatedDocument = DocumentModel.fromJson(recreatedJson, isFavorite: json['isFavorite']);

      expect(recreatedDocument.id, originalDocument.id);
      expect(recreatedDocument.title, originalDocument.title);
      expect(recreatedDocument.description, originalDocument.description);
      expect(recreatedDocument.date, originalDocument.date);
      expect(recreatedDocument.isFavorite, originalDocument.isFavorite);
      expect(recreatedDocument.patientId, originalDocument.patientId);
      expect(recreatedDocument.patientName, originalDocument.patientName);
    });
  });
}