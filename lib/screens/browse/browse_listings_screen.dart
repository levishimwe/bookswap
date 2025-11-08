import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/book_provider.dart';
import '../../widgets/book/book_card.dart';
import '../../widgets/common/loading_indicator.dart';
import 'book_detail_screen.dart';
import '../../widgets/book/featured_gallery.dart';

/// Browse all book listings screen
class BrowseListingsScreen extends StatefulWidget {
  const BrowseListingsScreen({super.key});

  @override
  State<BrowseListingsScreen> createState() => _BrowseListingsScreenState();
}

class _BrowseListingsScreenState extends State<BrowseListingsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse Listings'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search by first letter (e.g. A)',
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
      body: Consumer<BookProvider>(
        builder: (context, bookProvider, _) {
          List books = bookProvider.allBooks;

          final q = _searchController.text.trim().toLowerCase();
          if (q.isNotEmpty) {
            books = books
                .where((b) => b.title.toLowerCase().startsWith(q))
                .toList();
          }

          if (bookProvider.isLoading && books.isEmpty) {
            return const LoadingIndicator(message: 'Loading books...');
          }

          return ListView(
            children: [
              const FeaturedGallery(title: 'Featured'),
              const SizedBox(height: 8),
              if (books.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
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
                          'No books found',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...books.map((book) => BookCard(
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
                    )),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}
