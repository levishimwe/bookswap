import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book_model.dart';
import '../models/swap_model.dart';
import '../models/user_model.dart';
import '../models/access_request_model.dart';

/// Firestore service for database operations
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // ===== BOOK OPERATIONS =====
  
  /// Create a new book listing
  Future<String> createBook(BookModel book) async {
    try {
      final docRef = await _firestore.collection('books').add(book.toMap());
      return docRef.id;
    } catch (e) {
      throw 'Failed to create book listing. Please try again.';
    }
  }
  
  /// Get all available book listings
  Stream<List<BookModel>> getAllBooks() {
    return _firestore
        .collection('books')
        .where('isAvailable', isEqualTo: true)
        .orderBy('postedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => BookModel.fromFirestore(doc)).toList());
  }
  
  /// Get books by owner ID
  Stream<List<BookModel>> getBooksByOwner(String ownerId) {
    return _firestore
        .collection('books')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('postedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => BookModel.fromFirestore(doc)).toList());
  }
  
  /// Get single book by ID
  Future<BookModel?> getBook(String bookId) async {
    try {
      final doc = await _firestore.collection('books').doc(bookId).get();
      if (!doc.exists) return null;
      return BookModel.fromFirestore(doc);
    } catch (e) {
      return null;
    }
  }
  
  /// Update book listing
  Future<void> updateBook(String bookId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('books').doc(bookId).update(updates);
    } catch (e) {
      throw 'Failed to update book. Please try again.';
    }
  }
  
  /// Delete book listing
  Future<void> deleteBook(String bookId) async {
    try {
      await _firestore.collection('books').doc(bookId).delete();
    } catch (e) {
      throw 'Failed to delete book. Please try again.';
    }
  }
  
  // ===== SWAP OPERATIONS =====
  
  /// Create a swap offer
  Future<String> createSwap(SwapModel swap) async {
    try {
      // Start a batch write
      final batch = _firestore.batch();
      
      // Add swap document
      final swapRef = _firestore.collection('swaps').doc();
      batch.set(swapRef, swap.toMap());
      
      // Update book availability
      final bookRef = _firestore.collection('books').doc(swap.bookId);
      batch.update(bookRef, {
        'isAvailable': false,
        'swapId': swapRef.id,
      });
      
      // Commit batch
      await batch.commit();
      
      return swapRef.id;
    } catch (e) {
      throw 'Failed to create swap offer. Please try again.';
    }
  }
  
  /// Get swaps sent by user
  Stream<List<SwapModel>> getSwapsSent(String userId) {
    return _firestore
        .collection('swaps')
        .where('senderId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => SwapModel.fromFirestore(doc)).toList());
  }
  
  /// Get swaps received by user
  Stream<List<SwapModel>> getSwapsReceived(String userId) {
    return _firestore
        .collection('swaps')
        .where('receiverId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => SwapModel.fromFirestore(doc)).toList());
  }
  
  /// Update swap status
  Future<void> updateSwapStatus({
    required String swapId,
    required String bookId,
    required String newStatus,
  }) async {
    try {
      final batch = _firestore.batch();
      
      // Update swap status
      final swapRef = _firestore.collection('swaps').doc(swapId);
      batch.update(swapRef, {
        'status': newStatus,
        'respondedAt': FieldValue.serverTimestamp(),
      });
      
      // If rejected, make book available again
      if (newStatus == 'Rejected') {
        final bookRef = _firestore.collection('books').doc(bookId);
        batch.update(bookRef, {
          'isAvailable': true,
          'swapId': null,
        });
      }
      
      await batch.commit();
    } catch (e) {
      throw 'Failed to update swap status. Please try again.';
    }
  }
  
  // ===== USER OPERATIONS =====
  
  /// Get user by ID
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    } catch (e) {
      return null;
    }
  }
  
  /// Update user settings
  Future<void> updateUserSettings(String userId, Map<String, dynamic> settings) async {
    try {
      await _firestore.collection('users').doc(userId).update(settings);
    } catch (e) {
      throw 'Failed to update settings. Please try again.';
    }
  }
  
  /// Search books by title or author
  Future<List<BookModel>> searchBooks(String query) async {
    try {
      final queryLower = query.toLowerCase();
      
      // Get all available books
      final snapshot = await _firestore
          .collection('books')
          .where('isAvailable', isEqualTo: true)
          .get();
      
      // Filter locally (Firestore doesn't support full-text search)
      final books = snapshot.docs
          .map((doc) => BookModel.fromFirestore(doc))
          .where((book) =>
              book.title.toLowerCase().contains(queryLower) ||
              book.author.toLowerCase().contains(queryLower))
          .toList();
      
      return books;
    } catch (e) {
      throw 'Failed to search books. Please try again.';
    }
  }

  // ===== ACCESS REQUESTS =====

  Future<String> createAccessRequest(AccessRequestModel request) async {
    try {
      final docRef = await _firestore.collection('access_requests').add(request.toMap());
      return docRef.id;
    } catch (e) {
      throw 'Failed to send access request. Please try again.';
    }
  }

  Stream<List<AccessRequestModel>> getAccessRequestsReceived(String ownerId) {
    return _firestore
        .collection('access_requests')
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => AccessRequestModel.fromFirestore(d)).toList());
  }

  Future<void> updateAccessRequestStatus({
    required String requestId,
    required String newStatus,
  }) async {
    try {
      await _firestore.collection('access_requests').doc(requestId).update({
        'status': newStatus,
        'respondedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to update request. Please try again.';
    }
  }

  Future<void> grantAccessToBook({
    required String bookId,
    required String userId,
  }) async {
    try {
      await _firestore.collection('books').doc(bookId).update({
        'allowedUserIds': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      throw 'Failed to grant access. Please try again.';
    }
  }
}
