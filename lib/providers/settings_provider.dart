import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

/// Settings state provider
class SettingsProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  bool _notificationsEnabled = true;
  bool _emailUpdates = true;
  bool _darkMode = false;
  bool _isLoading = false;
  String? _errorMessage;
  
  bool get notificationsEnabled => _notificationsEnabled;
  bool get emailUpdates => _emailUpdates;
  bool get darkMode => _darkMode;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  /// Initialize settings
  Future<void> initialize(String userId) async {
    try {
      final user = await _firestoreService.getUser(userId);
      if (user != null) {
        _notificationsEnabled = user.notificationsEnabled;
        // Try to read theme from user's doc (optional)
        // If not present, keep default false
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
  
  /// Toggle notifications
  Future<void> toggleNotifications(String userId, bool value) async {
    try {
      _setLoading(true);
      _notificationsEnabled = value;
      
      await _firestoreService.updateUserSettings(userId, {
        'notificationsEnabled': value,
      });
      
      _setLoading(false);
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
    }
  }
  
  /// Toggle email updates
  void toggleEmailUpdates(bool value) {
    _emailUpdates = value;
    notifyListeners();
  }

  /// Toggle dark mode (also persists to Firestore user doc if possible)
  Future<void> toggleDarkMode(String userId, bool value) async {
    try {
      _darkMode = value;
      notifyListeners();
      await _firestoreService.updateUserSettings(userId, {
        'darkMode': value,
      });
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
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
}
