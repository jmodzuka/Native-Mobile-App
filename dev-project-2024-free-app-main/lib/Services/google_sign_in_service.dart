// lib/Services/google_sign_in_service.dart
import 'package:google_sign_in/google_sign_in.dart';
import 'package:final_app/Models/user_token.dart';

class GoogleSignInService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'https://www.googleapis.com/auth/calendar',
      'https://www.googleapis.com/auth/calendar.events',
      'https://www.googleapis.com/auth/calendar.events.readonly',
      'https://www.googleapis.com/auth/calendar.readonly',
      'email',
      'profile',
    ],
  );

  /// Initiates Google sign-in and returns UserTokens.
  Future<UserTokens?> getTokens() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      if (account == null) {
        print('User canceled the sign-in.');
        return null;
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      print('Access Token: ${auth.accessToken}');
      print('Refresh Token: ${auth.refreshToken}');

      return UserTokens(
        accessToken: auth.accessToken!,
        refreshToken: auth.refreshToken ?? '', // Handle missing refresh token gracefully
        userEmail: account.email,
      );
    } catch (error) {
      print('Error during Google Sign-In: $error');
      return null;
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}

extension on GoogleSignInAuthentication {
  get refreshToken => null;
}
