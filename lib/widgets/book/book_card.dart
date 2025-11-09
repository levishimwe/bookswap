import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../models/book_model.dart';
import 'book_condition_chip.dart';

/// Book card widget for displaying book listings
class BookCard extends StatelessWidget {
  final BookModel book;
  final VoidCallback onTap;
  final VoidCallback? onSwap;
  final bool showOwner;
  final bool showActions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool verticalLayout; // image on top, details below
  
  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
    this.onSwap,
    this.showOwner = true,
    this.showActions = false,
    this.onEdit,
    this.onDelete,
    this.verticalLayout = true,
  });
  
  @override
  Widget build(BuildContext context) {
    // Always use horizontal style matching screenshot
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F0FA), // light blue
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: showActions ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBookImage(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: AppTextStyles.h4,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'by ${book.author}',
                      style: AppTextStyles.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    BookConditionChip(condition: book.condition),
                    const SizedBox(height: 8),
                    if (showOwner)
                      Text(
                        'Owner: ${book.ownerName}',
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (showActions) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (onEdit != null)
                            TextButton.icon(
                              onPressed: onEdit,
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('Edit'),
                            ),
                          if (onDelete != null)
                            TextButton.icon(
                              onPressed: onDelete,
                              icon: const Icon(Icons.delete, size: 18),
                              label: const Text('Delete'),
                              style: TextButton.styleFrom(foregroundColor: AppColors.error),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (onSwap != null && !showActions)
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: ElevatedButton(
                    onPressed: onSwap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3), // blue
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      elevation: 0,
                    ),
                    child: const Text('Swap', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  

  Widget _buildBookImage() {
    return Container(
      width: 80,
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: _resolveImageWidget(),
      ),
    );
  }

  Widget _resolveImageWidget() {
    final path = book.imageUrl;
    // Prefer inline base64 image if available
    if (book.imageBase64 != null && book.imageBase64!.isNotEmpty) {
      try {
        final bytes = base64Decode(book.imageBase64!);
        return Image.memory(bytes, fit: BoxFit.cover, errorBuilder: (c, e, s) => _buildPlaceholder());
      } catch (_) {
        // fall through to other methods
      }
    }
    if (path == null || path.isEmpty) return _buildPlaceholder();
    // If user provided a direct http(s) link use network image
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        errorWidget: (context, url, error) => _buildPlaceholder(),
      );
    }
    // Otherwise treat as bundled asset (e.g. assets/images/...)
    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) => _buildPlaceholder(),
    );
  }
  
  Widget _buildPlaceholder() {
    return const Icon(
      Icons.book,
      size: 40,
      color: AppColors.textSecondary,
    );
  }
}
