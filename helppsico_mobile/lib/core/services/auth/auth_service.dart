import 'dart:convert';
import 'package:get_it/get_it.dart';
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';
import 'package:helppsico_mobile/core/services/storage/secure_storage_service.dart';
import 'package:helppsico_mobile/core/services/psicologo/psicologo_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:helppsico_mobile/domain/entities/user_model.dart';
import 'package:helppsico_mobile/domain/entities/psicologo_entity.dart';

class AuthService {
  final IGenericHttp _http;
  final SecureStorageService _storage;
  final PsicologoService _psicologoService;

  final String _baseUrl = "http://10.0.2.2:8080";

  AuthService({
    IGenericHttp? http,
    SecureStorageService? storage,
    PsicologoService? psicologoService,
  })  : _http = http ?? GenericHttp(),
        _storage = storage ?? GetIt.instance.get<SecureStorageService>(),
        _psicologoService = psicologoService ?? PsicologoService(http ?? GenericHttp(), storage ?? GetIt.instance.get<SecureStorageService>());

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _http.post(
        "$_baseUrl/login/paciente",
        {
          'email': email,
          'senha': password,
        },
      );

      if (response.statusCode == 200) {
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

        await _saveUserInfo(token, userId, userEmail);

        final psicologoInfo = await _psicologoService.getPsicologoByPacienteId(userId);

        Psicologo? psicologo;
        
        if (psicologoInfo != null) {
          psicologo = Psicologo(
            id: psicologoInfo['id'] ?? '',
            nome: psicologoInfo['nome'] ?? '',
            crp: psicologoInfo['crp']?? '',
          );

          await _savePsicologoInfo(psicologo);
        }

        return AuthResponse(
          id: userId,
          name: userEmail.split('@')[0],
          email: userEmail,
          role: 'PACIENTE',
          message: 'Login realizado com sucesso',
          token: token,
        );
      } else {
        final errorMessage = response.body['mensagem'] ?? 'Falha na autenticação';
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Falha ao autenticar: ${e.toString()}');
    }
  }

  Future<bool> isAuthenticated() async {
    final token = await _storage.getToken();
    if (token == null) {
      return false;
    }

    final isExpired = JwtDecoder.isExpired(token);
    return !isExpired;
  }

  Future<Map<String, dynamic>?> getUserInfo() async {
    try {
      final userData = await _storage.getUserData();
      if (userData != null) {
        final userMap = json.decode(userData);
        
        final psicologoData = await _storage.getPsicologoData();
        if (psicologoData != null && !userMap.containsKey('psicologo')) {
          final psicologoMap = json.decode(psicologoData);
          userMap['psicologo'] = psicologoMap;
        }
        
        return userMap;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, String>> getAuthHeaders() async {
    final token = await _storage.getToken();
    if (token == null) {
      return {};
    }

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<void> logout() async {
    await _storage.clearAll();
  }

  Future<String> getToken() async {
    final token = await _storage.getToken() ?? '';
    return token;
  }

  Future<String?> getCurrentUser() async {
    final userId = await _storage.getUserId();
    return userId;
  }

  Future<void> _saveUserInfo(String token, String userId, String userEmail) async {
    await _storage.saveToken(token);
    await _storage.saveUserId(userId);
    await _storage.saveUserEmail(userEmail);

    final user = User(
      id: userId,
      name: userEmail.split('@')[0],
      email: userEmail,
      password: '',
      role: 'PACIENTE',
      psicologo: null,
    );

    await _storage.saveUserData(json.encode(user.toJson()));
  }

  Future<void> _savePsicologoInfo(Psicologo psicologo) async {
    await _storage.savePsicologoData(json.encode(psicologo.toJson()));
  }
}

class AuthResponse {
  final String id;
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
      id: json['id']?.toString() ?? '',
      name: json['name'],
      email: json['email'],
      role: json['role'],
      message: json['message'],
      token: json['token'],
    );
  }
}

