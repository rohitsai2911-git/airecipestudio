import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'api_exceptions.dart';

class ApiClient {
  final String baseUrl;
  final http.Client _client = http.Client();

  ApiClient(this.baseUrl);

  Map<String, String> get _headers {
    final session = Supabase.instance.client.auth.currentSession;
    return {
      'Content-Type': 'application/json',
      if (session != null) 'Authorization': 'Bearer ${session.accessToken}',
    };
  }

  Future<dynamic> get(String path, {Map<String, String>? queryParams}) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: queryParams);
    final response = await _client.get(uri, headers: _headers);
    return _handleResponse(response);
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await _client.post(uri, headers: _headers, body: body != null ? jsonEncode(body) : null);
    return _handleResponse(response);
  }

  Future<Uint8List> postBinary(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = Map<String, String>.from(_headers);
    headers['Content-Type'] = 'application/json';
    final response = await _client.post(uri, headers: headers, body: body != null ? jsonEncode(body) : null);
    if (response.statusCode == 401) throw UnauthorizedException();
    if (response.statusCode >= 400) throw ApiException(response.body, statusCode: response.statusCode);
    return response.bodyBytes;
  }

  Future<dynamic> patch(String path, {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await _client.patch(uri, headers: _headers, body: jsonEncode(body));
    return _handleResponse(response);
  }

  Future<dynamic> delete(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await _client.delete(uri, headers: _headers);
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode == 401) throw UnauthorizedException();
    if (response.statusCode == 404) throw NotFoundException(response.request?.url.toString() ?? '');
    if (response.statusCode >= 400) throw ApiException(response.body, statusCode: response.statusCode);
    if (response.body.isEmpty) return null;
    return jsonDecode(response.body);
  }
}
