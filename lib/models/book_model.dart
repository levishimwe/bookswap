import 'package:cloud_firestore/cloud_firestore.dart';

/// Book model representing book listings
class BookModel {
  final String id;
  final String title;
  final String author;
  final String condition; // New, Like New, Good, Used
  final String? imageUrl;
  final String? linkUrl; // Optional reading link (PDF/web)
  final String? videoUrl; // Optional YouTube/video link
  final List<String> allowedUserIds; // Users approved to access links
  final String ownerId;
  final String ownerName;
  final DateTime postedAt;
  final bool isAvailable;
  final String? swapId; // ID of active swap if book is in swap
  
  BookModel({
    required this.id,
    required this.title,
    required this.author,
    required this.condition,
    this.imageUrl,
    this.linkUrl,
    this.videoUrl,
    this.allowedUserIds = const [],
    required this.ownerId,
    required this.ownerName,
    required this.postedAt,
    this.isAvailable = true,
    this.swapId,
  });
  
  /// Create BookModel from Firestore document
  factory BookModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookModel(
      id: doc.id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      condition: data['condition'] ?? 'Used',
      imageUrl: data['imageUrl'],
      linkUrl: data['linkUrl'],
      videoUrl: data['videoUrl'],
      allowedUserIds: (data['allowedUserIds'] as List?)?.cast<String>() ?? const [],
      ownerId: data['ownerId'] ?? '',
      ownerName: data['ownerName'] ?? '',
      postedAt: (data['postedAt'] as Timestamp).toDate(),
      isAvailable: data['isAvailable'] ?? true,
      swapId: data['swapId'],
    );
  }
  
  /// Convert BookModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'condition': condition,
      'imageUrl': imageUrl,
      'linkUrl': linkUrl,
      'videoUrl': videoUrl,
      'allowedUserIds': allowedUserIds,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'postedAt': Timestamp.fromDate(postedAt),
      'isAvailable': isAvailable,
      'swapId': swapId,
    };
  }
  
  /// Create a copy with updated fields
  BookModel copyWith({
    String? id,
    String? title,
    String? author,
    String? condition,
    String? imageUrl,
    String? linkUrl,
    String? videoUrl,
    List<String>? allowedUserIds,
    String? ownerId,
    String? ownerName,
    DateTime? postedAt,
    bool? isAvailable,
    String? swapId,
  }) {
    return BookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      condition: condition ?? this.condition,
      imageUrl: imageUrl ?? this.imageUrl,
      linkUrl: linkUrl ?? this.linkUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      allowedUserIds: allowedUserIds ?? this.allowedUserIds,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      postedAt: postedAt ?? this.postedAt,
      isAvailable: isAvailable ?? this.isAvailable,
      swapId: swapId ?? this.swapId,
    );
  }
}
