import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/helpers.dart';
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
    final content = verticalLayout
        ? _buildVertical()
        : _buildHorizontal();
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: showActions ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: content,
      ),
    );
  }
  
  Widget _buildVertical() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Big image on top
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          child: AspectRatio(
            aspectRatio: 3/4,
            child: _resolveImageWidget(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
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
                'By ${book.author}',
                style: AppTextStyles.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              BookConditionChip(condition: book.condition),
              const SizedBox(height: 8),
              if (showOwner)
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        book.ownerName,
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      ' • ${Helpers.formatDate(book.postedAt)}',
                      style: AppTextStyles.caption,
                    ),
                  ],
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
      ],
    );
  }

  Widget _buildHorizontal() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBookImage(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(book.title, style: AppTextStyles.h4, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('By ${book.author}', style: AppTextStyles.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                BookConditionChip(condition: book.condition),
                const SizedBox(height: 8),
                if (showOwner)
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          book.ownerName,
                          style: AppTextStyles.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(' • ${Helpers.formatDate(book.postedAt)}', style: AppTextStyles.caption),
                    ],
                  ),
                if (showActions) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (onEdit != null)
                        TextButton.icon(onPressed: onEdit, icon: const Icon(Icons.edit, size: 18), label: const Text('Edit')),
                      if (onDelete != null)
                        TextButton.icon(onPressed: onDelete, icon: const Icon(Icons.delete, size: 18), label: const Text('Delete'), style: TextButton.styleFrom(foregroundColor: AppColors.error)),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
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
