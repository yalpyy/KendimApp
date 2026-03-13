import 'package:flutter/foundation.dart';
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
  ///
  /// If the session exists but the `users` table row is missing (e.g. no
  /// database trigger), an initial row is created automatically via upsert.
  Future<UserModel?> getCurrentUser() async {
    final session = _auth.currentSession;
    if (session == null) return null;

    final userId = session.user.id;
    final isAnon = session.user.userMetadata?['is_anonymous'] == true;
    final email = session.user.email;
    final verified = session.user.emailConfirmedAt != null;
    final displayName =
        session.user.userMetadata?['display_name'] as String?;

    try {
      final data = await _client
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data != null) {
        return UserModel.fromJson({
          ...data,
          'is_anonymous': isAnon,
          'email': email,
          'email_verified': verified,
        });
      }

      // Row missing — create it so downstream code can proceed.
      debugPrint('[AuthDatasource] No users row for $userId — creating one');
      final now = DateTime.now().toIso8601String();
      await _client.from('users').upsert({
        'id': userId,
        'is_premium': false,
        'is_admin': false,
        'premium_miss_tokens': 3,
        'display_name': displayName,
        'created_at': now,
        'updated_at': now,
      });

      return UserModel(
        id: userId,
        isPremium: false,
        premiumMissTokens: 3,
        email: email,
        displayName: displayName,
        isAnonymous: isAnon,
        emailVerified: verified,
        isAdmin: false,
      );
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

      // Send welcome email via Resend (fire-and-forget, non-blocking).
      _sendEmail('welcome', user.email ?? email, displayName);

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

  /// Sends a password reset email via Supabase Auth.
  Future<void> resetPassword(String email) async {
    try {
      await _auth.resetPasswordForEmail(email);
    } catch (e) {
      throw AuthException('Password reset failed: $e');
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

  /// Deletes the current user's account and all associated data.
  ///
  /// 1. Delete user data from all tables
  /// 2. Call edge function to delete auth record
  /// 3. Sign out locally
  Future<void> deleteAccount(String userId) async {
    try {
      await _client.from('weekly_reflections').delete().eq('user_id', userId);
      await _client.from('entries').delete().eq('user_id', userId);
      await _client.from('users').delete().eq('id', userId);

      // Delete auth record via edge function (client can't call admin API).
      try {
        await _client.functions.invoke(
          'delete-user',
          body: {'user_id': userId},
        );
      } catch (e) {
        debugPrint('[AuthDatasource] Edge function delete-user failed: $e');
      }

      await _auth.signOut();
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Account deletion failed: $e');
    }
  }

  /// Updates the display name for the current user.
  Future<void> updateDisplayName(String userId, String newName) async {
    try {
      await _client.from('users').update({
        'display_name': newName,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      await _auth.updateUser(UserAttributes(data: {'display_name': newName}));
    } catch (e) {
      throw AuthException('Failed to update display name: $e');
    }
  }

  // ─── Admin queries ─────────────────────────────────

  /// Returns extended app statistics for the admin panel.
  Future<Map<String, dynamic>> getAdminStats() async {
    try {
      final users = await _client.from('users').select('id');
      final premiumUsers =
          await _client.from('users').select('id').eq('is_premium', true);
      final entries = await _client.from('entries').select('id');
      final reflections =
          await _client.from('weekly_reflections').select('id');

      // Top 10 users by reflection count
      final topReflectionUsers = await _client
          .from('weekly_reflections')
          .select('user_id')
          .order('created_at', ascending: false);

      // Top 10 users by entry count (streak proxy)
      final topEntryUsers = await _client
          .from('entries')
          .select('user_id')
          .order('created_at', ascending: false);

      // Count reflections per user
      final reflectionCounts = <String, int>{};
      for (final r in topReflectionUsers as List) {
        final uid = r['user_id'] as String;
        reflectionCounts[uid] = (reflectionCounts[uid] ?? 0) + 1;
      }
      final sortedReflections = reflectionCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      // Count entries per user
      final entryCounts = <String, int>{};
      for (final e in topEntryUsers as List) {
        final uid = e['user_id'] as String;
        entryCounts[uid] = (entryCounts[uid] ?? 0) + 1;
      }
      final sortedEntries = entryCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      // Fetch display names for top users
      final topUserIds = <String>{
        ...sortedReflections.take(10).map((e) => e.key),
        ...sortedEntries.take(10).map((e) => e.key),
      };
      final userNames = <String, String>{};
      if (topUserIds.isNotEmpty) {
        final userData = await _client
            .from('users')
            .select('id, display_name')
            .inFilter('id', topUserIds.toList());
        for (final u in userData as List) {
          userNames[u['id'] as String] = (u['display_name'] as String?) ?? '';
        }
      }

      return {
        'total_users': (users as List).length,
        'premium_users': (premiumUsers as List).length,
        'free_users': (users).length - (premiumUsers).length,
        'total_entries': (entries as List).length,
        'total_reflections': (reflections as List).length,
        'top_reflections': sortedReflections
            .take(10)
            .map((e) => {
                  'user_id': e.key,
                  'display_name': userNames[e.key] ?? '',
                  'count': e.value,
                })
            .toList(),
        'top_streaks': sortedEntries
            .take(10)
            .map((e) => {
                  'user_id': e.key,
                  'display_name': userNames[e.key] ?? '',
                  'count': e.value,
                })
            .toList(),
      };
    } catch (e) {
      throw AuthException('Failed to fetch admin stats: $e');
    }
  }

  /// Returns a paginated list of users with optional search.
  Future<List<Map<String, dynamic>>> getUsers({
    int page = 0,
    int pageSize = 10,
    String? search,
  }) async {
    try {
      var query = _client.from('users').select();

      if (search != null && search.isNotEmpty) {
        query = query.or('display_name.ilike.%$search%,id.ilike.%$search%');
      }

      final data = await query
          .order('created_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw AuthException('Failed to fetch users: $e');
    }
  }

  /// Returns a list of all users (for admin).
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final data = await _client
          .from('users')
          .select()
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw AuthException('Failed to fetch users: $e');
    }
  }

  /// Returns paginated reflections (for admin debug view).
  Future<List<Map<String, dynamic>>> getReflections({
    int page = 0,
    int pageSize = 10,
  }) async {
    try {
      final data = await _client
          .from('weekly_reflections')
          .select()
          .order('created_at', ascending: false)
          .range(page * pageSize, (page + 1) * pageSize - 1);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw AuthException('Failed to fetch reflections: $e');
    }
  }

  /// Returns all reflections (for admin debug view).
  Future<List<Map<String, dynamic>>> getAllReflections() async {
    try {
      final data = await _client
          .from('weekly_reflections')
          .select()
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (e) {
      throw AuthException('Failed to fetch reflections: $e');
    }
  }

  /// Grants premium to a user until the given date.
  Future<void> grantPremium(String userId, DateTime until) async {
    try {
      await _client.from('users').update({
        'is_premium': true,
        'premium_started_at': DateTime.now().toIso8601String(),
        'premium_expires_at': until.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      throw AuthException('Failed to grant premium: $e');
    }
  }

  /// Revokes premium from a user.
  Future<void> revokePremium(String userId) async {
    try {
      await _client.from('users').update({
        'is_premium': false,
        'premium_expires_at': null,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);
    } catch (e) {
      throw AuthException('Failed to revoke premium: $e');
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

  /// Sends a transactional email via the send-email edge function.
  /// Fire-and-forget — does not throw on failure.
  void _sendEmail(String emailType, String toEmail, String? toName) {
    _client.functions
        .invoke(
          'send-email',
          body: {
            'email_type': emailType,
            'to_email': toEmail,
            'to_name': toName,
          },
        )
        .then((_) => debugPrint('[AuthDatasource] Email sent: $emailType → $toEmail'))
        .catchError((e) => debugPrint('[AuthDatasource] Email send failed: $e'));
  }

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
