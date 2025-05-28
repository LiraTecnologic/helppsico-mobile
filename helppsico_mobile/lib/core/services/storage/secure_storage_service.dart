import 'package:shared_preferences/shared_preferences.dart';

/// A service for storing and retrieving user data and authentication tokens.
///
/// This service provides methods to manage authentication tokens and user data
/// using SharedPreferences for easy access across the application.
class SecureStorageService {
  late SharedPreferences _prefs;
  
  /// Key used for storing the JWT authentication token
  static const String _tokenKey = 'jwt_token';
  
  /// Key used for storing the user data
  static const String _userDataKey = 'user_data';
  
  /// Key used for storing the user ID
  static const String _userIdKey = 'user_id';
  
  /// Key used for storing the user email
  static const String _userEmailKey = 'user_email';

  /// Creates a new instance of [SecureStorageService].
  ///
  /// Initializes SharedPreferences instance.
  SecureStorageService() {
    _initPrefs();
  }
  
  /// Initializes SharedPreferences instance
  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }


  /// Saves the authentication token.
  ///
  /// @param token The JWT token to be stored
  Future<void> saveToken(String token) async {
    try {
      await _prefs.setString(_tokenKey, token);
    } catch (e) {
      throw Exception('Failed to save token: $e');
    }
  }


  /// Retrieves the stored authentication token.
  ///
  /// @return The stored token or null if no token exists
  Future<String?> getToken() async {
    try {
      return _prefs.getString(_tokenKey);
    } catch (e) {
      throw Exception('Failed to retrieve token: $e');
    }
  }


  /// Checks if a valid token exists in storage.
  ///
  /// @return true if a non-empty token exists, false otherwise
  Future<bool> hasToken() async {
    try {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }


  /// Deletes the stored authentication token.
  Future<void> deleteToken() async {
    try {
      await _prefs.remove(_tokenKey);
    } catch (e) {
      throw Exception('Failed to delete token: $e');
    }
  }

  /// Saves user data.
  ///
  /// @param userData The user data to be stored as a JSON string
  Future<void> saveUserData(String userData) async {
    try {
      await _prefs.setString(_userDataKey, userData);
    } catch (e) {
      throw Exception('Failed to save user data: $e');
    }
  }


  /// Retrieves the stored user data.
  ///
  /// @return The stored user data as a JSON string or null if no data exists
  Future<String?> getUserData() async {
    try {
      return _prefs.getString(_userDataKey);
    } catch (e) {
      throw Exception('Failed to retrieve user data: $e');
    }
  }


  /// Deletes the stored user data.
  Future<void> deleteUserData() async {
    try {
      await _prefs.remove(_userDataKey);
    } catch (e) {
      throw Exception('Failed to delete user data: $e');
    }
  }

  /// Saves user ID.
  ///
  /// @param userId The user ID to be stored
  Future<void> saveUserId(String userId) async {
    try {
      await _prefs.setString(_userIdKey, userId);
    } catch (e) {
      throw Exception('Failed to save user ID: $e');
    }
  }


  /// Retrieves the stored user ID.
  ///
  /// @return The stored user ID or null if no ID exists
  Future<String?> getUserId() async {
    try {
      return _prefs.getString(_userIdKey);
    } catch (e) {
      throw Exception('Failed to retrieve user ID: $e');
    }
  }


  /// Saves user email.
  ///
  /// @param email The user email to be stored
  Future<void> saveUserEmail(String email) async {
    try {
      await _prefs.setString(_userEmailKey, email);
    } catch (e) {
      throw Exception('Failed to save user email: $e');
    }
  }


  /// Retrieves the stored user email.
  ///
  /// @return The stored user email or null if no email exists
  Future<String?> getUserEmail() async {
    try {
      return _prefs.getString(_userEmailKey);
    } catch (e) {
      throw Exception('Failed to retrieve user email: $e');
    }
  }

  /// Clears all stored data.
  ///
  /// This method removes all user-related data from storage.
  Future<void> clearAll() async {
    try {
      await _prefs.remove(_tokenKey);
      await _prefs.remove(_userDataKey);
      await _prefs.remove(_userIdKey);
      await _prefs.remove(_userEmailKey);
    } catch (e) {
      throw Exception('Failed to clear storage: $e');
    }
  }
}