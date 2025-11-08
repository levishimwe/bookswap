import 'package:flutter/material.dart';
import '../models/access_request_model.dart';
import '../services/firestore_service.dart';

class AccessRequestProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<AccessRequestModel> _received = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AccessRequestModel> get received => _received;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void initialize(String ownerId) {
    _firestoreService.getAccessRequestsReceived(ownerId).listen((list) {
      _received = list;
      notifyListeners();
    });
  }

  Future<bool> sendRequest({
    required String bookId,
    required String bookTitle,
    required String ownerId,
    required String requesterId,
    required String requesterName,
    required String type,
    String? offeredBookId,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      final req = AccessRequestModel(
        id: '',
        bookId: bookId,
        bookTitle: bookTitle,
        ownerId: ownerId,
        requesterId: requesterId,
        requesterName: requesterName,
        type: type,
        offeredBookId: offeredBookId,
        status: 'Pending',
        createdAt: DateTime.now(),
      );
      await _firestoreService.createAccessRequest(req);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> accept(AccessRequestModel request) async {
    try {
      _setLoading(true);
      await _firestoreService.updateAccessRequestStatus(
        requestId: request.id,
        newStatus: 'Accepted',
      );
      await _firestoreService.grantAccessToBook(
        bookId: request.bookId,
        userId: request.requesterId,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> decline(AccessRequestModel request) async {
    try {
      _setLoading(true);
      await _firestoreService.updateAccessRequestStatus(
        requestId: request.id,
        newStatus: 'Declined',
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}
