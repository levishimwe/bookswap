import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
// Removed PDF support: file_picker no longer needed
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
  final ImagePicker _picker = ImagePicker();
  Uint8List? _pickedBytes; // supports web & mobile
  // PDF fields removed; use link URL instead
  
  bool get isEditing => widget.bookToEdit != null;
  
  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _titleController.text = widget.bookToEdit!.title;
      _authorController.text = widget.bookToEdit!.author;
      _selectedCondition = widget.bookToEdit!.condition;
      _linkUrlController.text = widget.bookToEdit!.linkUrl ?? '';
      _videoUrlController.text = widget.bookToEdit!.videoUrl ?? '';
      // Decode existing base64 image if available for preview
      if (widget.bookToEdit!.imageBase64 != null && widget.bookToEdit!.imageBase64!.isNotEmpty) {
        try {
          _pickedBytes = base64Decode(widget.bookToEdit!.imageBase64!);
        } catch (_) {
          // Ignore decode errors
        }
      }
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _linkUrlController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;
    if (kIsWeb) {
      final bytes = await file.readAsBytes();
      setState(() => _pickedBytes = bytes);
    } else {
      final bytes = await file.readAsBytes();
      setState(() => _pickedBytes = bytes);
    }
  }

  // PDF picking removed; users should supply an external reading link.
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
        imageBytes: _pickedBytes,
        existingImageBase64: widget.bookToEdit!.imageBase64,
  // PDF removed
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
        imageBytes: _pickedBytes,
  // PDF removed
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
              // Image picker & preview
              Text('Book Cover', style: AppTextStyles.h4),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                    color: AppColors.cardBackground,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _pickedBytes == null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add_a_photo, size: 48, color: Colors.black54),
                              const SizedBox(height: 8),
                              Text('Tap to pick a cover image', style: AppTextStyles.caption),
                            ],
                          ),
                        )
                      : Image.memory(_pickedBytes!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 24),
              
              // PDF picker removed. Use reading link below instead.
              const SizedBox(height: 8),
              
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
