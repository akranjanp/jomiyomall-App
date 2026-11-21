import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/widgets/error_state_view.dart';
import '../../shared/models/product_model.dart';
import '../../shared/providers/app_providers.dart';
import 'widgets/product_card.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  final int? categoryId;
  final String title;

  const ProductListScreen({
    super.key,
    this.categoryId,
    required this.title,
  });

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  String _selectedSort = 'default';

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<ProductModel>> productsAsync = widget.categoryId != null
        ? ref.watch(categoryProductsProvider(widget.categoryId!))
        : ref.watch(featuredProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Sort Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sort by:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                DropdownButton<String>(
                  value: _selectedSort,
                  underline: const SizedBox.shrink(),
                  isDense: true,
                  style: const TextStyle(fontSize: 13, color: Colors.black),
                  items: const [
                    DropdownMenuItem(value: 'default', child: Text('Default')),
                    DropdownMenuItem(value: 'price_low', child: Text('Price: Low to High')),
                    DropdownMenuItem(value: 'price_high', child: Text('Price: High to Low')),
                    DropdownMenuItem(value: 'rating', child: Text('Highest Rated')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedSort = val);
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: productsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return const EmptyStateView(
                    icon: Icons.inventory_2_outlined,
                    title: 'No Products Found',
                    message: 'No items currently in this section. Please check back later.',
                  );
                }

                // Apply Sorting
                List<ProductModel> sortedList = List.from(products);
                if (_selectedSort == 'price_low') {
                  sortedList.sort((a, b) => a.price.compareTo(b.price));
                } else if (_selectedSort == 'price_high') {
                  sortedList.sort((a, b) => b.price.compareTo(a.price));
                } else if (_selectedSort == 'rating') {
                  sortedList.sort((a, b) => b.rating.compareTo(a.rating));
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    if (widget.categoryId != null) {
                      ref.invalidate(categoryProductsProvider(widget.categoryId!));
                    } else {
                      ref.invalidate(featuredProductsProvider);
                    }
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.all(14),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.58,
                    ),
                    itemCount: sortedList.length,
                    itemBuilder: (context, index) {
                      return ProductCard(product: sortedList[index]);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => ErrorStateView(
                message: err.toString(),
                onRetry: () {
                  if (widget.categoryId != null) {
                    ref.invalidate(categoryProductsProvider(widget.categoryId!));
                  } else {
                    ref.invalidate(featuredProductsProvider);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
