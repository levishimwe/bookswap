import 'package:cloud_firestore/cloud_firestore.dart';

/// User model representing app users
class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? profileImageUrl;
  final DateTime createdAt;
  final bool emailVerified;
  final bool notificationsEnabled;
  
  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.profileImageUrl,
    required this.createdAt,
    this.emailVerified = false,
    this.notificationsEnabled = true,
  });
  
  /// Create UserModel from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      profileImageUrl: data['profileImageUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      emailVerified: data['emailVerified'] ?? false,
      notificationsEnabled: data['notificationsEnabled'] ?? true,
    );
  }
  
  /// Convert UserModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'profileImageUrl': profileImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'emailVerified': emailVerified,
      'notificationsEnabled': notificationsEnabled,
    };
  }
  
  /// Create a copy with updated fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? profileImageUrl,
    DateTime? createdAt,
    bool? emailVerified,
    bool? notificationsEnabled,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      emailVerified: emailVerified ?? this.emailVerified,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
