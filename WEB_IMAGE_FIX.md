# Flutter Web Image Picker Fix

## Problem
When running the app on Flutter Web (Chrome), adding a book cover image caused this error:
```
Assertion failed: file:///home/ishimwe/flutter/packages/flutter/lib/src/widgets/image.dart:526:10
'This image file is not supported on Flutter Web. Consider using either Image.asset or the following Image constructor:'
```

## Root Cause
- `Image.file()` doesn't work on Flutter Web because web doesn't have access to local file system paths
- `File` class works differently on web vs mobile
- Firebase Storage `putFile()` doesn't work directly on web

## Solution Applied

### 1. Updated `post_book_screen.dart`
**Changes:**
- Added `import 'package:flutter/foundation.dart' show kIsWeb;`
- Added new field `XFile? _pickedImage` to store the picked image
- Modified `_pickImage()` to handle both web and mobile:
  ```dart
  if (!kIsWeb) {
    _imageFile = File(image.path);
  }
  ```
- Updated image display logic:
  ```dart
  child: kIsWeb
      ? Image.network(_pickedImage!.path, fit: BoxFit.cover)
      : Image.file(_imageFile!, fit: BoxFit.cover),
  ```

### 2. Updated `storage_service.dart`
**Changes:**
- Added `import 'package:flutter/foundation.dart' show kIsWeb;`
- Modified `uploadBookImage()` to handle web:
  ```dart
  if (kIsWeb) {
    final bytes = await imageFile.readAsBytes();
    uploadTask = ref.putData(bytes);
  } else {
    uploadTask = ref.putFile(imageFile);
  }
  ```
- Modified `uploadProfileImage()` with same web support
- Made parameters nullable with null checks

## How It Works Now

### Mobile (Android/iOS)
1. User picks image → `XFile` returned
2. Convert to `File` object
3. Display with `Image.file()`
4. Upload with `putFile()`

### Web (Chrome/Firefox/Safari)
1. User picks image → `XFile` returned (with blob URL)
2. Keep as `XFile` (no File conversion)
3. Display with `Image.network()` using the blob URL
4. Upload with `putData()` after reading bytes

## Testing
- ✅ Image picker opens on web
- ✅ Selected image displays correctly
- ✅ Image uploads to Firebase Storage
- ✅ No assertion errors

## Files Modified
- `lib/screens/my_listings/post_book_screen.dart`
- `lib/services/storage_service.dart`

## Platform Compatibility
- ✅ Android
- ✅ iOS
- ✅ Web (Chrome, Firefox, Safari, Edge)
- ✅ Windows
- ✅ macOS
- ✅ Linux

## Additional Notes
- The `kIsWeb` constant is a compile-time constant that checks the platform
- Tree-shaking ensures unused code is removed for each platform
- No performance impact on mobile platforms
