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

  GenericHttp({http.Client? client, SecureStorageService? storage,  secureStorageService}) : 
    _client = client ?? http.Client(),
    _storage =  GetIt.instance.get<SecureStorageService>();
  
  @override
  Future<HttpResponse> get(String url, {Map<String, String>? headers}) async {
    return _executeRequest((url) => _client.get(Uri.parse(url), headers: headers));
  }

  @override
  Future<HttpResponse> post(String url, dynamic body, {Map<String, String>? headers}) async {
    return _executeRequest((url) => _client.post(Uri.parse(url), headers: headers, body: json.encode(body)));
  }

  @override
  Future<HttpResponse> put(String url, dynamic body, {Map<String, String>? headers}) async {
    return _executeRequest((url) => _client.put(Uri.parse(url), headers: headers, body: json.encode(body)));
  }

  @override
  Future<HttpResponse> delete(String url, {Map<String, String>? headers}) async {
    return _executeRequest((url) => _client.delete(Uri.parse(url), headers: headers));
  }

  Future<HttpResponse> _executeRequest(Future<http.Response> Function(String) request) async {
    try {
      final token = await _storage.getToken();
      final Map<String, String> authHeaders = (token != null) ? {'Authorization': 'Bearer $token'} : {};
      final response = await request((authHeaders.isNotEmpty ? {'...?headers': authHeaders} : null) as String);
      return HttpResponse(
        statusCode: response.statusCode,
        body: response.body.isEmpty ? {} : json.decode(response.body),
        headers: response.headers,
      );
    } catch(e) {
      rethrow;
    }
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
