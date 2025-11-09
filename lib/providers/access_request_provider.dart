import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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

      // Prefilled email to owner
      try {
        final owner = await _firestoreService.getUser(ownerId);
        if (owner != null && owner.email.isNotEmpty) {
          final subject = Uri.encodeComponent('Access request for "$bookTitle"');
            final body = Uri.encodeComponent(
              'Hello,\n\n'
              '$requesterName is requesting ${type == 'watch' ? 'to watch' : 'to read'} "$bookTitle".\n'
              'Open BookSwap > Requests to Grant or Decline.\n\n'
              'Request details:\n- Book: $bookTitle\n- Type: $type\n- From: $requesterName\n- Date: ${DateTime.now()}\n\n'
              'This email was generated locally.'
            );
          final mailto = Uri.parse('mailto:${owner.email}?subject=$subject&body=$body');
          await launchUrl(mailto, mode: LaunchMode.externalApplication);
        }
      } catch (_) {}
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
