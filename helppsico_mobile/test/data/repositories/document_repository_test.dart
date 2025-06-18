import 'package:flutter_test/flutter_test.dart';
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';
import 'package:helppsico_mobile/core/services/storage/secure_storage_service.dart';
import 'package:helppsico_mobile/data/repositories/document_repository.dart';
import 'package:helppsico_mobile/domain/entities/document_model.dart';
import 'package:helppsico_mobile/data/datasource/documents_datasource.dart';


// Mock classes
class MockDocumentsDataSource implements DocumentsDataSource {
  final Map<String, List<Map<String, dynamic>>> _documents = {};
  
  void setDocuments(List<Map<String, dynamic>> documents) {
    _documents['test'] = documents;
  }
  
  @override
  String get baseUrl => 'http://test.com';

  @override
  Future<HttpResponse> getDocuments() async {
    return HttpResponse(
      body: {'dado': {'content': _documents['test'] ?? []}},
      statusCode: 200,
    );
  }

  @override
  Future<HttpResponse> deleteDocument(String documentId) async {
    _documents['test']?.removeWhere((doc) => doc['id'] == documentId);
    return HttpResponse(body: null, statusCode: 204);
  }

  @override
  Future<HttpResponse> uploadDocument(String filePath, Map<String, dynamic> metadata) async {
    final document = {
      'id': 'doc${DateTime.now().millisecondsSinceEpoch}',
      'finalidade': metadata['type'],
      'descricao': metadata['description'],
      'dataEmissao': DateTime.now().toIso8601String(),
    };
    _documents['test']?.add(document);
    return HttpResponse(body: document, statusCode: 201);
  }
}

class MockSecureStorageService implements SecureStorageService {
  String? _mockUserId;
  String? _mockFavoriteDocuments;
  
  void setMockUserId(String? userId) {
    _mockUserId = userId;
  }
  
  void setMockFavoriteDocuments(String? favoriteDocuments) {
    _mockFavoriteDocuments = favoriteDocuments;
  }
  
  Future<String?> getUserId() async {
    return _mockUserId;
  }
  
  Future<String?> getFavoriteDocuments() async {
    return _mockFavoriteDocuments;
  }
  
  Future<void> saveFavoriteDocuments(String favoriteDocuments) async {
    _mockFavoriteDocuments = favoriteDocuments;
  }
  
