import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

abstract class StorageService {
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);
  Future<void> remove(String key);
}

class SecureStorageService implements StorageService {
  late SharedPreferences _prefs;

  static const String _tokenKey = 'jwt_token';
  static const String _userDataKey = 'user_data';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _psicologoDataKey = 'psicologo_data';
  static const String _favoriteDocumentsKey = 'favorite_documents';

  SecureStorageService._();

  static Future<SecureStorageService> create() async {
    final instance = SecureStorageService._();
    await instance._initPrefs();
    return instance;
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  Future<String?> getString(String key) async {
    try {
      return _prefs.getString(key);
    } catch (e) {
      throw Exception('Failed to retrieve value for key $key: $e');
    }
  }

  @override
  Future<void> setString(String key, String value) async {
    try {
      await _prefs.setString(key, value);
    } catch (e) {
      throw Exception('Failed to save value for key $key: $e');
    }
  }

  @override
  Future<void> remove(String key) async {
    try {
      await _prefs.remove(key);
    } catch (e) {
      throw Exception('Failed to remove value for key $key: $e');
    }
  }

  Future<void> saveToken(String token) async {
    await setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    return getString(_tokenKey);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> deleteToken() async {
    await remove(_tokenKey);
  }

  Future<void> saveUserData(String userData) async {
    await setString(_userDataKey, userData);
  }

  Future<String?> getUserData() async {
    return getString(_userDataKey);
  }

  Future<void> deleteUserData() async {
    await remove(_userDataKey);
  }

  Future<void> saveUserId(String userId) async {
    await setString(_userIdKey, userId);
  }

  Future<String?> getUserId() async {
    return getString(_userIdKey);
  }

  Future<void> saveUserEmail(String email) async {
    await setString(_userEmailKey, email);
  }

  Future<String?> getUserEmail() async {
    return getString(_userEmailKey);
  }

  Future<void> savePsicologoData(String psicologoData) async {
    await setString(_psicologoDataKey, psicologoData);
  }

  Future<String?> getPsicologoData() async {
    return getString(_psicologoDataKey);
  }

  Future<void> deletePsicologoData() async {
    await remove(_psicologoDataKey);
  }

  Future<void> clearAll() async {
    await remove(_tokenKey);
    await remove(_userDataKey);
    await remove(_userIdKey);
    await remove(_userEmailKey);
    await remove(_psicologoDataKey);
    await remove(_favoriteDocumentsKey);
  }

  Future<List<String>> getFavoriteDocumentIds() async {
    final jsonString = await getString(_favoriteDocumentsKey);
    if (jsonString != null) {
      final List<dynamic> decodedList = jsonDecode(jsonString);
      return decodedList.cast<String>().toList();
    }
    return [];
  }

  Future<void> _saveFavoriteDocumentIds(List<String> ids) async {
    final jsonString = jsonEncode(ids);
    await setString(_favoriteDocumentsKey, jsonString);
  }

  Future<bool> isDocumentFavorite(String documentId) async {
    final favoriteIds = await getFavoriteDocumentIds();
    return favoriteIds.contains(documentId);
  }

  Future<void> addFavoriteDocumentId(String documentId) async {
    final favoriteIds = await getFavoriteDocumentIds();
    if (!favoriteIds.contains(documentId)) {
      favoriteIds.add(documentId);
      await _saveFavoriteDocumentIds(favoriteIds);
    }
  }

  Future<void> removeFavoriteDocumentId(String documentId) async {
    final favoriteIds = await getFavoriteDocumentIds();
    if (favoriteIds.contains(documentId)) {
      favoriteIds.remove(documentId);
      await _saveFavoriteDocumentIds(favoriteIds);
    }
  }

  Future<void> toggleFavoriteDocumentId(String documentId) async {
    final favoriteIds = await getFavoriteDocumentIds();
    if (favoriteIds.contains(documentId)) {
      favoriteIds.remove(documentId);
    } else {
      favoriteIds.add(documentId);
    }
    await _saveFavoriteDocumentIds(favoriteIds);
  }
}
