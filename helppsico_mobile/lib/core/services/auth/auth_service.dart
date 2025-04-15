
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';

class AuthService {
  final IGenericHttp _http;
  final String _baseUrl = "http://localhost:7000"; 

  AuthService({IGenericHttp? http}) : _http = http ?? GenericHttp();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _http.post(
        "$_baseUrl/login",
        {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        return {
          'name': email.split('@')[0], 
          'email': email,
          'role': 'patient',
          'message': response.body['message'],
        };
      } else {
        throw Exception(response.body['message'] ?? 'Authentication failed');
      }
    } catch (e) {
      throw Exception('Failed to authenticate: ${e.toString()}');
    }
  }
}