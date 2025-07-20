import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mockito/mockito.dart';

/// Test helper functions for setting up test environment
class TestHelpers {
  static bool _isSupabaseInitialized = false;

  /// Initialize Supabase for testing with proper mock setup
  static Future<void> initializeSupabase() async {
    if (_isSupabaseInitialized) {
      return;
    }

    // Mock SharedPreferences for testing
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/shared_preferences'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getAll') {
          return <String, dynamic>{};
        }
        return null;
      },
    );

    const supabaseUrl = String.fromEnvironment(
      'SUPABASE_URL',
      defaultValue: 'https://mdjsjdxvumdxjulgemhg.supabase.co',
    );
    const supabaseAnonKey = String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1kanNqZHh2dW1keGp1bGdlbWhnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTE0Mzg4MzIsImV4cCI6MjA2NzAxNDgzMn0.5dPioDEXWBq7Wu_WD7P9t519l7CYzxVN2HKOQm9gVUc',
    );

    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: false,
      );
      _isSupabaseInitialized = true;
    } catch (e) {
      print('Supabase initialization skipped: $e');
      // For tests that don't need real Supabase, we'll create a mock
      _isSupabaseInitialized = true;
    }
  }

  /// Setup test environment
  static Future<void> setupTestEnvironment() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeSupabase();
  }

  /// Create a mock Supabase client for widget tests
  static Future<void> setupMockSupabase() async {
    if (_isSupabaseInitialized) {
      return;
    }

    // Ensure Flutter binding is initialized
    TestWidgetsFlutterBinding.ensureInitialized();

    // Mock SharedPreferences
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/shared_preferences'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getAll') {
          return <String, dynamic>{};
        }
        return null;
      },
    );

    try {
      await Supabase.initialize(
        url: 'https://test.supabase.co',
        anonKey: 'test-anon-key',
        debug: false,
      );
      _isSupabaseInitialized = true;
    } catch (e) {
      // Ignore initialization errors in tests
      _isSupabaseInitialized = true;
    }
  }

  /// Reset Supabase state for testing
  static void resetSupabase() {
    _isSupabaseInitialized = false;
  }
}