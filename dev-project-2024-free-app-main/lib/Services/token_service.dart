// lib/services/token_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:final_app/Models/user_token.dart';

class TokenService {
  static const _tokenEndpoint = 'https://oauth2.googleapis.com/token';

  /// Refreshes the access token using the refresh token.
  Future<String?> refreshAccessToken(UserTokens tokens) async {
    try {
      final response = await http.post(
        Uri.parse(_tokenEndpoint),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'refresh_token': tokens.refreshToken,
          'grant_type': 'refresh_token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final newAccessToken = data['access_token'] as String;
        print('New Access Token: $newAccessToken');
        return newAccessToken;
      } else {
        print('Failed to refresh access token: ${response.body}');
        return null;
      }
    } catch (error) {
      print('Error refreshing access token: $error');
      return null;
    }
  }
}
