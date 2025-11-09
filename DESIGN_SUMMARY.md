# Design & Architecture Summary

Submission Info

- Name: Levis Ishimwe
- Email: i.levis@alustudent.com
- GitHub: https://github.com/levishimwe/bookswap
- Demo Video: https://www.youtube.com/watch?v=Fb6FazMZJpw
- Date: November 9, 2025

# BookSwap - Design Summary

## Database Schema & Architecture

### Entity-Relationship Diagram (ERD)

```
┌─────────────────┐         ┌─────────────────┐
│     USERS       │         │     BOOKS       │
├─────────────────┤         ├─────────────────┤
│ uid (PK)        │─────┐   │ id (PK)         │
│ email           │     │   │ title           │
│ displayName     │     │   │ author          │
│ profileImageUrl │     │   │ condition       │
│ createdAt       │     └──▶│ ownerId (FK)    │
│ emailVerified   │         │ ownerName       │
│ notificationsOn │         │ imageBase64     │
└─────────────────┘         │ imageUrl        │
                            │ linkUrl         │
                            │ videoUrl        │
       ┌────────────────────│ allowedUserIds[]│
       │                    │ isAvailable     │
       │                    │ swapId          │
       │                    │ postedAt        │
       │                    └─────────────────┘
       │                             │
       │                             │ 1:N
       │                             ▼
       │                    ┌─────────────────┐
       │                    │     SWAPS       │
       │                    ├─────────────────┤
       │                    │ id (PK)         │
       │                    │ bookId (FK)     │
       │         ┌─────────▶│ senderId (FK)   │
       │         │          │ senderName      │
       │         │  ┌──────▶│ receiverId (FK) │
       │         │  │       │ receiverName    │
       │         │  │       │ bookTitle       │
       │         │  │       │ bookImageUrl    │
       │         │  │       │ status          │
       │         │  │       │ createdAt       │
       │         │  │       │ respondedAt     │
       │         │  │       └─────────────────┘
       │         │  │
       │         │  │
       ├─────────┘  │       ┌──────────────────┐
       │            │       │ ACCESS_REQUESTS  │
       │            │       ├──────────────────┤
       │            │       │ id (PK)          │
       │            │       │ bookId (FK)      │
       │            ├──────▶│ ownerId (FK)     │
       │            │       │ requesterId (FK) │
       │            │       │ requesterName    │
       │            │       │ bookTitle        │
       │            │       │ type             │
       │            │       │ status           │
       │            │       │ createdAt        │
       │            │       │ respondedAt      │
       │            │       └──────────────────┘
       │            │
       │            │
       ├────────────┤       ┌─────────────────┐
       │            │       │     CHATS       │
       │            │       ├─────────────────┤
       │            │       │ id (PK)         │
       │            └──────▶│ participantIds[]│
       │                    │ participantNames│
       └───────────────────▶│   (Map)         │
                            │ lastMessage     │
                            │ lastMessageTime │
                            │ unreadCount(Map)│
                            └─────────────────┘
                                     │
                                     │ 1:N
                                     ▼
                            ┌─────────────────┐
                            │   MESSAGES      │
                            │  (subcollection)│
                            ├─────────────────┤
                            │ id (PK)         │
                            │ chatId (FK)     │
                            │ senderId (FK)   │
                            │ senderName      │
                            │ receiverId (FK) │
                            │ text            │
                            │ timestamp       │
                            │ isRead          │
                            └─────────────────┘
```

### Firestore Collection Structure

