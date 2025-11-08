import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/book_provider.dart';
import '../../widgets/book/book_card.dart';
import '../../widgets/common/loading_indicator.dart';
import '../browse/book_detail_screen.dart';
import '../../widgets/book/featured_gallery.dart';

/// Home screen showing all books
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Consumer<BookProvider>(
        builder: (context, bookProvider, _) {
          final books = bookProvider.allBooks;

          if (bookProvider.isLoading && books.isEmpty) {
            return const LoadingIndicator(message: 'Loading books...');
          }

          return ListView(
            children: [
              const FeaturedGallery(title: 'Featured'),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text('All Books', style: Theme.of(context).textTheme.titleLarge),
              ),
              if (books.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                  child: Center(child: Text('No books yet. Post your first book!')),
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
