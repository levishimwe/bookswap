
class FeaturedBook {
  final String asset; // assets/images/<file>
  final String title; // Short display title
  final String link;  // External URL
  final String caption; // Short words under the image

  const FeaturedBook({
    required this.asset,
    required this.title,
    required this.link,
    required this.caption,
  });
}

// Static featured entries shown on Home and Browse screens
const List<FeaturedBook> kFeaturedBooks = [
  FeaturedBook(
    asset: 'assets/images/the_pilgrim-s_progress.avif',
    title: "The Pilgrim's Progress",
    link: 'https://www.gutenberg.org/ebooks/131',
    caption: "Classic Christian allegory — Project Gutenberg",
  ),
  FeaturedBook(
    asset: 'assets/images/loveof_God.jpeg',
    title: 'The Love of God',
    link: 'https://www.biblegateway.com/',
    caption: 'Scripture reading — Bible Gateway',
  ),
  FeaturedBook(
    asset: 'assets/images/flutter-book.jpeg',
    title: 'Flutter Learning Resources',
    link: 'https://docs.flutter.dev/reference/learning-resources',
    caption: 'Build apps with Flutter — docs.flutter.dev',
  ),
  FeaturedBook(
    asset: 'assets/images/firebase-learn.jpeg',
    title: 'Learn Firebase',
    link: 'https://firebase.google.com/docs',
    caption: 'Backend for apps — Official Docs',
  ),
  FeaturedBook(
    asset: 'assets/images/node-js.png',
    title: 'Learn Node.js',
    link: 'https://reactdom.com/node/',
    caption: 'Server-side JavaScript — ReactDOM Node guide',
  ),
];
