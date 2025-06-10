
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

  final String _baseUrl = "http://localhost:8080";

  AuthService({
    IGenericHttp? http,
    SecureStorageService? storage,
    PsicologoService? psicologoService,
  })  : _http = http ?? GenericHttp(),
        _storage = storage ?? GetIt.instance.get<SecureStorageService>(),
        _psicologoService = psicologoService ?? PsicologoService(http ?? GenericHttp(), storage ?? GetIt.instance.get<SecureStorageService>()) {
    print('[AuthService] AuthService instance created.');
  }

  Future<AuthResponse> login(String email, String password) async {
    print('[AuthService] login method called with email: $email');
    try {
      print("[AuthService] Attempting login for user: $email");
      print("[AuthService] Sending login request to $_baseUrl/login/paciente");
      final response = await _http.post(
        "$_baseUrl/login/paciente",
        {
          'email': email,
          'senha': password,
        },
      );

      print("[AuthService] Login response status code: ${response.statusCode}");
      if (response.statusCode == 200) {
        print("[AuthService] Login successful for user: $email");
        final responseData = response.body['dado'];
        print("[AuthService] Login response data: $responseData");

        if (responseData == null) {
          print("[AuthService] Invalid response data for user: $email");
          throw Exception('Dados de resposta inválidos');
        }

        final token = responseData['token'];
        final userId = responseData['idUsuario']?.toString();
        final userEmail = responseData['email'];

        if (token == null || userId == null || userEmail == null) {
          print("Incomplete authentication data for user: $email");
          throw Exception('Dados de autenticação incompletos');
        }

        await _storage.saveToken(token);
        print("[AuthService] Token saved to secure storage.");
        await _storage.saveUserId(userId);
        print("[AuthService] UserId saved to secure storage: $userId");
        await _storage.saveUserEmail(userEmail);
        print("[AuthService] UserEmail saved to secure storage: $userEmail");
        

        final psicologoInfo = await _psicologoService.getPsicologoByPacienteId(userId);
        print("[AuthService] Psicologo info from _psicologoService: $psicologoInfo");
        
        Psicologo? psicologo;
        if (psicologoInfo != null) {
          psicologo = Psicologo(
            id: psicologoInfo['id'] ?? '',
            nome: psicologoInfo['nome'] ?? '',
            crp: psicologoInfo['crp']?? '',
          );
          
          // Salvar dados do psicólogo separadamente
          await _storage.savePsicologoData(json.encode(psicologo.toJson()));
          print("[AuthService] Psicologo data saved to secure storage: ${psicologo.nome}");
        }

        final user = User(
          id: userId,
          name: userEmail.split('@')[0],
          email: userEmail,
          password: '',
          role: 'PACIENTE',
          psicologo: psicologo,
        );

        await _storage.saveUserData(json.encode(user.toJson()));
        print("[AuthService] User data saved to secure storage: ${user.email}");

        return AuthResponse(
          id: userId,
          name: user.name,
          email: userEmail,
          role: 'PACIENTE',
          message: 'Login realizado com sucesso',
          token: token,
        );
      } else {
        final errorMessage = response.body['mensagem'] ?? 'Falha na autenticação';
        print("[AuthService] Authentication failed for user: $email. Status: ${response.statusCode}, Message: $errorMessage, Body: ${response.body}");
        throw Exception(errorMessage);
      }
    } catch (e) {
      print("[AuthService] Authentication error for user: $email with exception: ${e.toString()}");
      throw Exception('Falha ao autenticar: ${e.toString()}');
    }
  }

  Future<bool> isAuthenticated() async {
    print('[AuthService] isAuthenticated called.');
    final token = await _storage.getToken();
    if (token == null) {
      print("[AuthService] User is not authenticated - no token found in storage.");
      return false;
    }

    final isExpired = JwtDecoder.isExpired(token);
    final result = !isExpired;
    print("[AuthService] Token validation: isExpired = $isExpired. isAuthenticated result: $result (token: ${token.substring(0,10)}...)");
    return result;
  }

  Future<Map<String, dynamic>?> getUserInfo() async {
    print('[AuthService] getUserInfo called.');
    try {
      print("[AuthService] Attempting to fetch user information.");
      final token = await _storage.getToken();
      if (token == null) {
        print("[AuthService] No token found in storage for getUserInfo.");
        return null;
      }

      final userData = await _storage.getUserData();
      if (userData != null) {
        print("[AuthService] User data found in storage: $userData");
        final userMap = json.decode(userData);
        
        // Verificar se já temos dados do psicólogo armazenados
        final psicologoData = await _storage.getPsicologoData();
        if (psicologoData != null && !userMap.containsKey('psicologo')) {
          final psicologoMap = json.decode(psicologoData);
          userMap['psicologo'] = psicologoMap;
        }
        
        print("[AuthService] Returning userMap from stored userData: $userMap");
        print("[AuthService] Returning reconstructed userMap: $userMap");
        return userMap;
      }

      final userId = await _storage.getUserId();
      final userEmail = await _storage.getUserEmail();
      final psicologoData = await _storage.getPsicologoData();

      if (userId != null && userEmail != null) {
        print("[AuthService] User data reconstructed from ID ($userId) and email ($userEmail).");
        final userMap = {
          'id': userId,
          'email': userEmail,
          'role': 'PACIENTE',
        };
        
        if (psicologoData != null) {
          userMap['psicologo'] = json.decode(psicologoData);
        }
        
        print("[AuthService] Returning userMap from stored userData: $userMap");
        print("[AuthService] Returning reconstructed userMap: $userMap");
        return userMap;
      }

      print("[AuthService] Decoding user data from token as fallback.");
      final decodedToken = JwtDecoder.decode(token);
      print("[AuthService] Decoded token data: $decodedToken");
      return decodedToken;
    } catch (e) {
      print('[AuthService] Error in getUserInfo: $e');
      return null;
    }
  }

  Future<Map<String, String>> getAuthHeaders() async {
    print('[AuthService] getAuthHeaders called.');
    final token = await _storage.getToken();
    if (token == null) {
      print("[AuthService] No token found for getAuthHeaders, returning empty headers.");
      return {};
    }

    print("[AuthService] Returning authorization headers with token: ${token.substring(0,10)}...");
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<void> logout() async {
    print("[AuthService] logout called. Clearing all data from storage.");
    await _storage.clearAll();
    print("[AuthService] All data cleared from storage.");
  }

  Future<String> getToken() async {
    print("[AuthService] getToken called.");
    final token = await _storage.getToken() ?? '';
    print("[AuthService] Token from storage: ${token.isNotEmpty ? token.substring(0,10) + '...' : 'empty'}");
    return token;
  }

  Future<String?> getCurrentUser() async {
    print("[AuthService] getCurrentUser (ID) called.");
    final userId = await _storage.getUserId();
    print("[AuthService] Current user ID from storage: $userId");
    return userId;
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
