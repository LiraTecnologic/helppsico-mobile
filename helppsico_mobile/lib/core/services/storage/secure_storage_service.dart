import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A service for securely storing and retrieving sensitive data.
///
/// This service provides methods to manage authentication tokens and user data
/// using secure storage mechanisms provided by the device.
class SecureStorageService {
  final FlutterSecureStorage _storage;
  
  /// Key used for storing the JWT authentication token
  static const String _tokenKey = 'jwt_token';
  
  /// Key used for storing the user data
  static const String _userDataKey = 'user_data';

  /// Creates a new instance of [SecureStorageService].
  ///
  /// If [storage] is not provided, a default [FlutterSecureStorage] instance is used.
  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();


  /// Saves the authentication token securely.
  ///
  /// @param token The JWT token to be stored
  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (e) {
      throw Exception('Failed to save token: $e');
    }
  }


  /// Retrieves the stored authentication token.
  ///
  /// @return The stored token or null if no token exists
  Future<String?> getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
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
      await _storage.delete(key: _tokenKey);
    } catch (e) {
      throw Exception('Failed to delete token: $e');
    }
  }

  /// Saves the user data securely.
  ///
  /// @param userData JSON string containing user information
  Future<void> saveUserData(String userData) async {
    try {
      await _storage.write(key: _userDataKey, value: userData);
    } catch (e) {
      throw Exception('Failed to save user data: $e');
    }
  }


  /// Retrieves the stored user data.
  ///
  /// @return The stored user data or null if no data exists
  Future<String?> getUserData() async {
    try {
      return await _storage.read(key: _userDataKey);
    } catch (e) {
      throw Exception('Failed to retrieve user data: $e');
    }
  }


  /// Deletes the stored user data.
  Future<void> deleteUserData() async {
    try {
      await _storage.delete(key: _userDataKey);
    } catch (e) {
      throw Exception('Failed to delete user data: $e');
    }
  }

  /// Clears all stored data including tokens and user information.
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw Exception('Failed to clear all data: $e');
    }
  }
}