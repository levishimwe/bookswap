import 'package:flutter/material.dart';
import '../models/swap_model.dart';
import '../models/book_model.dart';
import '../services/firestore_service.dart';

/// Swap offers state provider
class SwapProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<SwapModel> _swapsSent = [];
  List<SwapModel> _swapsReceived = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  List<SwapModel> get swapsSent => _swapsSent;
  List<SwapModel> get swapsReceived => _swapsReceived;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  /// Get all swaps (sent + received)
  List<SwapModel> get allSwaps => [..._swapsSent, ..._swapsReceived];
  
  /// Get pending swaps
  List<SwapModel> get pendingSwaps =>
      allSwaps.where((swap) => swap.status == 'Pending').toList();
  
  /// Initialize swap provider
  void initialize(String userId) {
    // Listen to swaps sent
    _firestoreService.getSwapsSent(userId).listen((swaps) {
      _swapsSent = swaps;
      notifyListeners();
    });
    
    // Listen to swaps received
    _firestoreService.getSwapsReceived(userId).listen((swaps) {
      _swapsReceived = swaps;
      notifyListeners();
    });
  }
  
  /// Create a swap offer
  Future<bool> createSwap({
    required BookModel book,
    required String senderId,
    required String senderName,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      // Use imageBase64 if available, fallback to imageUrl
      final imageUrl = book.imageBase64 ?? book.imageUrl ?? '';
      
      final swap = SwapModel(
        id: '',
        bookId: book.id,
        bookTitle: book.title,
        bookImageUrl: imageUrl,
        senderId: senderId,
        senderName: senderName,
        receiverId: book.ownerId,
        receiverName: book.ownerName,
        status: 'Pending',
        createdAt: DateTime.now(),
      );
      
      await _firestoreService.createSwap(swap);
      
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }
  
  /// Accept swap offer
  Future<bool> acceptSwap(SwapModel swap) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      await _firestoreService.updateSwapStatus(
        swapId: swap.id,
        bookId: swap.bookId,
        newStatus: 'Accepted',
      );
      
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }
  
  /// Reject swap offer
  Future<bool> rejectSwap(SwapModel swap) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      await _firestoreService.updateSwapStatus(
        swapId: swap.id,
        bookId: swap.bookId,
        newStatus: 'Rejected',
      );
      
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }
  
  /// Check if user already made swap offer for a book
  bool hasSwapOffer(String bookId, String userId) {
    return _swapsSent.any(
      (swap) => swap.bookId == bookId && swap.senderId == userId,
    );
  }
  
  /// Get swap for specific book
  SwapModel? getSwapForBook(String bookId) {
    try {
      return allSwaps.firstWhere((swap) => swap.bookId == bookId);
    } catch (e) {
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