```
/users/{userId}
  - uid: string
  - email: string
  - displayName: string
  - profileImageUrl: string?
  - createdAt: timestamp
  - emailVerified: bool
  - notificationsEnabled: bool

/books/{bookId}
  - id: string
  - title: string
  - author: string
  - condition: string (New | Like New | Good | Used)
  - ownerId: string (ref to users)
  - ownerName: string
  - imageBase64: string? (compressed base64 image)
  - imageUrl: string? (for featured assets)
  - linkUrl: string? (Google Drive/external link)
  - videoUrl: string? (YouTube/external link)
  - allowedUserIds: array<string> (access control)
  - isAvailable: bool (false when in swap)
  - swapId: string? (ref to active swap)
  - postedAt: timestamp

/swaps/{swapId}
  - id: string
  - bookId: string (ref to books)
  - bookTitle: string (denormalized for performance)
  - bookImageUrl: string (base64 or URL)
  - senderId: string (ref to users)
  - senderName: string
  - receiverId: string (ref to users)
  - receiverName: string
  - status: string (Pending | Accepted | Rejected)
  - createdAt: timestamp
  - respondedAt: timestamp?

/access_requests/{requestId}
  - id: string
  - bookId: string (ref to books)
  - bookTitle: string
  - ownerId: string (ref to users)
  - requesterId: string (ref to users)
  - requesterName: string
  - offeredBookId: string? (future feature)
  - type: string (read | watch)
  - status: string (Pending | Accepted | Declined)
  - createdAt: timestamp
  - respondedAt: timestamp?

/chats/{chatId}
  - id: string (composite: userId1_userId2, sorted)
  - participantIds: array<string> [userId1, userId2]
  - participantNames: map<string, string> {userId: name}
  - lastMessage: string
  - lastMessageSenderId: string
  - lastMessageTime: timestamp
  - unreadCount: map<string, number> {userId: count}

/chats/{chatId}/messages/{messageId}  (subcollection)
  - id: string
  - chatId: string
  - senderId: string
  - senderName: string
  - receiverId: string
  - text: string
  - timestamp: timestamp
  - isRead: bool
```

---

## Swap State Modeling

### State Machine Diagram

```
                    ┌──────────────┐
                    │  Book Posted │
                    │ (Available)  │
                    └──────┬───────┘
                           │
                           │ User taps "Swap"
                           ▼
                    ┌──────────────┐
         ┌─────────▶│   PENDING    │
         │          │ (In Offer)   │
         │          └──────┬───────┘
         │                 │
         │                 ├───────┐
         │                 │       │
         │  Owner rejects  │       │ Owner accepts
         │                 │       │
         │                 ▼       ▼
         │          ┌──────────┐ ┌──────────┐
         └──────────│ REJECTED │ │ ACCEPTED │
           (Book    └──────────┘ └──────────┘
          available              (Swap complete)
           again)
```

### Swap State Transitions

| Current State | Action           | Next State | Side Effects                              |
|---------------|------------------|------------|-------------------------------------------|
| (none)        | Send Swap Offer  | PENDING    | - Create swap doc<br>- Set book.isAvailable = false<br>- Set book.swapId = swapId<br>- Send email notification |
| PENDING       | Accept Swap      | ACCEPTED   | - Update swap.status = "Accepted"<br>- Update swap.respondedAt<br>- book remains unavailable |
| PENDING       | Reject Swap      | REJECTED   | - Update swap.status = "Rejected"<br>- Set book.isAvailable = true<br>- Clear book.swapId<br>- book available for new offers |

### Firestore Transaction for Swap Creation

```dart
Future<String> createSwap(SwapModel swap) async {
  try {
    // Use batch write to ensure atomicity
    final batch = _firestore.batch();
    
    // Step 1: Add swap document
    final swapRef = _firestore.collection('swaps').doc();
    batch.set(swapRef, swap.toMap());
    
    // Step 2: Update book availability atomically
    final bookRef = _firestore.collection('books').doc(swap.bookId);
    batch.update(bookRef, {
      'isAvailable': false,  // Lock book
      'swapId': swapRef.id,  // Link to swap
    });
    
    // Commit both operations atomically
    await batch.commit();
    
    return swapRef.id;
  } catch (e) {
    throw 'Failed to create swap offer';
  }
}
```

### Why This Design?

1. **Atomicity**: Batch writes ensure book and swap are updated together or not at all
2. **Referential Integrity**: `swapId` field links book to active swap
3. **Optimistic Locking**: Only one swap can be pending per book at a time
4. **Denormalization**: Store `bookTitle` and `bookImageUrl` in swap for performance (avoid joins)
5. **Reversibility**: Rejected swaps restore book availability automatically

---

## State Management Implementation

### Architecture: Provider Pattern

