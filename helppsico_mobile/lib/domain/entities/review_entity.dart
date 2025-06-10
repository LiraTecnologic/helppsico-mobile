class ReviewEntity {
  final String id;
  final String psicologoId;
  final String pacienteId;
  final String userName;
  final int rating;
  final String comment;
  final DateTime date;

  ReviewEntity({
    required this.id,
    required this.psicologoId,
    required this.pacienteId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
  }) {
    print(
      '[ReviewEntity] Created - '
      'id: $id, '
      'psicologoId: $psicologoId, '
      'pacienteId: $pacienteId, '
      'userName: $userName, '
      'rating: $rating, '
      'comment: ${comment.length > 50 ? comment.substring(0, 50) + "..." : comment}'
    );
  }
}
