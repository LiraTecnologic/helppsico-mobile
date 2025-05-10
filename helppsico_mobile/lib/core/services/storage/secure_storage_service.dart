import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;
  static const String _tokenKey = 'jwt_token';
  static const String _userDataKey = 'user_data';

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();


  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }


  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }


  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }


  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  // Salvar dados do usuário
  Future<void> saveUserData(String userData) async {
    await _storage.write(key: _userDataKey, value: userData);
  }


  Future<String?> getUserData() async {
    return await _storage.read(key: _userDataKey);
  }


  Future<void> deleteUserData() async {
    await _storage.delete(key: _userDataKey);
  }

 
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}