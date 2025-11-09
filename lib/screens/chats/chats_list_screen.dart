import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';
import '../../providers/chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/users_provider.dart';
import 'chat_screen.dart';

/// Chats list screen
class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key});
  
  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.currentUserId ?? '';
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search users…',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Live user search suggestions by first letters
          Consumer<UsersProvider>(
            builder: (context, usersProvider, _) {
              final q = _searchController.text.trim();
              if (q.isEmpty) return const SizedBox.shrink();
              final suggestions = usersProvider.searchByStartsWith(q)
                  .where((u) => u.uid != currentUserId)
                  .toList();
              if (suggestions.isEmpty) return const SizedBox.shrink();
              return SizedBox(
                height: 160,
                child: ListView.separated(
                  itemCount: suggestions.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final u = suggestions[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryNavy,
                        child: Text(
                          Helpers.getInitials(u.displayName),
                          style: const TextStyle(color: AppColors.textWhite),
                        ),
                      ),
                      title: Text(u.displayName),
                      subtitle: Text(u.email, maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final chatId = await Provider.of<ChatProvider>(context, listen: false).createOrGetChat(
                          currentUserId: currentUserId,
                          currentUserName: authProvider.currentUser?.displayName ?? 'Me',
                          otherUserId: u.uid,
                          otherUserName: u.displayName,
                        );
                        if (!context.mounted || chatId == null) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(chatId: chatId, otherUserName: u.displayName),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
          const Divider(height: 1),
          // Existing chats list
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, _) {
                var chats = chatProvider.chats;
                final q = _searchController.text.trim().toLowerCase();
                if (q.isNotEmpty) {
                  chats = chats
                      .where((c) => c
                          .getOtherParticipantName(currentUserId)
                          .toLowerCase()
                          .startsWith(q))
                      .toList();
                }

                if (chats.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 80,
                          color: AppColors.textSecondary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No conversations yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index];
                    final otherUserName = chat.getOtherParticipantName(currentUserId);
                    final unreadCount = chat.getUnreadCount(currentUserId);

                    return Dismissible(
                      key: Key(chat.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: AppColors.error,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Chat'),
                            content: const Text('Delete this conversation?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (_) async {
                        await chatProvider.deleteChat(chat.id);
                      },
                      child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryNavy,
                        child: Text(
                          Helpers.getInitials(otherUserName),
                          style: const TextStyle(color: AppColors.textWhite),
                        ),
                      ),
                      title: Text(
                        otherUserName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        chat.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            Helpers.formatChatTime(chat.lastMessageTime),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (unreadCount > 0) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$unreadCount',
                                style: const TextStyle(
                                  color: AppColors.textWhite,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              chatId: chat.id,
                              otherUserName: otherUserName,
                            ),
                          ),
                        );
                      },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
