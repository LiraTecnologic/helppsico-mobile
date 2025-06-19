import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:helppsico_mobile/core/services/storage/secure_storage_service.dart';



abstract class IGenericHttp {
  Future<HttpResponse> get(String url, {Map<String, String>? headers});
  Future<HttpResponse> post(String url, dynamic body, {Map<String, String>? headers});
  Future<HttpResponse> put(String url, dynamic body, {Map<String, String>? headers});
  Future<HttpResponse> delete(String url, {Map<String, String>? headers});
}

class GenericHttp implements IGenericHttp {
  final http.Client _client;
  final SecureStorageService _storage;

  GenericHttp({http.Client? client, SecureStorageService? secureStorageService}) : 
    _client = client ?? http.Client(),
    _storage = secureStorageService ?? GetIt.instance.get<SecureStorageService>();
  
  @override
  Future<HttpResponse> get(String url, {Map<String, String>? headers}) async {
    final Map<String, String> requestHeaders = await _prepareHeaders(headers);
    final response = await _client.get(Uri.parse(url), headers: requestHeaders);
    return _processResponse(response);
  }

  @override
  Future<HttpResponse> post(String url, dynamic body, {Map<String, String>? headers}) async {
    final Map<String, String> requestHeaders = await _prepareHeaders(headers);
    final encodedBody = body is String ? body : json.encode(body);
    final response = await _client.post(
      Uri.parse(url), 
      headers: requestHeaders,
      body: encodedBody
    );
    return _processResponse(response);
  }

  @override
  Future<HttpResponse> put(String url, dynamic body, {Map<String, String>? headers}) async {
    final Map<String, String> requestHeaders = await _prepareHeaders(headers);
    final encodedBody = body is String ? body : json.encode(body);
    final response = await _client.put(
      Uri.parse(url), 
      headers: requestHeaders,
      body: encodedBody
    );
    return _processResponse(response);
  }

  @override
  Future<HttpResponse> delete(String url, {Map<String, String>? headers}) async {
    final Map<String, String> requestHeaders = await _prepareHeaders(headers);
    final response = await _client.delete(Uri.parse(url), headers: requestHeaders);
    return _processResponse(response);
  }

  Future<Map<String, String>> _prepareHeaders(Map<String, String>? customHeaders) async {
    final Map<String, String> headers = customHeaders ?? {};
    
    // Adiciona Content-Type se não estiver presente
    if (!headers.containsKey('Content-Type')) {
      headers['Content-Type'] = 'application/json';
    }
    
    // Adiciona token de autorização se disponível
    final token = await _storage.getToken();
    if (token != null && !headers.containsKey('Authorization')) {
      headers['Authorization'] = token.startsWith('Bearer ') ? token : 'Bearer $token';
    }
    
    return headers;
  }
  
  HttpResponse _processResponse(http.Response response) {
    return HttpResponse(
      statusCode: response.statusCode,
      body: response.body,
      headers: response.headers,
    );
  }
}

class HttpResponse {
  final int statusCode;
  final dynamic body;
  final Map<String, String>? headers;

  HttpResponse({
    required this.statusCode,
    required this.body,
    this.headers,
  });
}
