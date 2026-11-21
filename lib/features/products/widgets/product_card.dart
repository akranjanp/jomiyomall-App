import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/custom_cached_image.dart';
import '../../../shared/models/product_model.dart';
import '../../../shared/providers/app_providers.dart';

class ProductCard extends ConsumerWidget {
  final ProductModel product;

  const ProductCard({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlist = ref.watch(wishlistProvider);
    final isFav = wishlist.contains(product.id);

    return InkWell(
      onTap: () => context.push('/product/${product.id}'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack with Badges & Wishlist Heart
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: CustomCachedImage(
                      imageUrl: product.images.isNotEmpty ? product.images.first : '',
                      borderRadius: 0,
                    ),
                  ),
                ),
                // Discount Badge
                if (product.onSale && product.discountPercentage > 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '-${product.discountPercentage}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                // Wishlist Heart Button
                Positioned(
                  top: 4,
                  right: 4,
                  child: IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? AppColors.error : AppColors.textSecondaryLight,
                      size: 22,
                    ),
                    onPressed: () {
                      ref.read(wishlistProvider.notifier).toggleWishlist(product.id);
                    },
                  ),
                ),
              ],
            ),

            // Product Details
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 3),

                  // Rating Row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            Text(
                              product.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(Icons.star, size: 10, color: AppColors.success),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${product.ratingCount})',
                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryLight),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Price Row
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          CurrencyFormatter.format(product.price),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        if (product.regularPrice > product.price) ...[
                          const SizedBox(width: 5),
                          Text(
                            CurrencyFormatter.format(product.regularPrice),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondaryLight,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Quick Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 30,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        side: const BorderSide(color: AppColors.primary, width: 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      onPressed: () {
                        if (product.isVariable) {
                          context.push('/product/${product.id}');
                        } else {
                          ref.read(cartProvider.notifier).addToCart(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.name} added to cart!'),
                              duration: const Duration(seconds: 2),
                              action: SnackBarAction(
                                label: 'VIEW CART',
                                textColor: AppColors.secondary,
                                onPressed: () => context.push('/cart'),
                              ),
                            ),
                          );
                        }
                      },
                      child: Text(
                        product.isVariable ? 'SELECT OPTIONS' : 'ADD TO CART',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
