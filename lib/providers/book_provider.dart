// Removed file & bytes imports since we now use direct image URLs
import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

/// Book listings state provider
class BookProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  
  List<BookModel> _allBooks = [];
  List<BookModel> _myBooks = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  List<BookModel> get allBooks => _allBooks;
  List<BookModel> get myBooks => _myBooks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  /// Initialize book provider with real-time Firestore listeners
  void initialize(String userId) {
    // Listen to all books
    _firestoreService.getAllBooks().listen((books) {
      _allBooks = books;
      notifyListeners();
    });
    
    // Listen to user's books
    _firestoreService.getBooksByOwner(userId).listen((books) {
      _myBooks = books;
      notifyListeners();
    });
  }
  
  /// Create a new book listing
  Future<bool> createBook({
    required String title,
    required String author,
    required String condition,
    required String ownerId,
    required String ownerName,
    required String imageUrl, // now provided directly as external or asset path
    String? linkUrl,
    String? videoUrl,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      // Create book model
      final book = BookModel(
        id: '',
        title: title,
        author: author,
        condition: condition,
        imageUrl: imageUrl,
        ownerId: ownerId,
        ownerName: ownerName,
        postedAt: DateTime.now(),
        isAvailable: true,
        linkUrl: linkUrl,
        videoUrl: videoUrl,
      );
      
      // Save to Firestore
      await _firestoreService.createBook(book);
      
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }
  
  /// Update existing book
  Future<bool> updateBook({
    required String bookId,
    required String title,
    required String author,
    required String condition,
    required String imageUrl, // direct path or URL
    required String ownerId,
    String? linkUrl,
    String? videoUrl,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      // Update Firestore document
      final updates = {
        'title': title,
        'author': author,
        'condition': condition,
        'imageUrl': imageUrl,
        if (linkUrl != null) 'linkUrl': linkUrl,
        if (videoUrl != null) 'videoUrl': videoUrl,
      };
      
      await _firestoreService.updateBook(bookId, updates);
      
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }
  
  /// Delete book and its image
  Future<bool> deleteBook(String bookId, String? imageUrl) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      

      if (imageUrl != null) {
        await _storageService.deleteImage(imageUrl);
      }
      
      
      await _firestoreService.deleteBook(bookId);
      
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }
  
  /// Search books
  Future<List<BookModel>> searchBooks(String query) async {
    try {
      if (query.isEmpty) return _allBooks;
      return await _firestoreService.searchBooks(query);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }
  
  /// Get a specific book by ID
  Future<BookModel?> getBook(String bookId) async {
    try {
      return await _firestoreService.getBook(bookId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }
  
  /// Clear errors
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  /// Manage loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  

  @override
  void dispose() {
    super.dispose();
  }
}
