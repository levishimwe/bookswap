import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';

/// Chat state provider
class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  
  List<ChatModel> _chats = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  List<ChatModel> get chats => _chats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  /// Get total unread count
  int getTotalUnreadCount(String userId) {
    int total = 0;
    for (var chat in _chats) {
      total += chat.getUnreadCount(userId);
    }
    return total;
  }
  
  /// Initialize chat provider
  void initialize(String userId) {
    // Listen to user's chats
    _chatService.getUserChats(userId).listen((chats) {
      _chats = chats;
      notifyListeners();
    });
  }
  
  /// Create or get chat
  Future<String?> createOrGetChat({
    required String currentUserId,
    required String currentUserName,
    required String otherUserId,
    required String otherUserName,
  }) async {
    try {
      _setLoading(true);
      _errorMessage = null;
      
      final chatId = await _chatService.createOrGetChat(
        currentUserId: currentUserId,
        currentUserName: currentUserName,
        otherUserId: otherUserId,
        otherUserName: otherUserName,
      );
      
      _setLoading(false);
      return chatId;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return null;
    }
  }
  
  /// Send message
  Future<bool> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String receiverId,
    required String text,
  }) async {
    try {
      await _chatService.sendMessage(
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
        receiverId: receiverId,
        text: text,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  /// Get messages stream
  Stream<List<MessageModel>> getMessages(String chatId) {
    return _chatService.getMessages(chatId);
  }
  
  /// Mark messages as read
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    await _chatService.markMessagesAsRead(chatId, userId);
  }
  
  /// Get chat by ID
  Future<ChatModel?> getChat(String chatId) async {
    try {
      return await _chatService.getChat(chatId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }
  
  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Delete a chat conversation
  Future<bool> deleteChat(String chatId) async {
    try {
      await _chatService.deleteChat(chatId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Delete a single message
  Future<bool> deleteMessage(String chatId, String messageId) async {
    try {
      await _chatService.deleteMessage(chatId, messageId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Edit a message
  Future<bool> editMessage(String chatId, String messageId, String newText) async {
    try {
      await _chatService.editMessage(chatId, messageId, newText);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  /// Dispose
  @override
  void dispose() {
    super.dispose();
  }
}
