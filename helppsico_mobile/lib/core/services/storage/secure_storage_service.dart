import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;
  static const String _tokenKey = 'jwt_token';
  static const String _userDataKey = 'user_data';

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  // Salvar o token JWT
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Recuperar o token JWT
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Verificar se o token existe
  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Remover o token JWT (logout)
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // Salvar dados do usuário
  Future<void> saveUserData(String userData) async {
    await _storage.write(key: _userDataKey, value: userData);
  }

  // Recuperar dados do usuário
  Future<String?> getUserData() async {
    return await _storage.read(key: _userDataKey);
  }

  // Remover dados do usuário
  Future<void> deleteUserData() async {
    await _storage.delete(key: _userDataKey);
  }

  // Limpar todos os dados (logout completo)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}