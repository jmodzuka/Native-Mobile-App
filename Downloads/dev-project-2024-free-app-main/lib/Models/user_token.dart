// lib/models/user_tokens.dart

class UserTokens {
  final String accessToken;
  final String refreshToken;
  final String userEmail; // Add user email field

  UserTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.userEmail,
  });

  // Factory constructor to create UserTokens from a JSON response
  factory UserTokens.fromJson(Map<String, dynamic> json) {
    return UserTokens(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      userEmail: json['email'] ?? '', // Handle missing email gracefully
    );
  }

  // Convert the UserTokens instance back to JSON if needed
  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'email': userEmail,
      };
}