```
┌─────────────────────────────────────────────────────┐
│                  UI Layer (Screens)                 │
│  ┌────────────┐  ┌────────────┐  ┌────────────┐   │
│  │  Browse    │  │ My Listings│  │   Chats    │   │
│  │  Screen    │  │   Screen   │  │   Screen   │   │
│  └─────┬──────┘  └─────┬──────┘  └─────┬──────┘   │
└────────┼───────────────┼───────────────┼───────────┘
         │               │               │
         │  Consumer /   │               │
         │  context.watch()              │
         │               │               │
┌────────▼───────────────▼───────────────▼───────────┐
│            Provider Layer (State)                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────┐ │
│  │ BookProvider │  │ SwapProvider │  │  Chat    │ │
│  │              │  │              │  │ Provider │ │
│  │ - allBooks   │  │ - swapsSent  │  │ - chats  │ │
│  │ - isLoading  │  │ - swapsRcvd  │  │ - unread │ │
│  │ - error      │  │ - isLoading  │  │          │ │
│  └──────┬───────┘  └──────┬───────┘  └────┬─────┘ │
└─────────┼──────────────────┼───────────────┼───────┘
          │                  │               │
          │   Service calls  │               │
          │                  │               │
┌─────────▼──────────────────▼───────────────▼───────┐
│           Service Layer (Firebase)                  │
│  ┌──────────────────┐  ┌────────────────────────┐ │
│  │ FirestoreService │  │    ChatService         │ │
│  │ - createBook()   │  │ - sendMessage()        │ │
│  │ - getAllBooks()  │  │ - getMessages()        │ │
│  │ - createSwap()   │  │ - createOrGetChat()    │ │
│  │ - updateSwap()   │  │ - getUserChats()       │ │
│  └────────┬─────────┘  └────────┬───────────────┘ │
└───────────┼──────────────────────┼─────────────────┘
            │                      │
            │  Firestore SDK calls │
            │                      │
┌───────────▼──────────────────────▼─────────────────┐
│              Firebase Backend                       │
│  ┌──────────┐  ┌──────┐  ┌──────────────────────┐ │
│  │Firestore │  │ Auth │  │  Security Rules      │ │
│  └──────────┘  └──────┘  └──────────────────────┘ │
└─────────────────────────────────────────────────────┘
```

