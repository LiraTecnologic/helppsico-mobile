
import 'dart:convert';
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';
import 'package:helppsico_mobile/core/services/storage/secure_storage_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:helppsico_mobile/domain/entities/user_model.dart';

class AuthService {
  final IGenericHttp _http;
  final SecureStorageService _storage;
  // Atualizado para a nova API Java
  final String _baseUrl = "http://localhost:8080"; // Ajuste conforme necessário para o ambiente de produção

  AuthService({
    IGenericHttp? http, 
    SecureStorageService? storage
  }) : 
    _http = http ?? GenericHttp(),
    _storage = storage ?? SecureStorageService();

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _http.post(
        "$_baseUrl/login/paciente",
        {
          'email': email,
          'senha': password, // Alterado de 'password' para 'senha' conforme API Java
        },
      );

      if (response.statusCode == 200) {
        // A API Java encapsula todas as respostas em um objeto ResponseDto<T> com o dado principal no campo 'dado'
        final responseData = response.body['dado'];
        
        if (responseData == null) {
          throw Exception('Dados de resposta inválidos');
        }
        
        final token = responseData['token'];
        final userId = responseData['idUsuario']?.toString();
        final userEmail = responseData['email'];
        
        if (token == null || userId == null || userEmail == null) {
          throw Exception('Dados de autenticação incompletos');
        }
        
        // Salva o token para autenticação
        await _storage.saveToken(token);
        
        // Salva os dados do usuário individualmente para fácil acesso
        await _storage.saveUserId(userId);
        await _storage.saveUserEmail(userEmail);
        
        // Cria um objeto User com os dados disponíveis
        final user = User(
          id: userId,
          name: userEmail.split('@')[0], // Usa parte do email como nome temporário
          email: userEmail,
          password: '', // Não armazenamos a senha
          role: 'PACIENTE', // Papel fixo para esta implementação
        );
        
        // Salva os dados completos do usuário como JSON
        await _storage.saveUserData(json.encode(user.toJson()));

        return AuthResponse(
          id: int.parse(userId),
          name: user.name, 
          email: userEmail,
          role: 'PACIENTE',
          message: 'Login realizado com sucesso',
          token: token,
        );
      } else {
        // Tratamento de erro conforme o formato da API Java
        final errorMessage = response.body['mensagem'] ?? 'Falha na autenticação';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Falha ao autenticar: ${e.toString()}');
    }
  }
  
  
  Future<bool> isAuthenticated() async {
    final token = await _storage.getToken();
    if (token == null) return false;
    
   
    return !JwtDecoder.isExpired(token);
  }
  
  
  Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      // Verifica se há um token válido
      final token = await _storage.getToken();
      if (token == null) return null;
      
      // Obtém os dados do usuário armazenados
      final userData = await _storage.getUserData();
      if (userData != null) {
        return json.decode(userData);
      }
      
      // Se não tiver dados armazenados, tenta extrair do token
      final userId = await _storage.getUserId();
      final userEmail = await _storage.getUserEmail();
      
      if (userId != null && userEmail != null) {
        return {
          'id': userId,
          'email': userEmail,
          'role': 'PACIENTE',
        };
      }
      
      // Se não tiver dados específicos, usa o payload do token
      return JwtDecoder.decode(token);
    } catch (e) {
      print('Erro ao obter informações do usuário: $e');
      return null;
    }
  }
  
 
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await _storage.getToken();
    if (token == null) return {};
    
    // Formato de autenticação para a API Java
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }
  
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
