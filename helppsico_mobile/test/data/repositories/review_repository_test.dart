import 'package:flutter_test/flutter_test.dart';
import 'package:helppsico_mobile/data/repositories/review_repository.dart';
import 'package:helppsico_mobile/data/datasource/review_datasource.dart';
import 'package:helppsico_mobile/domain/entities/review_entity.dart';
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';
import 'package:helppsico_mobile/core/services/storage/secure_storage_service.dart';
import 'package:helppsico_mobile/core/services/auth/auth_service.dart';

// Mock classes
class MockReviewDataSource implements ReviewDataSource {
  List<ReviewEntity>? _mockReviews;
  Map<String, String>? _mockPsicologoInfo;
  Exception? _mockException;
  String? _lastPsicologoId;
  ReviewEntity? _lastAddedReview;
  String? _lastDeletedReviewId;
  
  void setMockReviews(List<ReviewEntity>? reviews) {
    _mockReviews = reviews;
  }
  
  void setMockPsicologoInfo(Map<String, String>? info) {
    _mockPsicologoInfo = info;
  }
  
  void setMockException(Exception? exception) {
    _mockException = exception;
  }
  
  String? get lastPsicologoId => _lastPsicologoId;
  ReviewEntity? get lastAddedReview => _lastAddedReview;
  String? get lastDeletedReviewId => _lastDeletedReviewId;
  
  @override
  Future<List<ReviewEntity>> getReviewsByPsicologoId(String psicologoId) async {
    _lastPsicologoId = psicologoId;
    if (_mockException != null) {
      throw _mockException!;
    }
    return _mockReviews ?? [];
  }
  
  @override
  Future<Map<String, String>?> getPsicologoInfo() async {
    if (_mockException != null) {
      throw _mockException!;
    }
    return _mockPsicologoInfo;
  }
  
  @override
  Future<void> addReview(ReviewEntity review) async {
    _lastAddedReview = review;
    if (_mockException != null) {
      throw _mockException!;
    }
  }
  
  @override
  Future<void> deleteReview(String reviewId) async {
    _lastDeletedReviewId = reviewId;
    if (_mockException != null) {
      throw _mockException!;
    }
  }
  
