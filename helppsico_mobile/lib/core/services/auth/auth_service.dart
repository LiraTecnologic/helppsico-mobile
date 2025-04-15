
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';

class AuthService {
  final IGenericHttp _http;
  final String _baseUrl = "http://localhost:7000"; 

  AuthService({IGenericHttp? http}) : _http = http ?? GenericHttp();

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _http.post(
        "$_baseUrl/login",
        {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {

      return  AuthResponse(
          name: email.split('@')[0], 
          email: email,
          role: 'patient',
          message: response.body['message'],
       );
      } else {
        throw Exception(response.body['message'] ?? 'Authentication failed');
      }
    } catch (e) {
      throw Exception('Failed to authenticate: ${e.toString()}');
    }
  }

}

 class AuthResponse {
    final String name;
    final String email;
    final String role;
    final String message;

    AuthResponse({
      required this.name,
      required this.email,
      required this.role,
      required this.message,
    });

    factory AuthResponse.fromJson(Map<String, dynamic> json) {
      return AuthResponse(
        name: json['name'],
        email: json['email'],
        role: json['role'],
        message: json['message'],
      );
    }
  }