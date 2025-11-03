import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Authentication state provider
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  
  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  String? get currentUserId => _authService.currentUserId;
  
  /// Initialize auth state
  Future<void> initialize() async {
    final user = _authService.currentUser;
    if (user != null) {
      _currentUser = await _authService.getUserData(user.uid);
      notifyListeners();
    }
  }
  
  /// Sign up
  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      _currentUser = await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }
  
  /// Sign in
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      _currentUser = await _authService.signIn(
        email: email,
        password: password,
      );
      
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }
  
  /// Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _currentUser = null;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
  
  /// Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
  
  /// Check email verification status
  Future<bool> checkEmailVerified() async {
    try {
      final isVerified = await _authService.isEmailVerified();
      if (isVerified && _currentUser != null) {
        _currentUser = _currentUser!.copyWith(emailVerified: true);
        notifyListeners();
      }
      return isVerified;
    } catch (e) {
      return false;
    }
  }
  
  /// Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      await _authService.resetPassword(email);
      
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }
  
  /// Update profile
  Future<bool> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      _setLoading(true);
      await _authService.updateProfile(
        displayName: displayName,
        photoURL: photoURL,
      );
      
      // Refresh user data
      if (_currentUser != null) {
        _currentUser = await _authService.getUserData(_currentUser!.uid);
      }
      
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }
  
  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  /// Listen to auth state changes
  Stream<User?> get authStateChanges => _authService.authStateChanges;
}
