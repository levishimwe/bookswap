import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as img;

/// Storage service for handling file uploads to Firebase Storage
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = const Uuid();
  
  StorageService() {
    // Be more tolerant on slow networks to avoid retry-limit-exceeded
    try {
      _storage.setMaxUploadRetryTime(const Duration(minutes: 5));
      _storage.setMaxOperationRetryTime(const Duration(minutes: 2));
    } catch (_) {
      // Older plugin versions may not support these methods; ignore safely
    }
  }

  // Compress image bytes to a reasonable size for web/mobile uploads
  Future<Uint8List> _compressBytes(Uint8List input, {int maxWidth = 1280, int quality = 80}) async {
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
      // If compression fails, return original bytes
      return input;
    }
  }
  
  /// Upload book image (supports both web & mobile)
  Future<String> uploadBookImage({
    File? imageFile,
    Uint8List? webBytes,
    required String userId,
  }) async {
    try {
      if (imageFile == null && webBytes == null) {
        throw Exception('No image provided');
      }
      
      final String fileName = '${_uuid.v4()}.jpg';
      final String filePath = 'book_images/$userId/$fileName';

      final Reference ref = _storage.ref().child(filePath);
      
      // Prepare bytes (compress for both web & mobile)
      Uint8List bytesToUpload;
      if (kIsWeb && webBytes != null) {
        bytesToUpload = await _compressBytes(webBytes);
      } else if (imageFile != null) {
        final raw = await imageFile.readAsBytes();
        bytesToUpload = await _compressBytes(raw);
      } else if (kIsWeb && imageFile != null) {
        final raw = await imageFile.readAsBytes();
        bytesToUpload = await _compressBytes(raw);
      } else {
        throw Exception('Invalid image configuration');
      }

      if (kDebugMode) {
        final kb = (bytesToUpload.lengthInBytes / 1024).toStringAsFixed(0);
        // ignore: avoid_print
        print('Uploading image -> path: $filePath, size: ${kb}KB');
      }

      UploadTask uploadTask = ref.putData(
        bytesToUpload,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      TaskSnapshot snapshot;
      try {
        snapshot = await uploadTask;
      } on FirebaseException catch (fe) {
        // On retry-limit-exceeded, try a more aggressive compression once
        if (fe.code == 'retry-limit-exceeded') {
          if (kDebugMode) print('Retry with stronger compression due to retry-limit-exceeded');
          final retryBytes = await _compressBytes(bytesToUpload, maxWidth: 1024, quality: 65);
          uploadTask = ref.putData(
            retryBytes,
            SettableMetadata(contentType: 'image/jpeg'),
          );
          snapshot = await uploadTask; // may throw again
        } else {
          rethrow;
        }
      }
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } on FirebaseException catch (e) {
      if (kDebugMode) print('Storage upload FirebaseException: ${e.code} ${e.message}');
      rethrow;
    } catch (e) {
      if (kDebugMode) print('Storage upload error: $e');
      rethrow;
    }
  }
  
  /// Upload user profile image
  Future<String> uploadProfileImage({
    File? imageFile,
    Uint8List? webBytes,
    required String userId,
  }) async {
    try {
      if (imageFile == null && webBytes == null) {
        throw Exception('No image provided');
      }
      
      final String fileName = 'profile_$userId.jpg';
      final String filePath = 'profile_images/$fileName';

      final Reference ref = _storage.ref().child(filePath);
      
      UploadTask uploadTask;
      
      if (kIsWeb && webBytes != null) {
        uploadTask = ref.putData(
          webBytes,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      } else {
        uploadTask = ref.putFile(
          imageFile!,
          SettableMetadata(contentType: 'image/jpeg'),
        );
      }
      
      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }
  
  /// Delete any image from Firebase Storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      if (kDebugMode) print('Failed to delete image: $e');
    }
  }
}
