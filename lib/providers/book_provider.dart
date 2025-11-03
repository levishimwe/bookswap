import 'dart:io';
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
  
  /// Initialize book provider
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
    File? imageFile,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      // Upload image if provided
      String? imageUrl;
      if (imageFile != null) {
        imageUrl = await _storageService.uploadBookImage(imageFile, ownerId);
      }
      
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
  
  /// Update book listing
  Future<bool> updateBook({
    required String bookId,
    required String title,
    required String author,
    required String condition,
    String? existingImageUrl,
    File? newImageFile,
    required String ownerId,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      String? imageUrl = existingImageUrl;
      
      // Upload new image if provided
      if (newImageFile != null) {
        // Delete old image if exists
        if (existingImageUrl != null) {
          await _storageService.deleteImage(existingImageUrl);
        }
        imageUrl = await _storageService.uploadBookImage(newImageFile, ownerId);
      }
      
      // Update book
      final updates = {
        'title': title,
        'author': author,
        'condition': condition,
        'imageUrl': imageUrl,
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
  
  /// Delete book listing
  Future<bool> deleteBook(String bookId, String? imageUrl) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      // Delete image if exists
      if (imageUrl != null) {
        await _storageService.deleteImage(imageUrl);
      }
      
      // Delete book
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
  
  /// Get book by ID
  Future<BookModel?> getBook(String bookId) async {
    try {
      return await _firestoreService.getBook(bookId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
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
  
  /// Dispose
  @override
  void dispose() {
    super.dispose();
  }
}
