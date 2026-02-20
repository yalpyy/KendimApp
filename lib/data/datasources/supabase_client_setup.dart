import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:kendin/core/constants/app_constants.dart';

/// Initializes and provides access to the Supabase client.
class SupabaseClientSetup {
  SupabaseClientSetup._();

  static SupabaseClient get client => Supabase.instance.client;

  /// Call once in main() before runApp().
  static Future<void> initialize() async {
    debugPrint('[Kendin] Supabase URL: ${AppConstants.supabaseUrl.isNotEmpty ? "SET" : "EMPTY"}');
    debugPrint('[Kendin] Supabase Key: ${AppConstants.supabaseAnonKey.isNotEmpty ? "SET" : "EMPTY"}');

    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );

    debugPrint('[Kendin] Supabase client initialized successfully');
  }
}
