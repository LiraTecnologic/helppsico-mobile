import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:helppsico_mobile/core/services/storage/secure_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() {
  group('SecureStorageService Tests', () {
    late SecureStorageService secureStorageService;
    
    setUp(() async {
      // Configura SharedPreferences para testes
      SharedPreferences.setMockInitialValues({});
      secureStorageService = await SecureStorageService.create();
    });
    
    group('Token Management', () {
      test('should save and retrieve token', () async {
        // Arrange
        const token = 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9';
        
        // Act
        await secureStorageService.saveToken(token);
        final retrievedToken = await secureStorageService.getToken();
        
        // Assert
        expect(retrievedToken, token);
      });
      
      test('should return null when no token is saved', () async {
        // Act
        final token = await secureStorageService.getToken();
        
        // Assert
        expect(token, isNull);
      });
      
      test('should remove token successfully', () async {
        // Arrange
        const token = 'Bearer test-token';
        await secureStorageService.saveToken(token);
        
        // Act
        await secureStorageService.deleteToken();
        final retrievedToken = await secureStorageService.getToken();
        
        // Assert
        expect(retrievedToken, isNull);
      });
      
      test('should handle empty token', () async {
        // Arrange
        const emptyToken = '';
        
        // Act
        await secureStorageService.saveToken(emptyToken);
        final retrievedToken = await secureStorageService.getToken();
        
        // Assert
        expect(retrievedToken, emptyToken);
      });
      
      test('should handle very long token', () async {
        // Arrange
        final longToken = 'Bearer ${'a' * 1000}';
        
        // Act
        await secureStorageService.saveToken(longToken);
        final retrievedToken = await secureStorageService.getToken();
        
        // Assert
        expect(retrievedToken, longToken);
      });
    });
    
    group('User Data Management', () {
      test('should save and retrieve user data', () async {
        // Arrange
        const userData = '{"id": "123", "name": "John Doe", "email": "john@example.com"}';
        
        // Act
        await secureStorageService.saveUserData(userData);
        final retrievedUserData = await secureStorageService.getUserData();
        
        // Assert
        expect(retrievedUserData, userData);
      });
      
      test('should return null when no user data is saved', () async {
        // Act
        final userData = await secureStorageService.getUserData();
        
        // Assert
        expect(userData, isNull);
      });
      
      test('should remove user data successfully', () async {
        // Arrange
        const userData = '{"id": "123", "name": "John"}';
        await secureStorageService.saveUserData(userData);
        
        // Act
        await secureStorageService.deleteUserData();
        final retrievedUserData = await secureStorageService.getUserData();
        
        // Assert
        expect(retrievedUserData, isNull);
      });
      
      test('should handle complex user data with special characters', () async {
        // Arrange
        const userData = '{"id": "123", "name": "João da Silva & Cia", "description": "Descrição com acentos: ção, ã, é"}';
        
        // Act
        await secureStorageService.saveUserData(userData);
        final retrievedUserData = await secureStorageService.getUserData();
        
        // Assert
        expect(retrievedUserData, userData);
      });
      
      test('should handle empty user data', () async {
        // Arrange
        const emptyUserData = '';
        
        // Act
        await secureStorageService.saveUserData(emptyUserData);
        final retrievedUserData = await secureStorageService.getUserData();
        
        // Assert
        expect(retrievedUserData, emptyUserData);
      });
    });
    
    group('User ID Management', () {
      test('should save and retrieve user ID', () async {
        // Arrange
        const userId = '12345';
        
        // Act
        await secureStorageService.saveUserId(userId);
        final retrievedUserId = await secureStorageService.getUserId();
        
        // Assert
        expect(retrievedUserId, userId);
      });
      
      test('should return null when no user ID is saved', () async {
        // Act
        final userId = await secureStorageService.getUserId();
        
        // Assert
        expect(userId, isNull);
      });
      
      test('should remove user ID successfully', () async {
        // Arrange
        const userId = '12345';
        await secureStorageService.saveUserId(userId);
        
        // Act
        await secureStorageService.remove(userId);
        final retrievedUserId = await secureStorageService.getUserId();
        
        // Assert
        expect(retrievedUserId, isNull);
      });
      
      test('should handle numeric user ID as string', () async {
        // Arrange
        const userId = '999999999';
        
        // Act
        await secureStorageService.saveUserId(userId);
        final retrievedUserId = await secureStorageService.getUserId();
        
        // Assert
        expect(retrievedUserId, userId);
      });
      
      test('should handle UUID format user ID', () async {
        // Arrange
        const userId = '550e8400-e29b-41d4-a716-446655440000';
        
        // Act
        await secureStorageService.saveUserId(userId);
        final retrievedUserId = await secureStorageService.getUserId();
        
        // Assert
        expect(retrievedUserId, userId);
      });
    });
    
    group('User Email Management', () {
      test('should save and retrieve user email', () async {
        // Arrange
        const userEmail = 'john.doe@example.com';
        
        // Act
        await secureStorageService.saveUserEmail(userEmail);
        final retrievedUserEmail = await secureStorageService.getUserEmail();
        
        // Assert
        expect(retrievedUserEmail, userEmail);
      });
      
      test('should return null when no user email is saved', () async {
        // Act
        final userEmail = await secureStorageService.getUserEmail();
        
        // Assert
        expect(userEmail, isNull);
      });
      
      test('should remove user email successfully', () async {
        // Arrange
        const userEmail = 'john@example.com';
        await secureStorageService.saveUserEmail(userEmail);
        
        // Act
        await secureStorageService.remove(userEmail);
        final retrievedUserEmail = await secureStorageService.getUserEmail();
        
        // Assert
        expect(retrievedUserEmail, isNull);
      });
      
      test('should handle email with special characters', () async {
        // Arrange
        const userEmail = 'joão+test@example.com.br';
        
        // Act
        await secureStorageService.saveUserEmail(userEmail);
        final retrievedUserEmail = await secureStorageService.getUserEmail();
        
        // Assert
        expect(retrievedUserEmail, userEmail);
      });
      
      test('should handle very long email', () async {
        // Arrange
        final longEmail = '${'a' * 50}@${'b' * 50}.com';
        
        // Act
        await secureStorageService.saveUserEmail(longEmail);
        final retrievedUserEmail = await secureStorageService.getUserEmail();
        
        // Assert
        expect(retrievedUserEmail, longEmail);
      });
    });
    
    group('Favorite Documents Management', () {
      test('should save and retrieve favorite documents', () async {
        // Arrange
        const favoriteDocuments = '["doc1", "doc2", "doc3"]';
        
        // Act
        await secureStorageService.remove(favoriteDocuments);
        final retrievedFavoriteDocuments = await secureStorageService.getFavoriteDocumentIds();
        
        // Assert
        expect(retrievedFavoriteDocuments, favoriteDocuments);
      });
      
      test('should return null when no favorite documents are saved', () async {
        // Act
        final favoriteDocuments = await secureStorageService.getFavoriteDocumentIds();
        
        // Assert
        expect(favoriteDocuments, isNull);
      });
      
      test('should remove favorite documents successfully', () async {
        // Arrange
        const favoriteDocuments = '["doc1", "doc2"]';
        await secureStorageService.addFavoriteDocumentId(favoriteDocuments);
        
        // Act
        await secureStorageService.removeFavoriteDocumentId(favoriteDocuments);
        final retrievedFavoriteDocuments = await secureStorageService.getFavoriteDocumentIds();
        
        // Assert
        expect(retrievedFavoriteDocuments, isNull);
      });
      
      test('should handle empty favorite documents list', () async {
        // Arrange
        const emptyFavoriteDocuments = '[]';
        
        // Act
        await secureStorageService.addFavoriteDocumentId(emptyFavoriteDocuments);
        final retrievedFavoriteDocuments = await secureStorageService.getFavoriteDocumentIds();
        
        // Assert
        expect(retrievedFavoriteDocuments, emptyFavoriteDocuments);
      });
      
      test('should handle complex favorite documents structure', () async {
        // Arrange
        const favoriteDocuments = '[{"id": "doc1", "name": "Document 1"}, {"id": "doc2", "name": "Document 2"}]';
        final List<dynamic> decodedList = jsonDecode(favoriteDocuments);
        
        // Act
        for (final doc in decodedList) {
          await secureStorageService.addFavoriteDocumentId(doc['id']);
        }
        final retrievedFavoriteDocuments = await secureStorageService.getFavoriteDocumentIds();
        
        // Assert
        expect(retrievedFavoriteDocuments.length, 2);
        expect(retrievedFavoriteDocuments.contains('doc1'), true);
        expect(retrievedFavoriteDocuments.contains('doc2'), true);
      });
    });
    
    group('Clear All Data', () {
      test('should clear all stored data', () async {
        // Arrange
        await secureStorageService.saveToken('test-token');
        await secureStorageService.saveUserData('{"id": "123"}');
        await secureStorageService.saveUserId('123');
        await secureStorageService.saveUserEmail('test@example.com');
        await secureStorageService.addFavoriteDocumentId('doc1');
        
        // Act
        await secureStorageService.clearAll();
        
        // Assert
        expect(await secureStorageService.getToken(), isNull);
        expect(await secureStorageService.getUserData(), isNull);
        expect(await secureStorageService.getUserId(), isNull);
        expect(await secureStorageService.getUserEmail(), isNull);
        expect(await secureStorageService.getFavoriteDocumentIds(), isNull);
      });
      
      test('should handle clear all when no data exists', () async {
        // Act & Assert - Should not throw any exception
        expect(() async => await secureStorageService.clearAll(), returnsNormally);
      });
    });
    
    group('Data Persistence', () {
      test('should persist data across service instances', () async {
        // Arrange
        const token = 'persistent-token';
        const userData = '{"id": "persistent-user"}';
        
        // Act - Save data with first instance
        await secureStorageService.saveToken(token);
        await secureStorageService.saveUserData(userData);
        
        // Create new instance
        final newSecureStorageService = await SecureStorageService.create();
        
        // Assert - Data should be available in new instance
        expect(await newSecureStorageService.getToken(), token);
        expect(await newSecureStorageService.getUserData(), userData);
      });
    });
    
    group('Concurrent Operations', () {
      test('should handle concurrent save and retrieve operations', () async {
        // Arrange
        const token1 = 'token1';
        const token2 = 'token2';
        const userData1 = '{"id": "user1"}';
        const userData2 = '{"id": "user2"}';
        
        // Act - Perform concurrent operations
        await Future.wait([
          secureStorageService.saveToken(token1),
          secureStorageService.saveUserData(userData1),
          secureStorageService.saveToken(token2),
          secureStorageService.saveUserData(userData2),
        ]);
        
        // Assert - Last saved values should be retrieved
        final retrievedToken = await secureStorageService.getToken();
        final retrievedUserData = await secureStorageService.getUserData();
        
        expect(retrievedToken, anyOf(token1, token2));
        expect(retrievedUserData, anyOf(userData1, userData2));
      });
    });
    
    group('Edge Cases', () {
      test('should handle null values gracefully', () async {
        // Act & Assert - Should not throw exceptions
        expect(() async => await secureStorageService.saveToken(''), returnsNormally);
        expect(() async => await secureStorageService.saveUserData(''), returnsNormally);
        expect(() async => await secureStorageService.saveUserId(''), returnsNormally);
        expect(() async => await secureStorageService.saveUserEmail(''), returnsNormally);
        expect(() async => await secureStorageService.addFavoriteDocumentId(''), returnsNormally);
      });
      
      test('should handle very large data', () async {
        // Arrange
        final largeData = 'x' * 100000; // 100KB of data
        
        // Act
        await secureStorageService.saveUserData(largeData);
        final retrievedData = await secureStorageService.getUserData();
        
        // Assert
        expect(retrievedData, largeData);
      });
      
      test('should handle special JSON characters', () async {
        // Arrange
        const specialData = '{"message": "Hello \"world\" with \\backslashes\\ and \nline breaks"}';
        
        // Act
        await secureStorageService.saveUserData(specialData);
        final retrievedData = await secureStorageService.getUserData();
        
        // Assert
        expect(retrievedData, specialData);
      });
    });
  });
}