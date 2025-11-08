import 'package:cloud_firestore/cloud_firestore.dart';

class AccessRequestModel {
  final String id;
  final String bookId;
  final String bookTitle;
  final String ownerId;
  final String requesterId;
  final String requesterName;
  final String? offeredBookId; // optional
  final String type; // 'read' or 'watch'
  final String status; // Pending, Accepted, Declined
  final DateTime createdAt;
  final DateTime? respondedAt;

  AccessRequestModel({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.ownerId,
    required this.requesterId,
    required this.requesterName,
    required this.type,
    this.offeredBookId,
    required this.status,
    required this.createdAt,
    this.respondedAt,
  });

  factory AccessRequestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AccessRequestModel(
      id: doc.id,
      bookId: data['bookId'],
      bookTitle: data['bookTitle'] ?? '',
      ownerId: data['ownerId'],
      requesterId: data['requesterId'],
      requesterName: data['requesterName'] ?? '',
      offeredBookId: data['offeredBookId'],
      type: data['type'] ?? 'read',
      status: data['status'] ?? 'Pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      respondedAt: data['respondedAt'] != null
          ? (data['respondedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'bookTitle': bookTitle,
      'ownerId': ownerId,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'offeredBookId': offeredBookId,
      'type': type,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'respondedAt': respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
    };
  }
}
