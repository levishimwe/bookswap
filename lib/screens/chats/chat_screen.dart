import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/chat/message_bubble.dart';

/// Chat screen for individual conversation
class ChatScreen extends StatefulWidget {
  final String chatId;
  final String otherUserName;
  
  const ChatScreen({
    super.key,
    required this.chatId,
    required this.otherUserName,
  });
  
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    _markAsRead();
  }
  
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  void _markAsRead() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    chatProvider.markMessagesAsRead(widget.chatId, authProvider.currentUserId!);
  }
  
  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    
    final chat = await chatProvider.getChat(widget.chatId);
    if (chat == null) return;
    
    final otherUserId = chat.participantIds.firstWhere(
      (id) => id != authProvider.currentUserId,
    );
    
    _messageController.clear();
    
    await chatProvider.sendMessage(
      chatId: widget.chatId,
      senderId: authProvider.currentUserId!,
      senderName: authProvider.currentUser!.displayName,
      receiverId: otherUserId,
      text: text,
    );
  }

  Future<void> _deleteMessage(String messageId) async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final success = await chatProvider.deleteMessage(widget.chatId, messageId);
    
    if (!mounted) return;
    
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(chatProvider.errorMessage ?? 'Failed to delete message'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _editMessage(String messageId, String newText) async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    final success = await chatProvider.editMessage(widget.chatId, messageId, newText);
    
    if (!mounted) return;
    
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(chatProvider.errorMessage ?? 'Failed to edit message'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.currentUserId ?? '';
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUserName),
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, _) {
                return StreamBuilder(
                  stream: chatProvider.getMessages(widget.chatId),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    final messages = snapshot.data!;
                    
                    if (messages.isEmpty) {
                      return const Center(
                        child: Text(
                          'No messages yet\nStart the conversation!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      );
                    }
                    
                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMe = message.senderId == currentUserId;
                        return MessageBubble(
                          message: message,
                          isMe: isMe,
                          onDelete: isMe ? (messageId) => _deleteMessage(messageId) : null,
                          onEdit: isMe ? (messageId, currentText) => _editMessage(messageId, currentText) : null,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          
          // Message Input
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  mini: true,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