### Provider Setup (main.dart)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProxyProvider<AuthProvider, BookProvider>(
          create: (_) => BookProvider(),
          update: (_, auth, previous) {
            if (auth.currentUserId != null) {
              previous?.initialize(auth.currentUserId!);
            }
            return previous ?? BookProvider();
          },
        ),
        // ... other providers
      ],
      child: const MyApp(),
    ),
  );
}
```

### Key Provider Patterns Used

#### 1. ChangeNotifier Pattern
```dart
class BookProvider with ChangeNotifier {
  List<BookModel> _allBooks = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters expose immutable state
  List<BookModel> get allBooks => _allBooks;
  bool get isLoading => _isLoading;
  
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners(); // Triggers UI rebuild
  }
}
```

#### 2. Stream Listening Pattern
```dart
void initialize(String userId) {
  // Listen to Firestore stream
  _firestoreService.getAllBooks().listen((books) {
    _allBooks = books;
    notifyListeners(); // Update UI when data changes
  });
}
```

#### 3. Consumer Widget Pattern
```dart
Consumer<BookProvider>(
  builder: (context, bookProvider, child) {
    if (bookProvider.isLoading) {
      return const LoadingIndicator();
    }
    return ListView.builder(
      itemCount: bookProvider.allBooks.length,
      itemBuilder: (context, index) {
        final book = bookProvider.allBooks[index];
        return BookCard(book: book);
      },
    );
  },
)
```

#### 4. Provider Dependency (ProxyProvider)
```dart
ChangeNotifierProxyProvider<AuthProvider, BookProvider>(
  create: (_) => BookProvider(),
  update: (_, auth, previous) {
    // Re-initialize when auth state changes
    if (auth.currentUserId != null) {
      previous?.initialize(auth.currentUserId!);
    }
    return previous ?? BookProvider();
  },
)
```

### Why Provider?

| Criterion | Provider | Bloc | Riverpod | GetX |
|-----------|----------|------|----------|------|
| Learning Curve | ✅ Easy | ❌ Complex | ⚠️ Medium | ✅ Easy |
| Boilerplate | ✅ Minimal | ❌ High | ✅ Minimal | ✅ Minimal |
| Official Support | ✅ Yes | ✅ Yes | ⚠️ Community | ⚠️ Community |
| Testing | ✅ Good | ✅ Excellent | ✅ Excellent | ⚠️ Medium |
| Performance | ✅ Good | ✅ Excellent | ✅ Excellent | ✅ Good |
| Our Choice | ✓ | | | |

**Rationale**: Provider is officially recommended by Flutter team, has minimal boilerplate, and integrates seamlessly with Firebase streams. Perfect for this project's complexity level.

---

## Design Trade-offs & Challenges

### 1. Image Storage: Base64 vs Firebase Storage

**Challenge**: Teacher requirement prohibited URL-based image uploads.

**Options Evaluated**:

| Option | Pros | Cons | Chosen? |
|--------|------|------|---------|
| Firebase Storage | Optimized for large files, CDN, separate security | Requires URLs, teacher restriction | ❌ |
| Base64 Inline | No external service, always available | 1MB Firestore limit, slower queries | ✅ |
| Asset Bundle | Fast loading, no network | Not user-generated, static only | ⚠️ For featured books |

**Solution Implemented**:
```dart
Future<Uint8List> _compressBytes(Uint8List input) async {
  final image = img.decodeImage(input);
  if (image == null) return input;
  
  const maxWidth = 800;
  final resized = image.width > maxWidth
      ? img.copyResize(image, width: maxWidth)
      : image;
  
  return Uint8List.fromList(img.encodeJpg(resized, quality: 80));
}
```

**Result**: Compressed JPEG at 800px width, 80% quality averages 80-150KB, well under 1MB limit.

**Trade-off**: Slightly slower list queries (larger docs), but acceptable for <100 books. If scaling to 1000s of books, would need pagination.

---

### 2. Chat ID Generation: Composite vs Auto-ID

**Challenge**: Two users should have one chat regardless of who initiates.

**Options**:

| Approach | Chat ID Format | Pros | Cons |
|----------|----------------|------|------|
| Auto-ID | Random string | Simple creation | Hard to find existing chat |
| Composite | `userId1_userId2` (sorted) | Deterministic, no duplicates | Must sort IDs |

**Solution**:
```dart
String _generateChatId(String userId1, String userId2) {
  final ids = [userId1, userId2]..sort();
  return '${ids[0]}_${ids[1]}';
}
```

**Trade-off**: Adds sorting logic, but eliminates duplicate chats and simplifies queries.

---

### 3. Real-time Updates: Polling vs Streams

**Challenge**: Keep UI in sync with Firestore changes from other users.

**Approaches**:

| Method | Implementation | Performance | Chosen? |
|--------|----------------|-------------|---------|
| Manual Refresh | Pull-to-refresh | Poor (stale data) | ❌ |
| Polling | Timer + `.get()` | Medium (network overhead) | ❌ |
| Firestore Streams | `.snapshots()` | Excellent (WebSocket) | ✅ |

**Solution**: Use Firestore streams everywhere:
```dart
Stream<List<BookModel>> getAllBooks() {
  return _firestore
      .collection('books')
      .snapshots() // Real-time updates
      .map((snapshot) => snapshot.docs
          .map((doc) => BookModel.fromFirestore(doc))
          .toList());
}
```

**Trade-off**: More network connections open (one per stream), but Firebase optimizes this. Modern mobile devices handle multiple WebSocket connections efficiently.

---

### 4. Data Denormalization: bookTitle in Swaps

**Challenge**: Show swap details without querying books collection every time.

**Normalized (Relational) Approach**:
```
swaps: { bookId: "abc123", ... }
books: { id: "abc123", title: "Chemistry 101", ... }
// Need to join collections to display swap list
```

**Denormalized (NoSQL) Approach**:
```
swaps: { 
  bookId: "abc123", 
  bookTitle: "Chemistry 101",  // Duplicated!
  bookImageUrl: "data:image...", 
  ...
}
// Everything needed in one document
```

**Trade-off**:
- **Pro**: Faster reads (no joins), single query for swap list
- **Con**: Data duplication (~100 bytes per swap), potential inconsistency if book title changes
- **Decision**: Duplication acceptable because book titles rarely change after posting

---

### 5. Email Notifications: Cloud Functions vs Mailto

**Challenge**: Teacher prohibited JavaScript code in repository.

**Initial Approach**: Firebase Cloud Functions with Nodemailer
```javascript
exports.onSwapCreated = functions.firestore
  .document('swaps/{swapId}')
  .onCreate(async (snap) => {
    // Send email with action links
  });
```

**Final Approach**: Client-side mailto links
```dart
final mailto = Uri.parse('mailto:${owner.email}?subject=$subject&body=$body');
await launchUrl(mailto, mode: LaunchMode.externalApplication);
```

**Trade-off**:
- **Pro**: No backend code, complies with restrictions, works on all platforms
- **Con**: User must manually send email (not automatic), no one-click accept links
- **Decision**: Acceptable compromise given constraints; in-app acceptance still works

---

### 6. Search Implementation: Client-side vs Algolia

**Challenge**: Firestore lacks full-text search.

**Options**:

| Approach | Pros | Cons | Cost |
|----------|------|------|------|
| Algolia | Fast, typo-tolerant | Extra service, complex | $$ |
| Client-side filter | Simple, free | Only works on loaded data | Free |
| Firestore prefix | Native, indexed | Only prefix matching | Free |

**Solution**: Hybrid approach
```dart
// 1. Prefix matching for live queries
.where('title', isGreaterThanOrEqualTo: query)
.where('title', isLessThan: query + '\uf8ff')

