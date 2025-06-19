import 'package:flutter_test/flutter_test.dart';
import 'package:helppsico_mobile/domain/entities/review_entity.dart';

void main() {
  group('ReviewEntity Tests', () {
    late DateTime testDate;

    setUp(() {
      testDate = DateTime.parse('2024-01-15T10:00:00.000Z');
    });

    test('should create ReviewEntity instance with all fields', () {
      final review = ReviewEntity(
        id: 'rev123',
        psicologoId: 'psi123',
        pacienteId: 'pac456',
        userName: 'João Silva',
        rating: 5,
        comment: 'Excelente profissional, muito atencioso.',
        date: testDate,
      );

      expect(review.id, 'rev123');
      expect(review.psicologoId, 'psi123');
      expect(review.pacienteId, 'pac456');
      expect(review.userName, 'João Silva');
      expect(review.rating, 5);
      expect(review.comment, 'Excelente profissional, muito atencioso.');
      expect(review.date, testDate);
    });

    test('should create ReviewEntity with minimum rating', () {
      final review = ReviewEntity(
        id: 'rev123',
        psicologoId: 'psi123',
        pacienteId: 'pac456',
        userName: 'João Silva',
        rating: 1,
        comment: 'Não gostei do atendimento.',
        date: testDate,
      );

      expect(review.rating, 1);
      expect(review.comment, 'Não gostei do atendimento.');
    });

    test('should create ReviewEntity with maximum rating', () {
      final review = ReviewEntity(
        id: 'rev123',
        psicologoId: 'psi123',
        pacienteId: 'pac456',
        userName: 'João Silva',
        rating: 5,
        comment: 'Perfeito!',
        date: testDate,
      );

      expect(review.rating, 5);
      expect(review.comment, 'Perfeito!');
    });

    test('should create ReviewEntity with empty comment', () {
      final review = ReviewEntity(
        id: 'rev123',
        psicologoId: 'psi123',
        pacienteId: 'pac456',
        userName: 'João Silva',
        rating: 4,
        comment: '',
        date: testDate,
      );

      expect(review.comment, '');
      expect(review.rating, 4);
    });

    test('should create ReviewEntity with long comment', () {
      final longComment = 'Este é um comentário muito longo que descreve em detalhes a experiência do paciente com o psicólogo. ' * 5;
      
      final review = ReviewEntity(
        id: 'rev123',
        psicologoId: 'psi123',
        pacienteId: 'pac456',
        userName: 'João Silva',
        rating: 4,
        comment: longComment,
        date: testDate,
      );

      expect(review.comment, longComment);
      expect(review.comment.length, greaterThan(100));
    });

    test('should handle different date values', () {
      final pastDate = DateTime.parse('2023-01-01T00:00:00.000Z');
      final futureDate = DateTime.parse('2025-12-31T23:59:59.999Z');

      final pastReview = ReviewEntity(
        id: 'rev123',
        psicologoId: 'psi123',
        pacienteId: 'pac456',
        userName: 'João Silva',
        rating: 4,
        comment: 'Review do passado',
        date: pastDate,
      );

      final futureReview = ReviewEntity(
        id: 'rev124',
        psicologoId: 'psi123',
        pacienteId: 'pac456',
        userName: 'João Silva',
        rating: 3,
        comment: 'Review do futuro',
        date: futureDate,
      );

      expect(pastReview.date, pastDate);
      expect(futureReview.date, futureDate);
      expect(pastReview.date.isBefore(futureReview.date), true);
    });

    test('should handle special characters in fields', () {
      final review = ReviewEntity(
        id: 'rev@123#',
        psicologoId: 'psi\$123%',
        pacienteId: 'pac&456*',
        userName: 'João & Maria Silva',
        rating: 5,
        comment: 'Comentário com acentos: ção, ã, é, ü e símbolos: @#\$%&*',
        date: testDate,
      );

      expect(review.id, 'rev@123#');
      expect(review.psicologoId, 'psi\$123%');
      expect(review.pacienteId, 'pac&456*');
      expect(review.userName, 'João & Maria Silva');
      expect(review.comment, 'Comentário com acentos: ção, ã, é, ü e símbolos: @#\$%&*');
    });

    test('should handle numeric string IDs', () {
      final review = ReviewEntity(
        id: '123456',
        psicologoId: '789012',
        pacienteId: '345678',
        userName: 'João Silva',
        rating: 4,
        comment: 'Bom atendimento',
        date: testDate,
      );

      expect(review.id, '123456');
      expect(review.psicologoId, '789012');
      expect(review.pacienteId, '345678');
    });

    test('should handle edge case ratings', () {
      final zeroRatingReview = ReviewEntity(
        id: 'rev123',
        psicologoId: 'psi123',
        pacienteId: 'pac456',
        userName: 'João Silva',
        rating: 0,
        comment: 'Rating zero',
        date: testDate,
      );

      final negativeRatingReview = ReviewEntity(
        id: 'rev124',
        psicologoId: 'psi123',
        pacienteId: 'pac456',
        userName: 'João Silva',
        rating: -1,
        comment: 'Rating negativo',
        date: testDate,
      );

      final highRatingReview = ReviewEntity(
        id: 'rev125',
        psicologoId: 'psi123',
        pacienteId: 'pac456',
        userName: 'João Silva',
        rating: 10,
        comment: 'Rating alto',
        date: testDate,
      );

      expect(zeroRatingReview.rating, 0);
      expect(negativeRatingReview.rating, -1);
      expect(highRatingReview.rating, 10);
    });

    test('should maintain immutability', () {
      final review = ReviewEntity(
        id: 'rev123',
        psicologoId: 'psi123',
        pacienteId: 'pac456',
        userName: 'João Silva',
        rating: 5,
        comment: 'Excelente',
        date: testDate,
      );

      // Verificar que os campos são final e não podem ser alterados
      expect(review.id, 'rev123');
      expect(review.psicologoId, 'psi123');
      expect(review.pacienteId, 'pac456');
      expect(review.userName, 'João Silva');
      expect(review.rating, 5);
      expect(review.comment, 'Excelente');
      expect(review.date, testDate);
    });
  });
}