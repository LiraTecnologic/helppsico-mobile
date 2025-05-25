import 'package:flutter_test/flutter_test.dart';
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';
import 'package:helppsico_mobile/data/datasource/documents_datasource.dart';
import 'package:helppsico_mobile/data/repositories/document_repository.dart';
import 'package:helppsico_mobile/domain/entities/document_model.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'document_repository_test.mocks.dart';

@GenerateMocks([DocumentsDataSource])
void main() {
  late MockDocumentsDataSource mockDataSource;
  late DocumentRepository repository;

  setUp(() {
    mockDataSource = MockDocumentsDataSource();
    repository = DocumentRepository(mockDataSource);
  });

  final tDocumentModel = DocumentModel(
    id: '1',
    title: 'Test Document',
    description: 'Test Description',
    date: DateTime.now(),
    fileSize: '1MB',
    fileType: 'pdf',
    type: DocumentType.RELATORIO_PSICOLOGICO,
    isFavorite: false,
    patientId: 'p1',
    patientName: 'Patient Name',
    fileUrl: '/path/to/file.pdf',
  );

  final tDocumentJson = {
    'id': '1',
    'title': 'Test Document',
    'description': 'Test Description',
    'date': tDocumentModel.date.toIso8601String(),
    'fileSize': '1MB',
    'fileType': 'pdf',
    'type': 'RELATORIO_PSICOLOGICO',
    'isFavorite': false,
    'patientId': 'p1',
    'patientName': 'Patient Name',
    'fileUrl': '/path/to/file.pdf',
  };

  final tHttpResponse = HttpResponse(statusCode: 200, body: [tDocumentJson]);
  final tSingleHttpResponse = HttpResponse(statusCode: 200, body: tDocumentJson);
  final tUploadHttpResponse = HttpResponse(statusCode: 201, body: tDocumentJson);

  group('getDocuments', () {
    test('should return a list of DocumentModel when the call to datasource is successful', () async {

      when(mockDataSource.getDocuments()).thenAnswer((_) async => tHttpResponse);

      final result = await repository.getDocuments();

      expect(result, isA<List<DocumentModel>>());
      expect(result.length, 1);
      expect(result.first.id, tDocumentModel.id);
      verify(mockDataSource.getDocuments()).called(1);
    });

    test('should throw an exception when the call to datasource is unsuccessful', () async {

      when(mockDataSource.getDocuments()).thenThrow(Exception('DataSource Error'));

      expect(() => repository.getDocuments(), throwsA(isA<Exception>()));
      verify(mockDataSource.getDocuments()).called(1);
    });
  });

  group('uploadDocument', () {
    test('should return a DocumentModel when the call to datasource is successful', () async {

      final metadata = {
        'title': tDocumentModel.title,
        'description': tDocumentModel.description,
        'type': tDocumentModel.type.toString().split('.').last,
        'patientId': tDocumentModel.patientId,
        'patientName': tDocumentModel.patientName,
      };
      when(mockDataSource.uploadDocument(tDocumentModel.fileUrl, metadata))
          .thenAnswer((_) async => tUploadHttpResponse);

      final result = await repository.uploadDocument(tDocumentModel);
      // Assert
      expect(result, isA<DocumentModel>());
      expect(result.id, tDocumentModel.id);
      verify(mockDataSource.uploadDocument(tDocumentModel.fileUrl, metadata)).called(1);
    });

    test('should throw an exception when the call to datasource is unsuccessful', () async {
      // Arrange
      final metadata = {
        'title': tDocumentModel.title,
        'description': tDocumentModel.description,
        'type': tDocumentModel.type.toString().split('.').last,
        'patientId': tDocumentModel.patientId,
        'patientName': tDocumentModel.patientName,
      };
      when(mockDataSource.uploadDocument(tDocumentModel.fileUrl, metadata))
          .thenThrow(Exception('DataSource Error'));

      expect(() => repository.uploadDocument(tDocumentModel), throwsA(isA<Exception>()));
      verify(mockDataSource.uploadDocument(tDocumentModel.fileUrl, metadata)).called(1);
    });
  });

  group('deleteDocument', () {
    const documentId = '1';
    test('should complete successfully when the call to datasource is successful', () async {

      when(mockDataSource.deleteDocument(documentId)).thenAnswer((_) async => HttpResponse(statusCode: 204, body: null));
 
      await repository.deleteDocument(documentId);

      verify(mockDataSource.deleteDocument(documentId)).called(1);
    });

    test('should throw an exception when the call to datasource is unsuccessful', () async {

      when(mockDataSource.deleteDocument(documentId)).thenThrow(Exception('DataSource Error'));
    
      expect(() => repository.deleteDocument(documentId), throwsA(isA<Exception>()));
      verify(mockDataSource.deleteDocument(documentId)).called(1);
    });
  });

  group('updateDocument', () {
    test('should return a DocumentModel when the call to datasource is successful', () async {
 
      when(mockDataSource.updateDocument(tDocumentModel.id!, tDocumentModel.toJson()))
          .thenAnswer((_) async => tSingleHttpResponse);
 
      final result = await repository.updateDocument(tDocumentModel);
 
      expect(result, isA<DocumentModel>());
      expect(result.id, tDocumentModel.id);
      verify(mockDataSource.updateDocument(tDocumentModel.id!, tDocumentModel.toJson())).called(1);
    });

    test('should throw an exception when the call to datasource is unsuccessful', () async {

      when(mockDataSource.updateDocument(tDocumentModel.id!, tDocumentModel.toJson()))
          .thenThrow(Exception('DataSource Error'));
      
      expect(() => repository.updateDocument(tDocumentModel), throwsA(isA<Exception>()));
      verify(mockDataSource.updateDocument(tDocumentModel.id!, tDocumentModel.toJson())).called(1);
    });
  });

  group('toggleFavorite', () {
    const documentId = '1';
    test('should complete successfully when the call to datasource is successful and returns 200', () async {
      when(mockDataSource.toggleFavorite(documentId))
          .thenAnswer((_) async => HttpResponse(statusCode: 200, body: {'isFavorite': true}));
      await repository.toggleFavorite(documentId);
      verify(mockDataSource.toggleFavorite(documentId)).called(1);
    });

    test('should throw an exception when the call to datasource returns non-200 status', () async {
      
      when(mockDataSource.toggleFavorite(documentId))
          .thenAnswer((_) async => HttpResponse(statusCode: 400, body: null));
   
      expect(() => repository.toggleFavorite(documentId), throwsA(isA<Exception>()));
      verify(mockDataSource.toggleFavorite(documentId)).called(1);
    });

    test('should throw an exception when the call to datasource throws an error', () async {
   
      when(mockDataSource.toggleFavorite(documentId)).thenThrow(Exception('DataSource Error'));
      
      expect(() => repository.toggleFavorite(documentId), throwsA(isA<Exception>()));
      verify(mockDataSource.toggleFavorite(documentId)).called(1);
    });
  });
}