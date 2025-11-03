import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
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
  String _selectedCondition = AppConstants.conditionGood;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  
  bool get isEditing => widget.bookToEdit != null;
  
  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _titleController.text = widget.bookToEdit!.title;
      _authorController.text = widget.bookToEdit!.author;
      _selectedCondition = widget.bookToEdit!.condition;
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }
  
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }
  
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
        existingImageUrl: widget.bookToEdit!.imageUrl,
        newImageFile: _imageFile,
        ownerId: authProvider.currentUserId!,
      );
    } else {
      success = await bookProvider.createBook(
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
        condition: _selectedCondition,
        ownerId: authProvider.currentUserId!,
        ownerName: authProvider.currentUser!.displayName,
        imageFile: _imageFile,
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
              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_imageFile!, fit: BoxFit.cover),
                        )
                      : widget.bookToEdit?.imageUrl != null && _imageFile == null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                widget.bookToEdit!.imageUrl!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.add_photo_alternate,
                                  size: 60,
                                  color: AppColors.textSecondary,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap to add book cover',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                ),
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
