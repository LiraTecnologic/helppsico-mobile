import 'models/review_model.dart';

class MockReviews {
  static final List<ReviewModel> reviews = [
    ReviewModel(
      id: '1',
      psicologoId: '1',
      userName: 'João Silva',
      rating: 5,
      comment: 'Excelente profissional! Me ajudou muito com minhas questões de ansiedade.',
      date: DateTime(2024, 1, 15),
    ),
    ReviewModel(
      id: '2',
      psicologoId: '1',
      userName: 'Maria Santos',
      rating: 4,
      comment: 'Muito atenciosa e profissional. Recomendo!',
      date: DateTime(2024, 1, 10),
    ),
    ReviewModel(
      id: '3',
      psicologoId: '1',
      userName: 'Pedro Oliveira',
      rating: 5,
      comment: 'Ótimas sessões, me sinto muito melhor após começar o tratamento.',
      date: DateTime(2024, 1, 5),
    ),
  ];

  static void addReview(ReviewModel review) {
    reviews.insert(0, review);
  }

  static void deleteReview(String reviewId) {
    reviews.removeWhere((review) => review.id == reviewId);
  }

  static List<ReviewModel> getReviewsByPsicologoId(String psicologoId) {
    return reviews.where((review) => review.psicologoId == psicologoId).toList();
  }
}