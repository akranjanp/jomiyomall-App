import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/error_state_view.dart';
import '../../shared/providers/app_providers.dart';
import '../products/widgets/product_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(searchQueryProvider.notifier).state = query;
      if (query.trim().isNotEmpty) {
        ref.read(localStorageProvider).addRecentSearch(query.trim());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final searchResultsAsync = ref.watch(searchResultsProvider);
    final recentSearches = ref.watch(localStorageProvider).getRecentSearches();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search products, brands and more...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(searchQueryProvider.notifier).state = '';
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            ),
            onChanged: _onSearchChanged,
          ),
        ),
      ),
      body: query.isEmpty
          ? _buildRecentSearches(recentSearches)
          : searchResultsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.search_off_outlined,
                    title: 'No Results Found',
                    message: 'We couldn\'t find any products matching "$query". Please check spelling or try other keywords.',
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(14),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.58,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return ProductCard(product: products[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => ErrorStateView(
                message: err.toString(),
                onRetry: () => ref.invalidate(searchResultsProvider),
              ),
            ),
    );
  }

  Widget _buildRecentSearches(List<String> searches) {
    if (searches.isEmpty) {
      return const EmptyStateView(
        icon: Icons.search,
        title: 'Search Jomiyo Mall',
        message: 'Type in a product name, category, or brand to find what you love.',
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Searches', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              InkWell(
                onTap: () {
                  ref.read(localStorageProvider).clearRecentSearches();
                  setState(() {});
                },
                child: const Text('Clear All', style: TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: searches.map((s) {
              return ActionChip(
                label: Text(s),
                avatar: const Icon(Icons.history, size: 16),
                onPressed: () {
                  _searchController.text = s;
                  ref.read(searchQueryProvider.notifier).state = s;
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
