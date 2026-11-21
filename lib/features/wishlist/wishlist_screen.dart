import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/error_state_view.dart';
import '../../shared/providers/app_providers.dart';
import '../products/widgets/product_card.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistIds = ref.watch(wishlistProvider);
    final featuredAsync = ref.watch(featuredProductsProvider);

    if (wishlistIds.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Wishlist', style: TextStyle(fontWeight: FontWeight.bold))),
        body: EmptyStateView(
          icon: Icons.favorite_border,
          title: 'Your Wishlist is Empty',
          message: 'Save items you love by tapping the heart icon on any product.',
          buttonText: 'EXPLORE PRODUCTS',
          onButtonPressed: () => context.go('/home'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('My Wishlist (${wishlistIds.length})', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: featuredAsync.when(
        data: (products) {
          // Filter products matching wishlist IDs
          final wishlisted = products.where((p) => wishlistIds.contains(p.id)).toList();

          if (wishlisted.isEmpty) {
            return const Center(child: Text('Wishlist items saved.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(14),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.58,
            ),
            itemCount: wishlisted.length,
            itemBuilder: (context, index) {
              return ProductCard(product: wishlisted[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error loading wishlist products.')),
      ),
    );
  }
}
