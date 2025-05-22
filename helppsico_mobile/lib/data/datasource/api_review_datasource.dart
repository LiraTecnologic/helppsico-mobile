import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/review_entity.dart';
import 'review_datasource.dart';

class ApiReviewDataSource implements ReviewDataSource {
  final String baseUrl = 'http://localhost:7000';


  @override
  Future<List<ReviewEntity>> getReviewsByPsicologoId(String psicologoId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/reviews/$psicologoId'));
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => _reviewFromJson(json)).toList();
      } else {
        throw Exception('Falha ao carregar avaliações');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  @override
  Future<void> addReview(ReviewEntity review) async {
    try {
      final reviewJson = {
        'id': review.id,
        'psicologoId': review.psicologoId,
        'userName': review.userName,
        'rating': review.rating,
        'comment': review.comment,
        'date': review.date.toIso8601String(),
      };

      final response = await http.post(
        Uri.parse('$baseUrl/reviews'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(reviewJson),
      );
      
      if (response.statusCode != 201) {
        throw Exception('Falha ao adicionar avaliação');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/reviews/$reviewId'));
      
      if (response.statusCode != 200) {
        throw Exception('Falha ao excluir avaliação');
      }
    } catch (e) {
      throw Exception('Erro de conexão: $e');
    }
  }

  ReviewEntity _reviewFromJson(Map<String, dynamic> json) {
    return ReviewEntity(
      id: json['id'],
      psicologoId: json['psicologoId'],
      userName: json['userName'],
      rating: json['rating'],
      comment: json['comment'],
      date: DateTime.parse(json['date']),
    );
  }
}