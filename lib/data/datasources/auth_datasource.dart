import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:kendin/core/errors/app_exception.dart';
import 'package:kendin/data/datasources/supabase_client_setup.dart';
import 'package:kendin/data/models/user_model.dart';

/// Handles all Supabase auth operations.
class AuthDatasource {
  SupabaseClient get _client => SupabaseClientSetup.client;
  GoTrueClient get _auth => _client.auth;

  /// Signs in anonymously. Used on first launch.
  Future<UserModel> signInAnonymously() async {
    try {
      final response = await _auth.signInAnonymously();
      return _userFromSession(response);
    } catch (e) {
      throw AuthException('Anonymous sign-in failed: $e');
    }
  }

  /// Returns the current user from the session, or null.
  Future<UserModel?> getCurrentUser() async {
    final session = _auth.currentSession;
    if (session == null) return null;

    final userId = session.user.id;
    try {
      final data =
          await _client.from('users').select().eq('id', userId).single();
      return UserModel.fromJson({
        ...data,
        'is_anonymous': session.user.userMetadata?['is_anonymous'] ?? false,
        'email': session.user.email,
      });
    } catch (e) {
      throw AuthException('Failed to fetch user: $e');
    }
  }

  /// Links anonymous account with Apple.
  Future<UserModel> linkWithApple() async {
    try {
      final rawNonce = _generateNonce();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email],
        nonce: hashedNonce,
      );

      final response = await _auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: credential.identityToken!,
        nonce: rawNonce,
      );

      return _userFromSession(response);
    } catch (e) {
      throw AuthException('Apple sign-in failed: $e');
    }
  }

  /// Links anonymous account with Google.
  Future<UserModel> linkWithGoogle() async {
    try {
      const webClientId = 'YOUR_GOOGLE_WEB_CLIENT_ID';
      const iosClientId = 'YOUR_GOOGLE_IOS_CLIENT_ID';

      final googleSignIn = GoogleSignIn(
        clientId: iosClientId,
        serverClientId: webClientId,
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthException('Google sign-in cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw const AuthException('No ID token from Google');
      }

      final response = await _auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      return _userFromSession(response);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Google sign-in failed: $e');
    }
  }

  /// Links anonymous account with email/password.
  Future<UserModel> linkWithEmail(String email, String password) async {
    try {
      await _auth.updateUser(
        UserAttributes(email: email, password: password),
      );
      final user = await getCurrentUser();
      if (user == null) throw const AuthException('User not found after link');
      return user;
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Email link failed: $e');
    }
  }

  /// Signs out.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Auth state stream.
  Stream<UserModel?> get authStateChanges {
    return _auth.onAuthStateChange.asyncMap((event) async {
      if (event.session == null) return null;
      return getCurrentUser();
    });
  }

  // ─── Helpers ─────────────────────────────────────

  UserModel _userFromSession(AuthResponse response) {
    final user = response.user;
    if (user == null) throw const AuthException('No user in response');

    return UserModel(
      id: user.id,
      isPremium: false,
      premiumMissTokens: 3,
      email: user.email,
      isAnonymous: user.userMetadata?['is_anonymous'] == true,
    );
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }
}
