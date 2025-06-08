import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageService {
  late SharedPreferences _prefs;
  

  static const String _tokenKey = 'jwt_token';
  static const String _userDataKey = 'user_data';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _psicologoDataKey = 'psicologo_data';



  SecureStorageService._();

  static Future <SecureStorageService> create() async {
    final instance = SecureStorageService._();
    await instance._initPrefs();
    return instance;
  }
 
  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveToken(String token) async {
    try {
      await _prefs.setString(_tokenKey, token);
    } catch (e) {
      throw Exception('Failed to save token: $e');
    }
  }


  Future<String?> getToken() async {
    try {
      return _prefs.getString(_tokenKey);
    } catch (e) {
      throw Exception('Failed to retrieve token: $e');
    }
  }


  Future<bool> hasToken() async {
    try {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  
  Future<void> deleteToken() async {
    try {
      await _prefs.remove(_tokenKey);
    } catch (e) {
      throw Exception('Failed to delete token: $e');
    }
  }

  Future<void> saveUserData(String userData) async {
    try {
      await _prefs.setString(_userDataKey, userData);
    } catch (e) {
      throw Exception('Failed to save user data: $e');
    }
  }


  Future<String?> getUserData() async {
    try {
      return _prefs.getString(_userDataKey);
    } catch (e) {
      throw Exception('Failed to retrieve user data: $e');
    }
  }


  Future<void> deleteUserData() async {
    try {
      await _prefs.remove(_userDataKey);
    } catch (e) {
      throw Exception('Failed to delete user data: $e');
    }
  }

  Future<void> saveUserId(String userId) async {
    try {
      await _prefs.setString(_userIdKey, userId);
    } catch (e) {
      throw Exception('Failed to save user ID: $e');
    }
  }

  Future<String?> getUserId() async {
    try {
      return _prefs.getString(_userIdKey);
    } catch (e) {
      throw Exception('Failed to retrieve user ID: $e');
    }
  }

  Future<void> saveUserEmail(String email) async {
    try {
      await _prefs.setString(_userEmailKey, email);
    } catch (e) {
      throw Exception('Failed to save user email: $e');
    }
  }


  Future<String?> getUserEmail() async {
    try {
      return _prefs.getString(_userEmailKey);
    } catch (e) {
      throw Exception('Failed to retrieve user email: $e');
    }
  }

  Future<void> savePsicologoData(String psicologoData) async {
    try {
      await _prefs.setString(_psicologoDataKey, psicologoData);
    } catch (e) {
      throw Exception('Failed to save psicologo data: $e');
    }
  }

  Future<String?> getPsicologoData() async {
    try {
      return _prefs.getString(_psicologoDataKey);
    } catch (e) {
      throw Exception('Failed to retrieve psicologo data: $e');
    }
  }

  Future<void> deletePsicologoData() async {
    try {
      await _prefs.remove(_psicologoDataKey);
    } catch (e) {
      throw Exception('Failed to delete psicologo data: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      await _prefs.remove(_tokenKey);
      await _prefs.remove(_userDataKey);
      await _prefs.remove(_userIdKey);
      await _prefs.remove(_userEmailKey);
      await _prefs.remove(_psicologoDataKey);
    } catch (e) {
      throw Exception('Failed to clear storage: $e');
    }
  }
}