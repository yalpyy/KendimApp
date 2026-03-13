import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:kendin/data/datasources/supabase_client_setup.dart';

/// Handles Firebase Cloud Messaging (FCM) for remote push notifications.
///
/// Registers the device token with Supabase so the admin can
/// send push notifications to users via the send-push edge function.
class PushNotificationService {
  PushNotificationService();

  FirebaseMessaging? _messaging;
  String? _currentToken;

  /// Initialize Firebase + FCM. Call after Supabase init.
  Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      _messaging = FirebaseMessaging.instance;

      // Request permission (iOS shows dialog, Android auto-grants)
      final settings = await _messaging!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint(
        '[PushNotificationService] Permission: ${settings.authorizationStatus}',
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        await _registerToken();
        _listenForTokenRefresh();
      }

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    } catch (e) {
      debugPrint('[PushNotificationService] Init failed: $e');
    }
  }

  /// Get and store the FCM token in Supabase.
  Future<void> _registerToken() async {
    try {
      // For iOS, use APNs token via FCM
      final token = await _messaging?.getToken();
      if (token == null) return;

      _currentToken = token;
      debugPrint('[PushNotificationService] Token: ${token.substring(0, 20)}...');

      await _saveTokenToSupabase(token);
    } catch (e) {
      debugPrint('[PushNotificationService] Token registration failed: $e');
    }
  }

  /// Listen for token refresh and update Supabase.
  void _listenForTokenRefresh() {
    _messaging?.onTokenRefresh.listen((newToken) async {
      debugPrint('[PushNotificationService] Token refreshed');

      // Remove old token
      if (_currentToken != null) {
        await _removeTokenFromSupabase(_currentToken!);
      }

      _currentToken = newToken;
      await _saveTokenToSupabase(newToken);
    });
  }

  /// Save token to Supabase device_tokens table.
  Future<void> _saveTokenToSupabase(String token) async {
    try {
      final client = SupabaseClientSetup.client;
      final userId = client.auth.currentUser?.id;
      if (userId == null) return;

      final platform = defaultTargetPlatform == TargetPlatform.iOS
          ? 'ios'
          : 'android';

      await client.from('device_tokens').upsert(
        {
          'user_id': userId,
          'token': token,
          'platform': platform,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'user_id,token',
      );
    } catch (e) {
      debugPrint('[PushNotificationService] Save token failed: $e');
    }
  }

  /// Remove token from Supabase (on logout or token refresh).
  Future<void> _removeTokenFromSupabase(String token) async {
    try {
      final client = SupabaseClientSetup.client;
      await client.from('device_tokens').delete().eq('token', token);
    } catch (e) {
      debugPrint('[PushNotificationService] Remove token failed: $e');
    }
  }

  /// Handle foreground messages (app is open).
  void _onForegroundMessage(RemoteMessage message) {
    debugPrint(
      '[PushNotificationService] Foreground message: ${message.notification?.title}',
    );
  }

  /// Remove device token on sign out.
  Future<void> onSignOut() async {
    if (_currentToken != null) {
      await _removeTokenFromSupabase(_currentToken!);
      _currentToken = null;
    }
  }
}
