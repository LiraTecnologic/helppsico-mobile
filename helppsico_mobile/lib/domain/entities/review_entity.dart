class ReviewEntity {
  final String id;
  final String psicologoId;
  final String userName;
  final int rating;
  final String comment;
  final DateTime date;

  ReviewEntity({
    required this.id,
    required this.psicologoId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
  }) {
    print('[ReviewEntity] Created - id: $id, psicologoId: $psicologoId, userName: $userName, rating: $rating, comment: ${comment.length > 50 ? comment.substring(0, 50) + '...' : comment}');
  }
}