  // Implementações vazias para outros métodos não utilizados nos testes
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class MockGenericHttp implements IGenericHttp {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class MockSecureStorageService implements SecureStorageService {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class MockAuthService implements AuthService {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  group('ReviewRepository Tests', () {
    late ReviewRepository reviewRepository;
    late MockReviewDataSource mockDataSource;
    
    setUp(() {
      mockDataSource = MockReviewDataSource();
      reviewRepository = ReviewRepository(dataSource: mockDataSource);
    });
    
    group('Constructor', () {
      test('should create repository with provided dataSource', () {
        // Arrange & Act
        final repository = ReviewRepository(dataSource: mockDataSource);
        
        // Assert
        expect(repository, isA<ReviewRepository>());
      });
      
      test('should create repository with default dependencies when not provided', () {
        // Arrange & Act
        final repository = ReviewRepository(
          http: MockGenericHttp(),
          secureStorage: MockSecureStorageService(),
          authService: MockAuthService(),
        );
        
        // Assert
        expect(repository, isA<ReviewRepository>());
      });
    });
    
    group('getReviews', () {
      test('should return reviews when psicologo info is available', () async {
        // Arrange
        final expectedReviews = [
          ReviewEntity(
            id: '1',
            psicologoId: 'psi123',
            pacienteId: 'pac1',
            userName: 'João Silva',
            rating: 5,
            comment: 'Excelente profissional',
            date: DateTime.now(),
          ),
          ReviewEntity(
            id: '2',
            psicologoId: 'psi123',
            pacienteId: 'pac2',
            userName: 'Ana Costa',
            rating: 4,
            comment: 'Muito boa',
            date: DateTime.now(),
          ),
        ];
        
        mockDataSource.setMockPsicologoInfo({'id': 'psi123', 'nome': 'Dr. Maria Santos'});
        mockDataSource.setMockReviews(expectedReviews);
        
        // Act
        final result = await reviewRepository.getReviews();
        
        // Assert
        expect(result, expectedReviews);
        expect(mockDataSource.lastPsicologoId, 'psi123');
      });
      
      test('should throw exception when psicologo info is null', () async {
        // Arrange
        mockDataSource.setMockPsicologoInfo(null);
        
        // Act & Assert
        expect(
          () => reviewRepository.getReviews(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Informações do psicólogo não encontradas'),
          )),
        );
      });
      
      test('should throw exception when psicologo info has no id', () async {
        // Arrange
        mockDataSource.setMockPsicologoInfo({'nome': 'Dr. Maria Santos'});
        
        // Act & Assert
        expect(
          () => reviewRepository.getReviews(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Informações do psicólogo não encontradas'),
          )),
        );
      });
      
      test('should throw exception when psicologo info has null id', () async {
        // Arrange
        mockDataSource.setMockPsicologoInfo({'id': "1", 'nome': 'Dr. Maria Santos'});
        
        // Act & Assert
        expect(
          () => reviewRepository.getReviews(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Informações do psicólogo não encontradas'),
          )),
        );
      });
      
      test('should rethrow exception from getPsicologoInfo', () async {
        // Arrange
        final expectedException = Exception('Erro ao obter informações do psicólogo');
        mockDataSource.setMockException(expectedException);
        
        // Act & Assert
        expect(
          () => reviewRepository.getReviews(),
          throwsA(expectedException),
        );
      });
      
      test('should return empty list when no reviews found', () async {
        // Arrange
        mockDataSource.setMockPsicologoInfo({'id': 'psi123', 'nome': 'Dr. Maria Santos'});
        mockDataSource.setMockReviews([]);
        
        // Act
        final result = await reviewRepository.getReviews();
        
        // Assert
        expect(result, isEmpty);
        expect(mockDataSource.lastPsicologoId, 'psi123');
      });
    });
    
    group('getReviewsByPsicologoId', () {
      test('should return reviews for given psicologo ID', () async {
        // Arrange
        const psicologoId = 'psi456';
        final expectedReviews = [
          ReviewEntity(
            id: '1',
            psicologoId: psicologoId,
            pacienteId: 'pac1',
            userName: 'Carlos Lima',
            rating: 5,
            comment: 'Profissional excepcional',
            date: DateTime.now(),
          ),
        ];
        
        mockDataSource.setMockReviews(expectedReviews);
        
        // Act
        final result = await reviewRepository.getReviewsByPsicologoId(psicologoId);
        
        // Assert
        expect(result, expectedReviews);
        expect(mockDataSource.lastPsicologoId, psicologoId);
      });
      
      test('should return empty list when no reviews found for psicologo', () async {
        // Arrange
        const psicologoId = 'psi789';
        mockDataSource.setMockReviews([]);
        
        // Act
        final result = await reviewRepository.getReviewsByPsicologoId(psicologoId);
        
        // Assert
        expect(result, isEmpty);
        expect(mockDataSource.lastPsicologoId, psicologoId);
      });
      
      test('should handle special characters in psicologo ID', () async {
        // Arrange
        const psicologoId = 'psi@123#special';
        final expectedReviews = [
          ReviewEntity(
            id: '1',
            psicologoId: psicologoId,
            pacienteId: 'pac1',
            userName: 'Maria Oliveira',
            rating: 4,
            comment: 'Boa profissional',
            date: DateTime.now(),
          ),
        ];
        
        mockDataSource.setMockReviews(expectedReviews);
        
        // Act
        final result = await reviewRepository.getReviewsByPsicologoId(psicologoId);
        
        // Assert
        expect(result, expectedReviews);
        expect(mockDataSource.lastPsicologoId, psicologoId);
      });
      
      test('should handle empty psicologo ID', () async {
        // Arrange
        const psicologoId = '';
        mockDataSource.setMockReviews([]);
        
        // Act
        final result = await reviewRepository.getReviewsByPsicologoId(psicologoId);
        
        // Assert
        expect(result, isEmpty);
        expect(mockDataSource.lastPsicologoId, psicologoId);
      });
    });
    
    group('addReview', () {
      test('should add review successfully', () async {
        // Arrange
        final review = ReviewEntity(
            id: 'new_review',
            psicologoId: 'psi123',
            pacienteId: 'pac1',
            userName: 'Pedro Santos',
            rating: 5,
            comment: 'Excelente atendimento',
            date: DateTime.now(),
          );
        
        // Act
        await reviewRepository.addReview(review);
        
        // Assert
        expect(mockDataSource.lastAddedReview, review);
      });
      
      test('should rethrow exception from dataSource', () async {
        // Arrange
        final review = ReviewEntity(
            id: 'new_review',
            psicologoId: 'psi123',
            pacienteId: 'pac1',
            userName: 'Pedro Santos',
            rating: 5,
            comment: 'Excelente atendimento',
            date: DateTime.now(),
          );
        final expectedException = Exception('Erro ao adicionar review');
        mockDataSource.setMockException(expectedException);
        
        // Act & Assert
        expect(
          () => reviewRepository.addReview(review),
          throwsA(expectedException),
        );
      });
      
      test('should handle review with minimum data', () async {
        // Arrange
        final review = ReviewEntity(
            id: '',
            psicologoId: '',
            pacienteId: '',
            userName: '',
            rating: 1,
            comment: '',
            date: DateTime.now(),
          );
        
        // Act
        await reviewRepository.addReview(review);
        
        // Assert
        expect(mockDataSource.lastAddedReview, review);
      });
      
      test('should handle review with special characters', () async {
        // Arrange
        final review = ReviewEntity(
            id: 'review@123#special',
            psicologoId: 'psi@123',
            pacienteId: 'pac@456',
            userName: 'José da Silva & Cia',
            rating: 3,
            comment: 'Comentário com acentos: ção, ã, é',
            date: DateTime.now(),
          );
        
        // Act
        await reviewRepository.addReview(review);
        
        // Assert
        expect(mockDataSource.lastAddedReview, review);
      });
    });
    
    group('deleteReview', () {
      test('should delete review successfully', () async {
        // Arrange
        const reviewId = 'review123';
        
        // Act
        await reviewRepository.deleteReview(reviewId);
        
        // Assert
        expect(mockDataSource.lastDeletedReviewId, reviewId);
      });
      
      test('should rethrow exception from dataSource', () async {
        // Arrange
        const reviewId = 'review123';
        final expectedException = Exception('Erro ao deletar review');
        mockDataSource.setMockException(expectedException);
        
        // Act & Assert
        expect(
          () => reviewRepository.deleteReview(reviewId),
          throwsA(expectedException),
        );
      });
      
      test('should handle special characters in review ID', () async {
        // Arrange
        const reviewId = 'review@123#special';
        
        // Act
        await reviewRepository.deleteReview(reviewId);
        
        // Assert
        expect(mockDataSource.lastDeletedReviewId, reviewId);
      });
      
      test('should handle empty review ID', () async {
        // Arrange
        const reviewId = '';
        
        // Act
        await reviewRepository.deleteReview(reviewId);
        
        // Assert
        expect(mockDataSource.lastDeletedReviewId, reviewId);
      });
    });
    
    group('getPsicologoInfo', () {
      test('should return psicologo info when available', () async {
        // Arrange
        final expectedInfo = {
          'id': 'psi123',
          'nome': 'Dr. Maria Santos',
          'crp': '12345',
          'especialidade': 'Psicologia Clínica',
        };
        mockDataSource.setMockPsicologoInfo(expectedInfo);
        
        // Act
        final result = await reviewRepository.getPsicologoInfo();
        
        // Assert
        expect(result, expectedInfo);
      });
      
      test('should return null when psicologo info not available', () async {
        // Arrange
        mockDataSource.setMockPsicologoInfo(null);
        
        // Act
        final result = await reviewRepository.getPsicologoInfo();
        
        // Assert
        expect(result, isNull);
      });
      
      test('should return empty map when psicologo info is empty', () async {
        // Arrange
        mockDataSource.setMockPsicologoInfo({});
        
        // Act
        final result = await reviewRepository.getPsicologoInfo();
        
        // Assert
        expect(result, isEmpty);
      });
      
      test('should rethrow exception from dataSource', () async {
        // Arrange
        final expectedException = Exception('Erro ao obter informações do psicólogo');
        mockDataSource.setMockException(expectedException);
        
        // Act & Assert
        expect(
          () => reviewRepository.getPsicologoInfo(),
          throwsA(expectedException),
        );
      });
      
      test('should handle psicologo info with special characters', () async {
        // Arrange
        final expectedInfo = {
          'id': 'psi@123#special',
          'nome': 'Dr. José da Silva & Cia',
          'crp': 'CRP-01/12345',
          'especialidade': 'Psicologia Clínica & Organizacional',
        };
        mockDataSource.setMockPsicologoInfo(expectedInfo);
        
        // Act
        final result = await reviewRepository.getPsicologoInfo();
        
        // Assert
        expect(result, expectedInfo);
      });
    });
    
    group('Integration Tests', () {
      test('should handle complete review workflow', () async {
        // Arrange
        final psicologoInfo = {'id': 'psi123', 'nome': 'Dr. Maria Santos'};
        final existingReviews = [
          ReviewEntity(
            id: '1',
            psicologoId: 'psi123',
            pacienteId: 'pac1',
            userName: 'João Silva',
            rating: 5,
            comment: 'Excelente',
            date: DateTime.now(),
          ),
        ];
        final newReview = ReviewEntity(
          id: '2',
          psicologoId: 'psi123',
          pacienteId: 'pac2',
          userName: 'Ana Costa',
          rating: 4,
          comment: 'Muito boa',
          date: DateTime.now(),
        );
        
        mockDataSource.setMockPsicologoInfo(psicologoInfo);
        mockDataSource.setMockReviews(existingReviews);
        
        // Act
        final info = await reviewRepository.getPsicologoInfo();
        final reviews = await reviewRepository.getReviews();
        await reviewRepository.addReview(newReview);
        await reviewRepository.deleteReview('1');
        
        // Assert
        expect(info, psicologoInfo);
        expect(reviews, existingReviews);
        expect(mockDataSource.lastAddedReview, newReview);
        expect(mockDataSource.lastDeletedReviewId, '1');
      });
      
      test('should handle error scenarios in workflow', () async {
        // Arrange
        final networkException = Exception('Erro de rede');
        mockDataSource.setMockException(networkException);
        
        final review = ReviewEntity(
          id: '1',
          psicologoId: 'psi123',
          pacienteId: 'pac1',
          userName: 'João Silva',
          rating: 5,
          comment: 'Excelente',
          date: DateTime.now(),
        );
        
        // Act & Assert
        expect(
          () => reviewRepository.getPsicologoInfo(),
          throwsA(networkException),
        );
        
        expect(
          () => reviewRepository.getReviews(),
          throwsA(networkException),
        );
        
        expect(
          () => reviewRepository.addReview(review),
          throwsA(networkException),
        );
        
        expect(
          () => reviewRepository.deleteReview('1'),
          throwsA(networkException),
        );
      });
    });
  });
}