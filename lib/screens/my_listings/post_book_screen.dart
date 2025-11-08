// Removed local file picking; using direct image URL instead.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/helpers.dart';
import '../../models/book_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/book_provider.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

/// Post or edit book screen
class PostBookScreen extends StatefulWidget {
  final BookModel? bookToEdit;
  
  const PostBookScreen({super.key, this.bookToEdit});
  
  @override
  State<PostBookScreen> createState() => _PostBookScreenState();
}

class _PostBookScreenState extends State<PostBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _linkUrlController = TextEditingController();
  final _videoUrlController = TextEditingController();
  String _selectedCondition = AppConstants.conditionGood;
  final _imageUrlController = TextEditingController();
  
  bool get isEditing => widget.bookToEdit != null;
  
  @override
  void initState() {
    super.initState();
    _imageUrlController.addListener(() => setState(() {}));
    if (isEditing) {
      _titleController.text = widget.bookToEdit!.title;
      _authorController.text = widget.bookToEdit!.author;
      _selectedCondition = widget.bookToEdit!.condition;
      _linkUrlController.text = widget.bookToEdit!.linkUrl ?? '';
      _videoUrlController.text = widget.bookToEdit!.videoUrl ?? '';
      _imageUrlController.text = widget.bookToEdit!.imageUrl ?? '';
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _linkUrlController.dispose();
    _videoUrlController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
  // Handle form submission
  // Handle form submission
  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final bookProvider = Provider.of<BookProvider>(context, listen: false);
    
    bool success;
    if (isEditing) {
      success = await bookProvider.updateBook(
        bookId: widget.bookToEdit!.id,
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        condition: _selectedCondition,
        imageUrl: _imageUrlController.text.trim(),
        ownerId: authProvider.currentUserId!,
        linkUrl: _linkUrlController.text.trim().isEmpty
            ? null
            : _linkUrlController.text.trim(),
        videoUrl: _videoUrlController.text.trim().isEmpty
            ? null
            : _videoUrlController.text.trim(),
      );
    } else {
      success = await bookProvider.createBook(
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        condition: _selectedCondition,
        ownerId: authProvider.currentUserId!,
        ownerName: authProvider.currentUser!.displayName,
        imageUrl: _imageUrlController.text.trim(),
        linkUrl: _linkUrlController.text.trim().isEmpty
            ? null
            : _linkUrlController.text.trim(),
        videoUrl: _videoUrlController.text.trim().isEmpty
            ? null
            : _videoUrlController.text.trim(),
      );
    }
    
    if (!mounted) return;
    
    if (success) {
      Helpers.showSuccessSnackBar(
        context,
        isEditing ? 'Book updated successfully!' : 'Book posted successfully!',
      );
      Navigator.pop(context);
    } else {
      Helpers.showErrorSnackBar(
        context,
        bookProvider.errorMessage ?? 'Failed to save book',
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Book' : 'Post a Book'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image URL field & live preview
              Text('Book Cover Image URL', style: AppTextStyles.h4),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _imageUrlController,
                label: 'Google Drive Image Link',
                hint: 'https://drive.google.com/uc?export=view&id=YOUR_FILE_ID',
                keyboardType: TextInputType.url,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Image URL required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Container(
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                clipBehavior: Clip.antiAlias,
                child: _imageUrlController.text.trim().isEmpty
                    ? Center(
                        child: Text(
                          'Enter an image URL then preview appears',
                          style: AppTextStyles.caption,
                        ),
                      )
                    : (_imageUrlController.text.startsWith('http')
                        ? Image.network(
                            _imageUrlController.text.trim(),
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Center(
                              child: Text('Invalid image URL', style: AppTextStyles.caption),
                            ),
                          )
                        : Image.asset(
                            _imageUrlController.text.trim(),
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Center(
                              child: Text('Asset not found', style: AppTextStyles.caption),
                            ),
                          )),
              ),
              const SizedBox(height: 24),
              
              // Title
              CustomTextField(
                controller: _titleController,
                label: 'Book Title',
                hint: 'Enter book title',
                validator: Validators.validateBookTitle,
              ),
              const SizedBox(height: 16),
              
              // Author
              CustomTextField(
                controller: _authorController,
                label: 'Author',
                hint: 'Enter author name',
                validator: Validators.validateAuthor,
              ),
              const SizedBox(height: 16),

              // Optional Links
              Text('Optional Links', style: AppTextStyles.h4),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _linkUrlController,
                label: 'Reading Link (optional)',
                hint: 'https://example.com/book.pdf',
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _videoUrlController,
                label: 'Video Link (optional)',
                hint: 'https://youtube.com/...',
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),
              
              // Condition
              Text('Condition', style: AppTextStyles.h4),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.bookConditions.map((condition) {
                  final isSelected = _selectedCondition == condition;
                  return ChoiceChip(
                    label: Text(condition),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedCondition = condition;
                        });
                      }
                    },
                    selectedColor: AppColors.accentYellow,
                    backgroundColor: AppColors.backgroundLight,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              
              // Submit Button
              Consumer<BookProvider>(
                builder: (context, bookProvider, _) {
                  return CustomButton(
                    text: isEditing ? 'Update Book' : 'Post Book',
                    onPressed: _handleSubmit,
                    isLoading: bookProvider.isLoading,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
