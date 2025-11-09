import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/helpers.dart';
import '../../models/book_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/swap_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/access_request_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/book/book_condition_chip.dart';
import '../chats/chat_screen.dart';

/// Book detail screen
class BookDetailScreen extends StatelessWidget {
  final BookModel book;
  
  const BookDetailScreen({super.key, required this.book});
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserId = authProvider.currentUserId ?? '';
    final isOwner = book.ownerId == currentUserId;
  final isApproved = isOwner || book.allowedUserIds.contains(currentUserId);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Book Image
            _buildBookImage(),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(book.title, style: AppTextStyles.h2),
                  const SizedBox(height: 8),
                  
                  // Author
                  Text(
                    'By ${book.author}',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Condition
                  BookConditionChip(condition: book.condition),
                  const SizedBox(height: 16),
                  
                  // Divider
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // Owner Info
                  Text('Posted By', style: AppTextStyles.h4),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.primaryNavy,
                        child: Text(
                          Helpers.getInitials(book.ownerName),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textWhite,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(book.ownerName, style: AppTextStyles.bodyLarge),
                          Text(
                            Helpers.formatDate(book.postedAt),
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  if (!isOwner && book.isAvailable)
                    _buildActionButtons(context, currentUserId),

                  const SizedBox(height: 12),
                  // Read/Watch buttons if links exist
                  if (book.linkUrl != null || book.videoUrl != null)
                    _buildLinkButtons(context, isApproved),
                  
                  if (!book.isAvailable)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: AppColors.warning),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'This book is currently in a swap offer',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBookImage() {
    return Container(
      height: 300,
      color: AppColors.backgroundLight,
      child: _resolveImageWidget(),
    );
  }

  /// Resolve which image widget to show
  Widget _resolveImageWidget() {
    // Priority 1: base64 encoded image
    if (book.imageBase64 != null && book.imageBase64!.isNotEmpty) {
      try {
        final bytes = base64Decode(book.imageBase64!);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        );
      } catch (e) {
        return _buildPlaceholder();
      }
    }
    
    // Priority 2: URL (network or asset)
    if (book.imageUrl != null && book.imageUrl!.isNotEmpty) {
      if (book.imageUrl!.startsWith('http')) {
        return CachedNetworkImage(
          imageUrl: book.imageUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(),
          ),
          errorWidget: (context, url, error) => _buildPlaceholder(),
        );
      } else {
        return Image.asset(
          book.imageUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        );
      }
    }
    
    // Priority 3: Placeholder
    return _buildPlaceholder();
  }
  
  Widget _buildPlaceholder() {
    return const Center(
      child: Icon(
        Icons.menu_book_rounded,
        size: 100,
        color: AppColors.textSecondary,
      ),
    );
  }
  
  Widget _buildActionButtons(BuildContext context, String currentUserId) {
    return Consumer<SwapProvider>(
      builder: (context, swapProvider, _) {
        final hasOffer = swapProvider.hasSwapOffer(book.id, currentUserId);
        
        return Column(
          children: [
            CustomButton(
              text: hasOffer ? 'Swap Offer Sent' : 'Send Swap Offer',
              onPressed: hasOffer ? () {} : () => _handleSwapOffer(context),
              backgroundColor: hasOffer ? AppColors.textSecondary : AppColors.accentYellow,
              isLoading: swapProvider.isLoading,
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: 'Chat with Owner',
              onPressed: () => _handleChat(context),
              isOutlined: true,
              icon: Icons.chat_bubble_outline,
            ),
          ],
        );
      },
    );
  }

  Widget _buildLinkButtons(BuildContext context, bool isApproved) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (book.linkUrl != null) ...[
          CustomButton(
            text: isApproved ? 'Read' : 'Request Access to Read',
            onPressed: () async {
              if (isApproved) {
                final uri = Uri.parse(book.linkUrl!);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              } else {
                _requestAccess(context, 'read');
              }
            },
            icon: Icons.menu_book,
            isOutlined: !isApproved,
          ),
          const SizedBox(height: 12),
        ],
        if (book.videoUrl != null) ...[
          CustomButton(
            text: isApproved ? 'Watch' : 'Request Access to Watch',
            onPressed: () async {
              if (isApproved) {
                final uri = Uri.parse(book.videoUrl!);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              } else {
                _requestAccess(context, 'watch');
              }
            },
            icon: Icons.play_circle_fill,
            isOutlined: !isApproved,
          ),
        ],
      ],
    );
  }

  Future<void> _requestAccess(BuildContext context, String type) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final provider = Provider.of<AccessRequestProvider>(context, listen: false);
    final ok = await provider.sendRequest(
      bookId: book.id,
      bookTitle: book.title,
      ownerId: book.ownerId,
      requesterId: authProvider.currentUserId!,
      requesterName: authProvider.currentUser!.displayName,
      type: type,
    );
    if (!context.mounted) return;
    if (ok) {
      Helpers.showSuccessSnackBar(context, 'Request sent to owner');
    } else {
      Helpers.showErrorSnackBar(context, provider.errorMessage ?? 'Failed to send request');
    }
  }
  
  Future<void> _handleSwapOffer(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final swapProvider = Provider.of<SwapProvider>(context, listen: false);
    
    final success = await swapProvider.createSwap(
      book: book,
      senderId: authProvider.currentUserId!,
      senderName: authProvider.currentUser!.displayName,
    );
    
    if (!context.mounted) return;
    
    if (success) {
      Helpers.showSuccessSnackBar(context, 'Swap offer sent successfully!');
    } else {
      Helpers.showErrorSnackBar(
        context,
        swapProvider.errorMessage ?? 'Failed to send swap offer',
      );
    }
  }
  
  Future<void> _handleChat(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    
    final chatId = await chatProvider.createOrGetChat(
      currentUserId: authProvider.currentUserId!,
      currentUserName: authProvider.currentUser!.displayName,
      otherUserId: book.ownerId,
      otherUserName: book.ownerName,
    );
    
    if (!context.mounted) return;
    
    if (chatId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatId: chatId,
            otherUserName: book.ownerName,
          ),
        ),
      );
    }
  }
}
