/// Input validation utility class
class Validators {
  /// Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    
    return null;
  }
  
  /// Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    
    return null;
  }
  
  /// Confirm password validation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }
  
  /// Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    return null;
  }
  
  /// Book title validation
  static String? validateBookTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Book title is required';
    }
    
    if (value.length < 2) {
      return 'Title must be at least 2 characters';
    }
    
    if (value.length > 100) {
      return 'Title must not exceed 100 characters';
    }
    
    return null;
  }
  
  /// Author validation
  static String? validateAuthor(String? value) {
    if (value == null || value.isEmpty) {
      return 'Author name is required';
    }
    
    if (value.length < 2) {
      return 'Author name must be at least 2 characters';
    }
    
    if (value.length > 100) {
      return 'Author name must not exceed 100 characters';
    }
    
    return null;
  }
  
  /// Required field validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    return null;
  }
  
  /// Message validation
  static String? validateMessage(String? value) {
    if (value == null || value.isEmpty) {
      return 'Message cannot be empty';
    }
    
    if (value.length > 500) {
      return 'Message must not exceed 500 characters';
    }
    
    return null;
  }
}
