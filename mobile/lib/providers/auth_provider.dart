import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _supabase.auth.onAuthStateChange.listen((data) async {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        await _fetchUserProfile(session.user.id);
      } else if (event == AuthChangeEvent.signedOut) {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  Future<void> _fetchUserProfile(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      if (response != null) {
        _currentUser = User.fromJson(response);
      } else {
        // Create user profile if it doesn't exist
        await _createUserProfile(userId);
      }
    } catch (e) {
      _errorMessage = 'Failed to fetch user profile: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _createUserProfile(String userId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final response = await _supabase
            .from('users')
            .insert({
              'id': userId,
              'email': user.email,
              'display_name': user.email?.split('@')[0],
            })
            .select()
            .single();

        _currentUser = User.fromJson(response);
      }
    } catch (e) {
      _errorMessage = 'Failed to create user profile: $e';
    }
  }

  Future<bool> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'display_name': displayName ?? email.split('@')[0],
        },
      );

      if (response.user != null) {
        await _createUserProfile(response.user!.id);
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Sign up failed: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _fetchUserProfile(response.user!.id);
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Sign in failed: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabase.auth.signOut();
      _currentUser = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Sign out failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    String? displayName,
  }) async {
    try {
      if (_currentUser == null) return false;

      _isLoading = true;
      notifyListeners();

      final response = await _supabase
          .from('users')
          .update({
            'display_name': displayName,
          })
          .eq('id', _currentUser!.id)
          .select()
          .single();

      _currentUser = User.fromJson(response);
      return true;
    } catch (e) {
      _errorMessage = 'Profile update failed: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      _errorMessage = 'Password reset failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
