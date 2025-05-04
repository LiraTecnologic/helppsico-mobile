
import 'dart:convert';
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';
import 'package:helppsico_mobile/core/services/storage/secure_storage_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthService {
  final IGenericHttp _http;
  final SecureStorageService _storage;
  final String _baseUrl = "http://localhost:7000"; 

  AuthService({
    IGenericHttp? http, 
    SecureStorageService? storage
  }) : 
    _http = http ?? GenericHttp(),
    _storage = storage ?? SecureStorageService();

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
        final token = response.body['token'];
        final userData = response.body['user'];
        
        // Armazenar o token JWT
        await _storage.saveToken(token);
        
        // Armazenar os dados do usuário
        await _storage.saveUserData(json.encode(userData));

        return AuthResponse(
          id: userData['id'],
          name: userData['name'], 
          email: userData['email'],
          role: userData['role'],
          message: response.body['message'],
          token: token,
        );
      } else {
        throw Exception(response.body['message'] ?? 'Authentication failed');
      }
    } catch (e) {
      throw Exception('Failed to authenticate: ${e.toString()}');
    }
  }
  
  // Verificar se o usuário está autenticado
  Future<bool> isAuthenticated() async {
    final token = await _storage.getToken();
    if (token == null) return false;
    
    // Verificar se o token não expirou
    return !JwtDecoder.isExpired(token);
  }
  
  // Obter informações do usuário a partir do token
  Future<Map<String, dynamic>?> getUserInfo() async {
    final token = await _storage.getToken();
    if (token == null) return null;
    
    return JwtDecoder.decode(token);
  }
  
  // Adicionar token às requisições
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await _storage.getToken();
    if (token == null) return {};
    
    return {
      'Authorization': 'Bearer $token',
    };
  }
  
  // Logout - remover token e dados do usuário
  Future<void> logout() async {
    await _storage.clearAll();
  }

  Future <String> getToken() async {
    return await _storage.getToken()?? '';
  }
}

class AuthResponse {
  final int id;
  final String name;
  final String email;
  final String role;
  final String message;
  final String token;

  AuthResponse({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.message,
    required this.token,
  });

    factory AuthResponse.fromJson(Map<String, dynamic> json) {
      return AuthResponse(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        role: json['role'],
        message: json['message'],
        token: json['token'],
      );
    }
  }
