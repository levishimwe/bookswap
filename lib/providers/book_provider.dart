import 'dart:convert';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import '../models/book_model.dart';
import '../services/firestore_service.dart';
// Storage uploads removed; images are stored inline as base64 in Firestore

/// Book listings state provider
class BookProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
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
    Uint8List? imageBytes, // picked image bytes (web or mobile)
    String? linkUrl,
    String? videoUrl,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      // Prepare base64 image if provided
      String? imageBase64;
      if (imageBytes != null && imageBytes.isNotEmpty) {
        final processed = await _compressBytes(imageBytes);
        imageBase64 = base64Encode(processed);
      }

      // Create book model
      final book = BookModel(
        id: '',
        title: title,
        author: author,
        condition: condition,
        imageUrl: null,
        imageBase64: imageBase64,
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
    Uint8List? imageBytes,
    required String ownerId,
    String? linkUrl,
    String? videoUrl,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      // Prepare base64 image if provided
      String? imageBase64;
      if (imageBytes != null && imageBytes.isNotEmpty) {
        final processed = await _compressBytes(imageBytes);
        imageBase64 = base64Encode(processed);
      }

      // Update Firestore document
      final updates = {
        'title': title,
        'author': author,
        'condition': condition,
        if (imageBase64 != null) 'imageBase64': imageBase64,
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
      // No external storage deletion needed when using base64 inline images
      
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

  // Compress images so they fit within Firestore document limits
  Future<Uint8List> _compressBytes(Uint8List input, {int maxWidth = 800, int quality = 80}) async {
    try {
      final img.Image? decoded = img.decodeImage(input);
      if (decoded == null) return input;
      img.Image processed = decoded;
      if (decoded.width > maxWidth) {
        processed = img.copyResize(decoded, width: maxWidth);
      }
      final List<int> jpg = img.encodeJpg(processed, quality: quality);
      return Uint8List.fromList(jpg);
    } catch (_) {
      return input;
    }
  }
  

  @override
  void dispose() {
    super.dispose();
  }
}
