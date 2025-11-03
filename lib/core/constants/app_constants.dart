/// App-wide constants
class AppConstants {
  // App Info
  static const String appName = 'BookSwap';
  static const String appTagline = 'Swap Your Books\nWith Other Students';
  
  // Book Conditions
  static const String conditionNew = 'New';
  static const String conditionLikeNew = 'Like New';
  static const String conditionGood = 'Good';
  static const String conditionUsed = 'Used';
  
  static const List<String> bookConditions = [
    conditionNew,
    conditionLikeNew,
    conditionGood,
    conditionUsed,
  ];
  
  // Swap Status
  static const String swapPending = 'Pending';
  static const String swapAccepted = 'Accepted';
  static const String swapRejected = 'Rejected';
  
  // Firestore Collections
  static const String usersCollection = 'users';
  static const String booksCollection = 'books';
  static const String swapsCollection = 'swaps';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';
  
  // Storage Paths
  static const String bookImagesPath = 'book_images';
  static const String profileImagesPath = 'profile_images';
  
  // Validation
  static const int minPasswordLength = 6;
  static const int maxBookTitleLength = 100;
  static const int maxAuthorNameLength = 100;
  static const int maxMessageLength = 500;
  
  // UI
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
  
  // Navigation
  static const int browseIndex = 0;
  static const int myListingsIndex = 1;
  static const int chatsIndex = 2;
  static const int settingsIndex = 3;
  
  // Error Messages
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'Please check your internet connection.';
  static const String authError = 'Authentication failed. Please try again.';
  
  // Success Messages
  static const String bookPostedSuccess = 'Book posted successfully!';
  static const String bookUpdatedSuccess = 'Book updated successfully!';
  static const String bookDeletedSuccess = 'Book deleted successfully!';
  static const String swapSentSuccess = 'Swap offer sent successfully!';
}
