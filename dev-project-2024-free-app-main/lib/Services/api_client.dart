// lib/services/api_client.dart

import 'package:http/http.dart' as http;

/// A custom HTTP client to add Google OAuth tokens to requests.
class GoogleAuthClient extends http.BaseClient {
  final String accessToken;
  final http.Client _client = http.Client();

  GoogleAuthClient(this.accessToken); // Constructor

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $accessToken'; // Add the token
    return _client.send(request);
  }
}
