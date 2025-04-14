
import 'dart:convert';

import 'package:http/http.dart' as http;

abstract interface class IGenericHttp {
  Future<HttpResponse> get(String url, {Map<String, String>? headers});
  // Future<HttpResponse> post(String url, dynamic body, {Map<String, String>? headers});
  // Future<HttpResponse> put(String url, dynamic body, {Map<String, String>? headers});
  // Future<HttpResponse> delete(String url, {Map<String, String>? headers});
}


class GenericHttp implements IGenericHttp {
  final http.Client _client;

  GenericHttp({http.Client? client}) : _client = client ?? http.Client();
  
  @override
  Future<HttpResponse> get(String url, {Map<String, String>? headers}) async {
    try {
      final response = await _client.get(Uri.parse(url), headers: headers);
      return HttpResponse(
        statusCode: response.statusCode,
        body: json.decode(response.body),
        headers: response.headers,
      );
    } catch(e) {
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