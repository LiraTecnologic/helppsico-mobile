import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/document_model.dart';

class DocumentRepository {
  // URL local para desenvolvimento
  final String baseUrl = 'http://10.0.2.2:7000'; // Para emulador Android

  Future<List<DocumentModel>> getDocuments() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/documents'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => DocumentModel.fromJson(json)).toList();
      } else {
        throw Exception('Falha ao carregar documentos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao buscar documentos: $e');
    }
  }

  Future<DocumentModel> uploadDocument(DocumentModel document) async {
    try {
      // Criar um FormData para enviar o arquivo
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/documents'),
      );

      // Adicionar campos do documento
      request.fields['title'] = document.title;
      request.fields['description'] = document.description;
      request.fields['type'] = document.type.toString().split('.').last;
      request.fields['patientId'] = document.patientId;
      request.fields['patientName'] = document.patientName;

      // Adicionar o arquivo se houver
      if (document.fileUrl.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            document.fileUrl,
          ),
        );
      }

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonData = json.decode(responseData);

      if (response.statusCode == 201) {
        return DocumentModel.fromJson(jsonData);
      } else {
        throw Exception('Falha ao fazer upload do documento: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao fazer upload do documento: $e');
    }
  }

  Future<void> deleteDocument(String documentId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/documents/$documentId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 204) {
        throw Exception('Falha ao deletar documento: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao deletar documento: $e');
    }
  }

  Future<DocumentModel> updateDocument(DocumentModel document) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/documents/${document.id}'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(document.toJson()),
      );

      if (response.statusCode == 200) {
        return DocumentModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Falha ao atualizar documento: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao atualizar documento: $e');
    }
  }
} 