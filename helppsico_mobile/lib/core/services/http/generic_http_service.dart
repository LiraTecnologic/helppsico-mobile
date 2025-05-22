
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:helppsico_mobile/core/services/storage/secure_storage_service.dart';

abstract interface class IGenericHttp {
  Future<HttpResponse> get(String url, {Map<String, String>? headers});
  Future<HttpResponse> post(String url, dynamic body, {Map<String, String>? headers});
  Future<HttpResponse> put(String url, dynamic body, {Map<String, String>? headers});
  Future<HttpResponse> delete(String url, {Map<String, String>? headers});
}


class GenericHttp implements IGenericHttp {
  final http.Client _client;
  final SecureStorageService _storage;

  GenericHttp({http.Client? client, SecureStorageService? storage}) : 
    _client = client ?? http.Client(),
    _storage = storage ?? SecureStorageService();
  
  @override
  Future<HttpResponse> get(String url, {Map<String, String>? headers}) async {
    try {
     
      final token = await _storage.getToken();
      final Map<String, String> authHeaders = (token != null) ? {'Authorization': 'Bearer $token'} : {};
      
  
      final Map<String, String> finalHeaders = {
        ...authHeaders,
        ...?headers,
      };
      
      final response = await _client.get(Uri.parse(url), headers: finalHeaders);
      return HttpResponse(
        statusCode: response.statusCode,
        body: json.decode(response.body),
        headers: response.headers,
      );
    } catch(e) {
      rethrow;
    }
  }

  @override
  Future<HttpResponse> post(String url, dynamic body, {Map<String, String>? headers}) async {
    try {
      
      final token = await _storage.getToken();
      final Map<String, String> authHeaders = token != null ? {'Authorization': 'Bearer $token'} : {};
      
   
      final Map<String, String> finalHeaders = {
        'Content-Type': 'application/json',
        ...authHeaders,
        ...?headers,
      };

      final response = await _client.post(
        Uri.parse(url),
        headers: finalHeaders,
        body: json.encode(body),
      );

      return HttpResponse(
        statusCode: response.statusCode,
        body: json.decode(response.body),
        headers: response.headers,
      );
    } catch(e) {
      rethrow;
    }
  }

  @override
  Future<HttpResponse> put(String url, dynamic body, {Map<String, String>? headers}) async {
    try {
      final final_headers = {
        'Content-Type': 'application/json',
        ...?headers,
      };

      final response = await _client.put(
        Uri.parse(url),
        headers: finalHeaders,
        body: json.encode(body),
      );

      return HttpResponse(
        statusCode: response.statusCode,
        body: json.decode(response.body),
        headers: response.headers,
      );
    } catch (e) {
      rethrow;
    }
  }
}

class HttpResponse {
  final int statusCode;
  final Map<String, String>? headers;
  final dynamic body;

  HttpResponse({
    required this.statusCode,
    required this.body,
    this.headers,
  });
}