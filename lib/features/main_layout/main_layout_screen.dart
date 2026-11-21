import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../shared/providers/app_providers.dart';
import '../home/home_screen.dart';
import '../categories/categories_screen.dart';
import '../wishlist/wishlist_screen.dart';
import '../cart/cart_screen.dart';
import '../profile/profile_screen.dart';

class MainLayoutScreen extends ConsumerStatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  ConsumerState<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends ConsumerState<MainLayoutScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CategoriesScreen(),
    WishlistScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final wishlist = ref.watch(wishlistProvider);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondaryLight,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            activeIcon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: wishlist.isNotEmpty,
              label: Text('${wishlist.length}'),
              child: const Icon(Icons.favorite_border),
            ),
            activeIcon: Badge(
              isLabelVisible: wishlist.isNotEmpty,
              label: Text('${wishlist.length}'),
              child: const Icon(Icons.favorite),
            ),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: cart.items.isNotEmpty,
              label: Text('${cart.items.length}'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            activeIcon: Badge(
              isLabelVisible: cart.items.isNotEmpty,
              label: Text('${cart.items.length}'),
              child: const Icon(Icons.shopping_cart),
            ),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