  // Implementações vazias para outros métodos não utilizados nos testes
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  group('DocumentRepository Tests', () {
    late DocumentRepository documentRepository;
    late MockDocumentsDataSource mockDocumentsDataSource;
    late MockSecureStorageService mockSecureStorageService;
    
    setUp(() {
      mockDocumentsDataSource = MockDocumentsDataSource();
      mockSecureStorageService = MockSecureStorageService();
      documentRepository = DocumentRepository(
        mockDocumentsDataSource,
        mockSecureStorageService,
      );
    });
    
    group('getDocuments', () {
      test('should return list of documents with favorite status', () async {
        // Arrange
        final documentsData = [
          {
            'id': 'doc1',
            'finalidade': 'Atestado',
            'descricao': 'Atestado médico',
            'dataEmissao': '2024-01-15T10:00:00.000Z',
          },
          {
            'id': 'doc2',
            'finalidade': 'Declaração',
            'descricao': 'Declaração de comparecimento',
            'dataEmissao': '2024-01-16T10:00:00.000Z',
          },
        ];
        
        mockSecureStorageService.setMockFavoriteDocuments('["doc1"]');
        mockDocumentsDataSource.setDocuments(documentsData);
        
        // Act
        final documents = await documentRepository.getDocuments();
        
        // Assert
        expect(documents, isA<List<DocumentModel>>());
        expect(documents.length, 2);
        expect(documents[0].id, 'doc1');
        expect(documents[0].isFavorite, true);
        expect(documents[1].id, 'doc2');
        expect(documents[1].isFavorite, false);
      });
      
      test('should return empty list when no documents are set', () async {
        // Arrange
        mockDocumentsDataSource.setDocuments([]);
        
        // Act
        final documents = await documentRepository.getDocuments();
        
        // Assert
        expect(documents, isA<List<DocumentModel>>());
        expect(documents.length, 0);
      });
      
      test('should handle no favorite documents stored', () async {
        // Arrange
        final documentsData = [
          {
            'id': 'doc1',
            'finalidade': 'Atestado',
            'descricao': 'Atestado médico',
            'dataEmissao': '2024-01-15T10:00:00.000Z',
          },
        ];
        
        mockSecureStorageService.setMockFavoriteDocuments(null);
        mockDocumentsDataSource.setDocuments(documentsData);
        
        // Act
        final documents = await documentRepository.getDocuments();
        
        // Assert
        expect(documents.length, 1);
        expect(documents[0].isFavorite, false);
      });
      
      test('should handle empty favorite documents list', () async {
        // Arrange
        final documentsData = [
          {
            'id': 'doc1',
            'finalidade': 'Atestado',
            'descricao': 'Atestado médico',
            'dataEmissao': '2024-01-15T10:00:00.000Z',
          },
        ];
        
        mockSecureStorageService.setMockFavoriteDocuments('[]');
        mockDocumentsDataSource.setDocuments(documentsData);
        
        // Act
        final documents = await documentRepository.getDocuments();
        
        // Assert
        expect(documents.length, 1);
        expect(documents[0].isFavorite, false);
      });
      
      test('should handle malformed favorite documents JSON', () async {
        // Arrange
        final documentsData = [
          {
            'id': 'doc1',
            'finalidade': 'Atestado',
            'descricao': 'Atestado médico',
            'dataEmissao': '2024-01-15T10:00:00.000Z',
          },
        ];
        
        mockSecureStorageService.setMockFavoriteDocuments('[invalid json');
        mockDocumentsDataSource.setDocuments(documentsData);
        
        // Act
        final documents = await documentRepository.getDocuments();
        
        // Assert
        expect(documents.length, 1);
        expect(documents[0].isFavorite, false);
      });
      
      test('should handle multiple favorite documents', () async {
        // Arrange
        final documentsData = [
          {
            'id': 'doc1',
            'finalidade': 'Atestado',
            'descricao': 'Atestado médico',
            'dataEmissao': '2024-01-15T10:00:00.000Z',
          },
          {
            'id': 'doc2',
            'finalidade': 'Declaração',
            'descricao': 'Declaração de comparecimento',
            'dataEmissao': '2024-01-16T10:00:00.000Z',
          },
          {
            'id': 'doc3',
            'finalidade': 'Relatório',
            'descricao': 'Relatório psicológico',
            'dataEmissao': '2024-01-17T10:00:00.000Z',
          },
        ];
        
        mockSecureStorageService.setMockFavoriteDocuments('["doc1", "doc3"]');
        mockDocumentsDataSource.setDocuments(documentsData);
        
        // Act
        final documents = await documentRepository.getDocuments();
        
        // Assert
        expect(documents.length, 3);
        expect(documents[0].isFavorite, true);  // doc1
        expect(documents[1].isFavorite, false); // doc2
        expect(documents[2].isFavorite, true);  // doc3
      });
      
      test('should handle documents with missing or invalid data', () async {
        // Arrange
        final documentsData = [
          {
            'id': 'doc1',
            'finalidade': null,
            'descricao': null,
            'dataEmissao': null,
          },
          {
            'id': 'doc2',
            // Missing fields
          },
          {
            // Missing id
            'finalidade': 'Atestado',
            'descricao': 'Atestado médico',
            'dataEmissao': '2024-01-15T10:00:00.000Z',
          },
        ];
        
        mockSecureStorageService.setMockFavoriteDocuments('[]');
        mockDocumentsDataSource.setDocuments(documentsData);
        
        // Act
        final documents = await documentRepository.getDocuments();
        
        // Assert
        expect(documents, isA<List<DocumentModel>>());
        expect(documents.length, 3);
        // Todos os documentos devem ser criados, mesmo com dados faltando
        expect(documents[0].id, 'doc1');
        expect(documents[1].id, 'doc2');
        expect(documents[2].id, ''); // ID vazio para documento sem ID
      });
    });
    
    group('toggleFavorite', () {
      test('should add document to favorites when not favorited', () async {
        // Arrange
        const documentId = 'doc1';
        mockSecureStorageService.setMockFavoriteDocuments('[]');
        
        // Act
        await documentRepository.toggleFavorite(documentId);
        
        // Assert
        final isFavorite = await documentRepository.isFavorite(documentId);
        expect(isFavorite, isTrue);
        // Verifica se foi salvo nos favoritos
        expect(mockSecureStorageService._mockFavoriteDocuments, '["doc1"]');
      });
      
      test('should remove document from favorites when already favorited', () async {
        // Arrange
        const documentId = 'doc1';
        mockSecureStorageService.setMockFavoriteDocuments('["doc1", "doc2"]');
        
        // Act
        await documentRepository.toggleFavorite(documentId);
        
        // Assert
        final isFavorite = await documentRepository.isFavorite(documentId);
        expect(isFavorite, isTrue);
        // Verifica se foi removido dos favoritos
        expect(mockSecureStorageService._mockFavoriteDocuments, '["doc2"]');
      });
      
      test('should handle empty favorites list', () async {
        // Arrange
        const documentId = 'doc1';
        mockSecureStorageService.setMockFavoriteDocuments(null);
        
        // Act
        await documentRepository.toggleFavorite(documentId);
        
        // Assert
        final isFavorite = await documentRepository.isFavorite(documentId);
        expect(isFavorite, isTrue);
        expect(mockSecureStorageService._mockFavoriteDocuments, '["doc1"]');
      });
      
      test('should handle malformed favorites JSON', () async {
        // Arrange
        const documentId = 'doc1';
        mockSecureStorageService.setMockFavoriteDocuments('[invalid json');
        
        // Act
        await documentRepository.toggleFavorite(documentId);
        
        // Assert
        final isFavorite = await documentRepository.isFavorite(documentId);
        expect(isFavorite, isTrue);
        expect(mockSecureStorageService._mockFavoriteDocuments, '["doc1"]');
      });
      
      test('should handle multiple toggle operations', () async {
        // Arrange
        const documentId1 = 'doc1';
        const documentId2 = 'doc2';
        mockSecureStorageService.setMockFavoriteDocuments('[]');
        
        // Act
        await documentRepository.toggleFavorite(documentId1);
        await documentRepository.toggleFavorite(documentId2);
        await documentRepository.toggleFavorite(documentId1); // Remove doc1
        
        // Assert
        expect(mockDocumentsDataSource.getDocuments(), 3);
        expect(mockSecureStorageService._mockFavoriteDocuments, '["doc2"]');
      });
      
      test('should handle special characters in document ID', () async {
        // Arrange
        const documentId = 'doc@123#special';
        mockSecureStorageService.setMockFavoriteDocuments('[]');
        
        // Act
        await documentRepository.toggleFavorite(documentId);
        
        // Assert
        final isFavorite = await documentRepository.isFavorite(documentId);
        expect(isFavorite, isTrue);
        expect(mockSecureStorageService._mockFavoriteDocuments, '["doc@123#special"]');
      });
      
      test('should handle empty document ID', () async {
        // Arrange
        const documentId = '';
        mockSecureStorageService.setMockFavoriteDocuments('[]');
        
        // Act
        await documentRepository.toggleFavorite(documentId);
        
        // Assert
        final isFavorite = await documentRepository.isFavorite(documentId);
        expect(isFavorite, isTrue);
        expect(mockSecureStorageService._mockFavoriteDocuments, '[""]');
      });
    });
    
   
    group('Integration Tests', () {
      test('should maintain favorite status consistency across operations', () async {
        // Arrange
        const userId = '123';
        const documentId = 'doc1';
        final documentsData = [
          {
            'id': documentId,
            'finalidade': 'Atestado',
            'descricao': 'Atestado médico',
            'dataEmissao': '2024-01-15T10:00:00.000Z',
          },
        ];
        
        mockSecureStorageService.setMockUserId(userId);
        mockSecureStorageService.setMockFavoriteDocuments('[]');
        mockDocumentsDataSource.setDocuments(documentsData);
        
        // Act & Assert
        // Initially not favorite
        var documents = await documentRepository.getDocuments();
        expect(documents[0].isFavorite, false);
        
        // Toggle to favorite
        await documentRepository.toggleFavorite(documentId);
        documents = await documentRepository.getDocuments();
        expect(documents[0].isFavorite, true);
        
        // Toggle back to not favorite
        await documentRepository.toggleFavorite(documentId);
        documents = await documentRepository.getDocuments();
        expect(documents[0].isFavorite, false);
      });
      
      test('should handle concurrent operations gracefully', () async {
        // Arrange
        final documentsData = [
          {
            'id': 'doc1',
            'finalidade': 'Atestado',
            'descricao': 'Atestado médico',
            'dataEmissao': '2024-01-15T10:00:00.000Z',
          },
        ];
        
        mockSecureStorageService.setMockFavoriteDocuments('[]');
        mockDocumentsDataSource.setDocuments(documentsData);
        
        // Act - Perform concurrent operations
        await Future.wait([
          documentRepository.getDocuments(),
          documentRepository.toggleFavorite('doc1'),
          documentRepository.getDocuments(),
        ]);
        
        // Assert - Should complete without errors
        final documents = await documentRepository.getDocuments();
        expect(documents, isNotEmpty);
        final isFavorite = await documentRepository.isFavorite('doc1');
        expect(isFavorite, isTrue);
      });
    });
  });
}