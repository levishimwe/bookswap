import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

/// Storage service for handling file uploads to Firebase Storage
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();
  
  /// Upload book image
  Future<String> uploadBookImage(File imageFile, String userId) async {
    try {
      final String fileName = '${_uuid.v4()}.jpg';
      final String filePath = 'book_images/$userId/$fileName';
      
      final Reference ref = _storage.ref().child(filePath);
      final UploadTask uploadTask = ref.putFile(imageFile);
      
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw 'Failed to upload image. Please try again.';
    }
  }
  
  /// Upload profile image
  Future<String> uploadProfileImage(File imageFile, String userId) async {
    try {
      final String fileName = 'profile_$userId.jpg';
      final String filePath = 'profile_images/$fileName';
      
      final Reference ref = _storage.ref().child(filePath);
      final UploadTask uploadTask = ref.putFile(imageFile);
      
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw 'Failed to upload profile image. Please try again.';
    }
  }
  
  /// Delete image from storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      // Silently fail if image doesn't exist or can't be deleted
      print('Failed to delete image: $e');
    }
  }
}
