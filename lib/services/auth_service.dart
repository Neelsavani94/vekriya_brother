import 'package:supabase_flutter/supabase_flutter.dart';

import './supabase_service.dart';

class AuthService {
  final SupabaseClient _client = SupabaseService.instance.client;

  /// Sign in with email and password
  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (error) {
      throw Exception('Failed to sign in: $error');
    }
  }

  /// Sign up with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String role = 'operator',
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone': phone,
          'role': role,
        },
      );
      return response;
    } catch (error) {
      throw Exception('Failed to sign up: $error');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (error) {
      throw Exception('Failed to sign out: $error');
    }
  }

  /// Get current user
  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  /// Get current user profile
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      final user = getCurrentUser();
      if (user == null) return null;

      final response = await _client
          .from('user_profiles')
          .select('*')
          .eq('id', user.id)
          .single();

      return Map<String, dynamic>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch user profile: $error');
    }
  }

  /// Update user profile
  Future<Map<String, dynamic>> updateUserProfile(
      Map<String, dynamic> data) async {
    try {
      final user = getCurrentUser();
      if (user == null) throw Exception('No authenticated user');

      final response = await _client
          .from('user_profiles')
          .update(data)
          .eq('id', user.id)
          .select()
          .single();

      return Map<String, dynamic>.from(response);
    } catch (error) {
      throw Exception('Failed to update profile: $error');
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => getCurrentUser() != null;

  /// Get user role
  Future<String?> getUserRole() async {
    try {
      final profile = await getCurrentUserProfile();
      return profile?['role'] as String?;
    } catch (error) {
      return null;
    }
  }

  /// Check if user has specific role
  Future<bool> hasRole(String role) async {
    try {
      final userRole = await getUserRole();
      return userRole == role;
    } catch (error) {
      return false;
    }
  }

  /// Check if user is admin
  Future<bool> isAdmin() async {
    return await hasRole('admin');
  }

  /// Check if user is manager
  Future<bool> isManager() async {
    return await hasRole('manager');
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (error) {
      throw Exception('Failed to reset password: $error');
    }
  }

  /// Update password
  Future<UserResponse> updatePassword(String newPassword) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return response;
    } catch (error) {
      throw Exception('Failed to update password: $error');
    }
  }

  /// Listen to auth state changes
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Sign in with OAuth (Google, etc.)
  Future<bool> signInWithOAuth(OAuthProvider provider) async {
    try {
      final response = await _client.auth.signInWithOAuth(provider);
      return response;
    } catch (error) {
      throw Exception('Failed to sign in with OAuth: $error');
    }
  }

  /// Get mock demo credentials for testing
  List<Map<String, String>> getDemoCredentials() {
    return [
      {
        'email': 'admin@vekariyabrothers.com',
        'password': 'admin123',
        'role': 'Admin',
        'name': 'Vekariya Admin'
      },
      {
        'email': 'manager@vekariyabrothers.com',
        'password': 'manager123',
        'role': 'Manager',
        'name': 'Workshop Manager'
      },
      {
        'email': 'operator@vekariyabrothers.com',
        'password': 'operator123',
        'role': 'Operator',
        'name': 'Floor Operator'
      },
    ];
  }
}
