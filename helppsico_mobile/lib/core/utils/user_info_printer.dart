import 'package:helppsico_mobile/core/services/auth/auth_service.dart';
import 'package:helppsico_mobile/core/services/storage/secure_storage_service.dart';

class UserInfoPrinter {
  final AuthService _authService;
  final SecureStorageService _storage;

  UserInfoPrinter({
    required AuthService authService,
    required SecureStorageService storage,
  }) : _authService = authService, _storage = storage;

  Future<void> printUserInfo() async {
    try {
      final token = await _authService.getToken();
      final userData = await _storage.getUserData();
      
      print('Token do usuário: $token');
      print('Dados do usuário: $userData');
    } catch (e) {
      print('Erro ao recuperar informações do usuário: $e');
    }
  }
}