import 'dart:convert';
import 'package:helppsico_mobile/core/services/http/generic_http_service.dart';

class DocumentsDataSource {
  String get baseUrl {
    
    const bool isAndroid = bool.fromEnvironment('dart.vm.android');
    return isAndroid ? 'http://10.0.2.2:7000' : 'http://localhost:7000';
  }
  final IGenericHttp _http;

  DocumentsDataSource(this._http);

  Future<HttpResponse> getDocuments() async {
    try {
      print('Attempting to fetch documents from $baseUrl/documents');
      final response = await _http.get('$baseUrl/documents');
      print('Received response with status code: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        print('Failed to fetch documents: ${response.statusCode}');
        throw Exception('Falha ao obter documentos: ${response.statusCode}');
      }
      
      print('Successfully fetched documents');
      return response;
    } catch (e) {
      print('Error connecting to server: $e');
      throw Exception('Erro ao conectar com o servidor: $e');
    }
  }

  Future<HttpResponse> uploadDocument(String filePath, Map<String, dynamic> metadata) async {
    try {
      final response = await _http.post(
        '$baseUrl/documents',
        {
          'file_path': filePath,
          'metadata': metadata,
        },
      );
      
      if (response.statusCode != 201) {
        throw Exception('Falha ao enviar documento: ${response.statusCode}');
      }
      return response;
    } catch (e) {
      throw Exception('Erro ao conectar com o servidor: $e');
    }
  }

  Future<HttpResponse> updateDocument(String documentId, Map<String, dynamic> data) async {
    try {
      final response = await _http.put(
        '$baseUrl/documents/$documentId',
        data,
      );
      
      if (response.statusCode != 200) {
        throw Exception('Falha ao atualizar documento: ${response.statusCode}');
      }
      return response;
    } catch (e) {
      throw Exception('Erro ao conectar com o servidor: $e');
    }
  }

  Future<HttpResponse> deleteDocument(String documentId) async {
    try {
      final response = await _http.delete('$baseUrl/documents/$documentId');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode != 204) {
        throw Exception('Falha ao deletar documento: ${response.statusCode}');
      }
      return response;
    } catch (e) {
      print('Error connecting to server: $e');
      throw Exception('Erro ao conectar com o servidor: $e');
    }
  }

  Future<HttpResponse> toggleFavorite(String documentId) async {
    try {
      final response = await _http.put(
        '$baseUrl/documents/$documentId/toggle-favorite',
        {},
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode != 200) {
        throw Exception('Falha ao atualizar favorito: ${response.statusCode}');
      }
      return response;
    } catch (e) {
      print('Error connecting to server: $e');
      throw Exception('Erro ao conectar com o servidor: $e');
    }
  }
}