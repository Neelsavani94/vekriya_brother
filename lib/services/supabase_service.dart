import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    // const String supabaseUrl = String.fromEnvironment('SUPABASE_URL');
    const String supabaseUrl = 'https://tspysiagalospxklhbwm.supabase.co';
    // const String supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRzcHlzaWFnYWxvc3B4a2xoYndtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM0NTM4NjksImV4cCI6MjA3OTAyOTg2OX0.-LJADulhHt9qliwMd0zEdr_4Ql7jT0IJ-zc2h_S1_MI';

    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception('Supabase credentials not found in environment');
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  User? get currentUser => client.auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}