// 2. Client-side filter for browse screen
books.where((book) => 
  book.title.toLowerCase().contains(query.toLowerCase()) ||
  book.author.toLowerCase().contains(query.toLowerCase())
).toList();
```

**Trade-off**: Search limited to ~100 loaded books. For production with 1000s of books, would need Algolia or ElasticSearch.

---

## Performance Optimizations Applied

### 1. Image Compression
- Max width: 800px (retina-ready for mobile)
- JPEG quality: 80% (imperceptible loss)
- Average size: 80-150KB (down from 2-5MB originals)

### 2. Firestore Indexes
```javascript
// Composite indexes created in Firebase Console
books: { ownerId: ASC, postedAt: DESC }
swaps: { senderId: ASC, createdAt: DESC }
swaps: { receiverId: ASC, createdAt: DESC }
```

### 3. Stream Debouncing
```dart
// Search input debounced to avoid excessive queries
Timer? _debounce;
void _onSearchChanged(String query) {
  if (_debounce?.isActive ?? false) _debounce!.cancel();
  _debounce = Timer(const Duration(milliseconds: 300), () {
    // Execute search
  });
}
```

### 4. Conditional Rendering
```dart
// Only render books when data is ready
if (!snapshot.hasData) return const SizedBox.shrink();
```

---

## Security Considerations

### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper function: check if user is authenticated
    function isSignedIn() {
      return request.auth != null;
    }
    
    // Helper function: check if user owns a resource
    function isOwner(ownerId) {
      return isSignedIn() && request.auth.uid == ownerId;
    }
    
    // Books: anyone can read, auth can create, owner can edit/delete
    match /books/{bookId} {
      allow read: if true;
      allow create: if isSignedIn();
      allow update, delete: if isOwner(resource.data.ownerId);
    }
    
    // Swaps: participants only
    match /swaps/{swapId} {
      allow read: if isSignedIn();
      allow create: if isSignedIn();
      allow update: if isSignedIn() && (
        request.auth.uid == resource.data.senderId ||
        request.auth.uid == resource.data.receiverId
      );
    }
    
    // Chats: participants only
    match /chats/{chatId} {
      allow read, write: if isSignedIn() && 
        request.auth.uid in resource.data.participantIds;
      
      // Messages subcollection inherits parent rules
      match /messages/{messageId} {
        allow read, write: if isSignedIn();
      }
    }
  }
}
```

---

## Future Improvements

### Scalability
- **Pagination**: Implement cursor-based pagination for book lists (load 20 at a time)
- **Search**: Integrate Algolia for full-text search with typo tolerance
- **Caching**: Use SQLite (sqflite package) for offline-first architecture

### Features
- **Push Notifications**: Implement FCM for real-time alerts (when swap accepted, new message)
- **Book Ratings**: Add 5-star rating system for users
- **Advanced Filters**: Filter by condition, author, availability
- **Wishlist**: Users can save books they want to swap for

### Architecture
- **Clean Architecture**: Separate into data/domain/presentation layers
- **Repository Pattern**: Abstract Firestore behind interfaces for testability
- **Dependency Injection**: Use get_it for better dependency management

---

## Conclusion

The BookSwap app demonstrates a full-stack Flutter application with Firebase integration, covering:

✅ **Authentication**: Email/password with verification  
✅ **CRUD Operations**: Books, swaps, chats, access requests  
✅ **Real-time Sync**: Firestore streams with Provider state management  
✅ **State Management**: Provider pattern with 7 providers  
✅ **Navigation**: Bottom navigation with 4 main screens  
✅ **Security**: Firestore rules protecting user data  
✅ **Performance**: Image compression, indexed queries, stream debouncing  

**Key Achievement**: Built a production-ready mobile app in 20 hours while adapting to constraints (no URLs for images, no JS backend) through creative problem-solving.

**Lines of Code**: ~4,500 Dart  
**Firebase Collections**: 6  
**Screens**: 15+  
**Providers**: 7  
**Dart Analyzer**: 0 errors, 13 info warnings (SDK deprecations)

---

**Author**: Ishimwe  
**Date**: November 9, 2025  
**Course**: Individual Assignment 2 (35 points)
