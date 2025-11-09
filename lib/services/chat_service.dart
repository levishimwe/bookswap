import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/message_model.dart';
import '../models/chat_model.dart';

/// Chat service for real-time messaging
class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Create or get existing chat between two users
  Future<String> createOrGetChat({
    required String currentUserId,
    required String currentUserName,
    required String otherUserId,
    required String otherUserName,
  }) async {
    try {
      // Generate consistent chat ID
      final chatId = _generateChatId(currentUserId, otherUserId);
      
      // Check if chat already exists
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      
      if (!chatDoc.exists) {
        // Create new chat
        final chat = ChatModel(
          id: chatId,
          participantIds: [currentUserId, otherUserId],
          participantNames: {
            currentUserId: currentUserName,
            otherUserId: otherUserName,
          },
          lastMessage: '',
          lastMessageSenderId: '',
          lastMessageTime: DateTime.now(),
          unreadCount: {
            currentUserId: 0,
            otherUserId: 0,
          },
        );
        
        await _firestore.collection('chats').doc(chatId).set(chat.toMap());
      }
      
      return chatId;
    } catch (e) {
      throw 'Failed to create chat. Please try again.';
    }
  }
  
  /// Send a message
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String receiverId,
    required String text,
  }) async {
    try {
      final message = MessageModel(
        id: '',
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
        receiverId: receiverId,
        text: text,
        timestamp: DateTime.now(),
        isRead: false,
      );
      
      // Add message to subcollection
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(message.toMap());
      
      // Update chat document with last message
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': text,
        'lastMessageSenderId': senderId,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'unreadCount.$receiverId': FieldValue.increment(1),
      });

      // Flag for Cloud Function to send email notification (lightweight trigger field)
      await _firestore.collection('notifications').add({
        'type': 'chat_message',
        'chatId': chatId,
        'senderId': senderId,
        'receiverId': receiverId,
        'senderName': senderName,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw 'Failed to send message. Please try again.';
    }
  }
  
  /// Get messages for a chat
  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromFirestore(doc))
            .toList());
  }
  
  /// Get all chats for a user
  Stream<List<ChatModel>> getUserChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ChatModel.fromFirestore(doc)).toList());
  }
  
  /// Mark messages as read
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      // Reset unread count for this user
      await _firestore.collection('chats').doc(chatId).update({
        'unreadCount.$userId': 0,
      });
      
      // Mark all unread messages as read
      final unreadMessages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();
      
      final batch = _firestore.batch();
      for (var doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      // Silently fail
      print('Failed to mark messages as read: $e');
    }
  }
  
  /// Get chat by ID
  Future<ChatModel?> getChat(String chatId) async {
    try {
      final doc = await _firestore.collection('chats').doc(chatId).get();
      if (!doc.exists) return null;
      return ChatModel.fromFirestore(doc);
    } catch (e) {
      return null;
    }
  }
  
  /// Generate consistent chat ID from two user IDs
  String _generateChatId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  /// Delete a chat conversation
  Future<void> deleteChat(String chatId) async {
    try {
      // Delete all messages first
      final messagesSnapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .get();
      
      final batch = _firestore.batch();
      for (var doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      // Delete chat document
      batch.delete(_firestore.collection('chats').doc(chatId));
      
      await batch.commit();
    } catch (e) {
      throw 'Failed to delete chat. Please try again.';
    }
  }

  /// Delete a single message
  Future<void> deleteMessage(String chatId, String messageId) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .delete();
    } catch (e) {
      throw 'Failed to delete message. Please try again.';
    }
  }

  /// Edit a message
  Future<void> editMessage(String chatId, String messageId, String newText) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({'text': newText});
      
      // Update last message in chat if this was the most recent
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      if (chatDoc.exists) {
        final lastMessageSnapshot = await _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();
        
        if (lastMessageSnapshot.docs.isNotEmpty) {
          final lastMessage = lastMessageSnapshot.docs.first;
          if (lastMessage.id == messageId) {
            await _firestore.collection('chats').doc(chatId).update({
              'lastMessage': newText,
            });
          }
        }
      }
    } catch (e) {
      throw 'Failed to edit message. Please try again.';
    }
  }
}
