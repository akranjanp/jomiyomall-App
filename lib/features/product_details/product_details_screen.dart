import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/custom_cached_image.dart';
import '../../core/widgets/error_state_view.dart';
import '../../shared/providers/app_providers.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  final int productId;

  const ProductDetailsScreen({
    super.key,
    required this.productId,
  });

  @override
  ConsumerState<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  int _currentImageIndex = 0;
  int _quantity = 1;
  final Map<String, String> _selectedAttributes = {};

  Map<String, dynamic>? _getMatchingVariation(List<Map<String, dynamic>> variations) {
    if (variations.isEmpty || _selectedAttributes.isEmpty) return null;

    for (final v in variations) {
      bool allMatch = true;
      final vAttrs = v['attributes'];
      if (vAttrs is List) {
        for (final vAttr in vAttrs) {
          if (vAttr is Map) {
            final attrName = vAttr['name']?.toString() ?? '';
            final attrVal = (vAttr['option'] ?? vAttr['value'])?.toString() ?? '';
            final userSelected = _selectedAttributes[attrName] ??
                _selectedAttributes.entries
                    .firstWhere(
                      (e) => e.key.toLowerCase() == attrName.toLowerCase(),
                      orElse: () => const MapEntry('', ''),
                    )
                    .value;
            if (userSelected.isNotEmpty &&
                attrVal.isNotEmpty &&
                userSelected.toLowerCase() != attrVal.toLowerCase()) {
              allMatch = false;
              break;
            }
          }
        }
      }
      if (allMatch) return v;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailsProvider(widget.productId));
    final wishlist = ref.watch(wishlistProvider);
    final isFav = wishlist.contains(widget.productId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? AppColors.error : AppColors.textPrimaryLight,
            ),
            onPressed: () {
              ref.read(wishlistProvider.notifier).toggleWishlist(widget.productId);
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => context.push('/cart'),
          ),
        ],
      ),
      body: productAsync.when(
        data: (product) {
          final variationsAsync = ref.watch(productVariationsProvider(widget.productId));
          final variations = variationsAsync.value ?? [];

          // Initialize default attributes if not yet set
          if (product.isVariable && _selectedAttributes.isEmpty) {
            for (final attr in product.attributes) {
              if (attr.options.isNotEmpty) {
                _selectedAttributes[attr.name] = attr.options.first;
              }
            }
          }

          final matchingVariation = _getMatchingVariation(variations);
          double displayPrice = product.price;
          double displayRegularPrice = product.regularPrice;
          int? matchedVariationId;

          if (matchingVariation != null) {
            matchedVariationId = int.tryParse(matchingVariation['id']?.toString() ?? '');
            final vPrice = double.tryParse(matchingVariation['price']?.toString() ?? '');
            final vReg = double.tryParse(matchingVariation['regular_price']?.toString() ?? '');
            if (vPrice != null && vPrice > 0) {
              displayPrice = vPrice;
            }
            if (vReg != null && vReg > 0) {
              displayRegularPrice = vReg;
            }
          }

          final cleanDesc = product.description.replaceAll(RegExp(r'<[^>]*>'), '').trim();

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image Gallery Carousel
                      Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          CarouselSlider.builder(
                            itemCount: product.images.length,
                            options: CarouselOptions(
                              height: 320,
                              viewportFraction: 1.0,
                              onPageChanged: (index, _) {
                                setState(() => _currentImageIndex = index);
                              },
                            ),
                            itemBuilder: (context, index, _) {
                              return CustomCachedImage(
                                imageUrl: product.images[index],
                                width: double.infinity,
                                height: 320,
                                fit: BoxFit.cover,
                                borderRadius: 0,
                              );
                            },
                          ),
                          if (product.images.length > 1)
                            Positioned(
                              bottom: 12,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  product.images.length,
                                  (index) => Container(
                                    width: _currentImageIndex == index ? 20 : 7,
                                    height: 7,
                                    margin: const EdgeInsets.symmetric(horizontal: 3),
                                    decoration: BoxDecoration(
                                      color: _currentImageIndex == index
                                          ? AppColors.primary
                                          : Colors.white.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimaryLight,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Rating & Stock Row
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        product.rating.toStringAsFixed(1),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: AppColors.success,
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                      const Icon(Icons.star, size: 12, color: AppColors.success),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${product.ratingCount} Ratings',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: product.isInStock
                                        ? AppColors.success.withOpacity(0.1)
                                        : AppColors.error.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    product.isInStock ? 'IN STOCK' : 'OUT OF STOCK',
                                    style: TextStyle(
                                      color: product.isInStock ? AppColors.success : AppColors.error,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Pricing
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  CurrencyFormatter.format(displayPrice),
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.primary,
                                  ),
                                ),
                                if (displayRegularPrice > displayPrice) ...[
                                  const SizedBox(width: 10),
                                  Text(
                                    CurrencyFormatter.format(displayRegularPrice),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: AppColors.textSecondaryLight,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${(((displayRegularPrice - displayPrice) / displayRegularPrice) * 100).round()}% OFF',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.error,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Inclusive of all taxes. Free shipping on orders over ₹999.',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                            ),

                            const Divider(height: 32),

                            // Variable Product Attributes (Size, Color, etc.)
                            if (product.isVariable && product.attributes.isNotEmpty) ...[
                              for (final attr in product.attributes) ...[
                                Text(
                                  'Select ${attr.name}: ${_selectedAttributes[attr.name] ?? ""}',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: attr.options.map((opt) {
                                    final isSelected = _selectedAttributes[attr.name]?.toLowerCase() == opt.toLowerCase();
                                    return ChoiceChip(
                                      label: Text(opt),
                                      selected: isSelected,
                                      selectedColor: AppColors.primary,
                                      backgroundColor: Colors.grey.shade100,
                                      showCheckmark: false,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide(
                                          color: isSelected ? AppColors.primary : AppColors.borderLight,
                                          width: isSelected ? 1.5 : 1.0,
                                        ),
                                      ),
                                      labelStyle: TextStyle(
                                        color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        fontSize: 13,
                                      ),
                                      onSelected: (selected) {
                                        if (selected) {
                                          setState(() => _selectedAttributes[attr.name] = opt);
                                        }
                                      },
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 16),
                              ],
                              const Divider(height: 16),
                            ],

                            // Quantity Selector
                            Row(
                              children: [
                                const Text('Quantity:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 16),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: AppColors.borderLight),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove, size: 18),
                                        onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                                      ),
                                      Text(
                                        '$_quantity',
                                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add, size: 18),
                                        onPressed: () => setState(() => _quantity++),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const Divider(height: 32),

                            // Product Description
                            const Text(
                              'Product Description',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              cleanDesc.isNotEmpty ? cleanDesc : product.shortDescription,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textPrimaryLight,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Action Bar
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: const Border(top: BorderSide(color: AppColors.borderLight)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      // Add to Cart
                      Expanded(
                        child: AppButton(
                          text: 'ADD TO CART',
                          isOutlined: true,
                          icon: Icons.add_shopping_cart,
                          onPressed: () {
                            ref.read(cartProvider.notifier).addToCart(
                              product,
                              quantity: _quantity,
                              attributes: _selectedAttributes.isNotEmpty ? _selectedAttributes : null,
                              variationId: matchedVariationId,
                              price: displayPrice,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$_quantity item(s) added to cart!'),
                                duration: const Duration(seconds: 2),
                                action: SnackBarAction(
                                  label: 'VIEW CART',
                                  textColor: AppColors.secondary,
                                  onPressed: () => context.push('/cart'),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Buy Now
                      Expanded(
                        child: AppButton(
                          text: 'BUY NOW',
                          backgroundColor: AppColors.secondary,
                          icon: Icons.bolt,
                          onPressed: () {
                            ref.read(cartProvider.notifier).addToCart(
                              product,
                              quantity: _quantity,
                              attributes: _selectedAttributes.isNotEmpty ? _selectedAttributes : null,
                              variationId: matchedVariationId,
                              price: displayPrice,
                            );
                            context.push('/checkout');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ErrorStateView(
          message: err.toString(),
          onRetry: () => ref.invalidate(productDetailsProvider(widget.productId)),
        ),
      ),
    );
  }
}
