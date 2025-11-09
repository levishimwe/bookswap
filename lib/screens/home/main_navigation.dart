import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/book_provider.dart';
import '../../providers/swap_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/access_request_provider.dart';
import '../../providers/users_provider.dart';
import '../browse/browse_listings_screen.dart';
import 'home_screen.dart';
import '../my_listings/my_listings_screen.dart';
import '../chats/chats_list_screen.dart';
import '../settings/settings_screen.dart';
import '../swaps/swap_requests_screen.dart';

/// Main navigation with bottom navigation bar
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = const [
    HomeScreen(),
    BrowseListingsScreen(),
    MyListingsScreen(),
    SwapRequestsScreen(), // New dedicated Requests screen (swap + access)
    ChatsListScreen(),
    SettingsScreen(),
  ];
  
  @override
  void initState() {
    super.initState();
    _initializeProviders();
  }
  
  void _initializeProviders() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.currentUserId;
    
    if (userId != null) {
      Provider.of<BookProvider>(context, listen: false).initialize(userId);
      Provider.of<SwapProvider>(context, listen: false).initialize(userId);
      Provider.of<ChatProvider>(context, listen: false).initialize(userId);
      Provider.of<SettingsProvider>(context, listen: false).initialize(userId);
  Provider.of<UsersProvider>(context, listen: false).initialize();
      // Access requests for books owned by the user
      Provider.of<AccessRequestProvider>(context, listen: false).initialize(userId);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.primaryNavy,
        selectedItemColor: AppColors.accentYellow,
        unselectedItemColor: AppColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'Browse',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books_outlined),
            activeIcon: Icon(Icons.library_books),
            label: 'My Listings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            activeIcon: Icon(Icons.compare_arrows),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
