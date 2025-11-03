import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/book_provider.dart';
import '../../widgets/book/book_card.dart';
import '../../widgets/common/loading_indicator.dart';
import 'book_detail_screen.dart';

/// Browse all book listings screen
class BrowseListingsScreen extends StatelessWidget {
  const BrowseListingsScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Listings'),
      ),
      body: Consumer<BookProvider>(
        builder: (context, bookProvider, _) {
          final books = bookProvider.allBooks;
          
          if (bookProvider.isLoading && books.isEmpty) {
            return const LoadingIndicator(message: 'Loading books...');
          }
          
          if (books.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.library_books_outlined,
                    size: 80,
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No books available yet',
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
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return BookCard(
                book: book,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookDetailScreen(book: book),
                    ),
                  );
                },
                showOwner: true,
              );
            },
          );
        },
      ),
    );
  }
}
