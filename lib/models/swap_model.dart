import 'package:cloud_firestore/cloud_firestore.dart';

/// Swap model representing swap offers between users
class SwapModel {
  final String id;
  final String bookId;
  final String bookTitle;
  final String bookImageUrl;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String receiverName;
  final String status; // Pending, Accepted, Rejected
  final DateTime createdAt;
  final DateTime? respondedAt;
  
  SwapModel({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.bookImageUrl,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.status,
    required this.createdAt,
    this.respondedAt,
  });
  
  /// Create SwapModel from Firestore document
  factory SwapModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SwapModel(
      id: doc.id,
      bookId: data['bookId'] ?? '',
      bookTitle: data['bookTitle'] ?? '',
      bookImageUrl: data['bookImageUrl'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      receiverId: data['receiverId'] ?? '',
      receiverName: data['receiverName'] ?? '',
      status: data['status'] ?? 'Pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      respondedAt: data['respondedAt'] != null 
          ? (data['respondedAt'] as Timestamp).toDate() 
          : null,
    );
  }
  
  /// Convert SwapModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'bookTitle': bookTitle,
      'bookImageUrl': bookImageUrl,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'respondedAt': respondedAt != null 
          ? Timestamp.fromDate(respondedAt!) 
          : null,
    };
  }
  
  /// Create a copy with updated fields
  SwapModel copyWith({
    String? id,
    String? bookId,
    String? bookTitle,
    String? bookImageUrl,
    String? senderId,
    String? senderName,
    String? receiverId,
    String? receiverName,
    String? status,
    DateTime? createdAt,
    DateTime? respondedAt,
  }) {
    return SwapModel(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      bookTitle: bookTitle ?? this.bookTitle,
      bookImageUrl: bookImageUrl ?? this.bookImageUrl,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }
  
  /// Check if current user is sender
  bool isSender(String currentUserId) {
    return senderId == currentUserId;
  }
  
  /// Check if current user is receiver
  bool isReceiver(String currentUserId) {
    return receiverId == currentUserId;
  }
}
