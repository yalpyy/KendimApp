import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

import 'package:kendin/core/errors/app_exception.dart';
import 'package:kendin/data/datasources/supabase_client_setup.dart';
import 'package:kendin/data/models/user_model.dart';

/// Handles all Supabase auth operations.
///
/// Supports anonymous sign-in and email/password auth only.
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
        'email_verified': session.user.emailConfirmedAt != null,
      });
    } catch (e) {
      throw AuthException('Failed to fetch user: $e');
    }
  }

  /// Creates a new email/password account.
  Future<UserModel> signUp(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final response = await _auth.signUp(
        email: email,
        password: password,
        data: {'display_name': displayName},
      );

      final user = response.user;
      if (user == null) throw const AuthException('No user in signup response');

      // Update the display_name in our users table.
      await _client.from('users').update({
        'display_name': displayName,
      }).eq('id', user.id);

      return UserModel(
        id: user.id,
        isPremium: false,
        premiumMissTokens: 3,
        email: user.email,
        displayName: displayName,
        isAnonymous: false,
        emailVerified: false,
      );
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Sign up failed: $e');
    }
  }

  /// Signs in with existing email/password.
  Future<UserModel> signIn(String email, String password) async {
    try {
      await _auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = await getCurrentUser();
      if (user == null) throw const AuthException('User not found after login');
      return user;
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Sign in failed: $e');
    }
  }

  /// Resends the email verification link.
  Future<void> resendVerificationEmail() async {
    try {
      final email = _auth.currentUser?.email;
      if (email == null) {
        throw const AuthException('No email to verify');
      }
      await _auth.resend(type: OtpType.email, email: email);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Failed to resend verification: $e');
    }
  }

  /// Checks if the current user's email is verified.
  Future<bool> isEmailVerified() async {
    try {
      // Refresh the session to get latest confirmation status.
      await _auth.refreshSession();
      final user = _auth.currentUser;
      return user?.emailConfirmedAt != null;
    } catch (e) {
      return false;
    }
  }

  /// Migrates data from anonymous account to email account via edge function.
  Future<void> migrateAnonymousData(
    String oldUserId,
    String newUserId,
  ) async {
    try {
      final response = await _client.functions.invoke(
        'migrate-user-data',
        body: {
          'old_user_id': oldUserId,
          'new_user_id': newUserId,
        },
      );

      if (response.status != 200) {
        throw AuthException(
          'Migration failed with status ${response.status}',
        );
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Data migration failed: $e');
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
      displayName: user.userMetadata?['display_name'] as String?,
      isAnonymous: user.userMetadata?['is_anonymous'] == true,
      emailVerified: user.emailConfirmedAt != null,
    );
  }
}
