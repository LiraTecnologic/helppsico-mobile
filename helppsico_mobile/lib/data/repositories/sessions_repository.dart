import 'dart:convert';
import 'package:helppsico_mobile/data/models/session_model.dart';
import 'package:http/http.dart' as http;

class SessionRepository {
  final String baseUrl = 'http://localhost:7000';
  final http.Client _client;

  SessionRepository({http.Client? client}) : _client = client ?? http.Client();

  Future<List<SessionModel>> getSessions() async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/sessions'));
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => SessionModel.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        throw Exception('Sessions not found');
      } else if (response.statusCode == 500) {
        throw Exception('Server error');
      } else {
        throw Exception('Failed to load sessions with status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch sessions: $e');
    }
  }
}