import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/custom_cached_image.dart';
import '../../core/widgets/error_state_view.dart';
import '../../shared/providers/app_providers.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final TextEditingController _couponController = TextEditingController();

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);

    if (cart.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Shopping Cart', style: TextStyle(fontWeight: FontWeight.bold))),
        body: EmptyStateView(
          icon: Icons.remove_shopping_cart_outlined,
          title: 'Your Cart is Empty',
          message: 'Looks like you haven\'t added any items to your shopping cart yet.',
          buttonText: 'START SHOPPING',
          onButtonPressed: () => context.go('/home'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Shopping Cart (${cart.items.length})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear Cart',
            onPressed: () {
              ref.read(cartProvider.notifier).clearCart();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Cart Items List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cart.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thumbnail
                      CustomCachedImage(
                        imageUrl: item.imageUrl,
                        width: 72,
                        height: 72,
                        borderRadius: 8,
                      ),
                      const SizedBox(width: 12),

                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimaryLight,
                              ),
                            ),
                            if (item.selectedAttributes != null && item.selectedAttributes!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                item.selectedAttributes!.entries.map((e) => '${e.key}: ${e.value}').join(' | '),
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              CurrencyFormatter.format(item.price),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Quantity Controls & Delete
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close, size: 18, color: AppColors.textSecondaryLight),
                            onPressed: () {
                              ref.read(cartProvider.notifier).removeFromCart(item.key);
                            },
                          ),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.borderLight),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    ref.read(cartProvider.notifier).updateQuantity(item.key, item.quantity - 1);
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    child: Icon(Icons.remove, size: 14),
                                  ),
                                ),
                                Text(
                                  '${item.quantity}',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                InkWell(
                                  onTap: () {
                                    ref.read(cartProvider.notifier).updateQuantity(item.key, item.quantity + 1);
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    child: Icon(Icons.add, size: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Coupon Code Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Apply Coupon Code', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _couponController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                            hintText: 'Enter code (e.g. JOMIYO10)',
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            final success = ref.read(cartProvider.notifier).applyCoupon(_couponController.text);
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Coupon JOMIYO10 applied successfully! (10% OFF)')),
                              );
                              _couponController.clear();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Invalid coupon code. Try JOMIYO10')),
                              );
                            }
                          },
                          child: const Text('APPLY'),
                        ),
                      ),
                    ],
                  ),
                  if (cart.appliedCoupon != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Coupon "${cart.appliedCoupon}" applied!',
                          style: const TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () => ref.read(cartProvider.notifier).removeCoupon(),
                          child: const Text(
                            'Remove',
                            style: TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Price Details Breakdown
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Price Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 14),
                  _summaryRow('Subtotal (${cart.items.length} items)', CurrencyFormatter.format(cart.subtotal)),
                  if (cart.discount > 0) ...[
                    const SizedBox(height: 8),
                    _summaryRow('Coupon Discount', '-${CurrencyFormatter.format(cart.discount)}', isDiscount: true),
                  ],
                  const SizedBox(height: 8),
                  _summaryRow('Delivery Charges', cart.shipping == 0 ? 'FREE' : CurrencyFormatter.format(cart.shipping)),
                  const Divider(height: 24),
                  _summaryRow('Total Amount', CurrencyFormatter.format(cart.total), isBold: true),
                ],
              ),
            ),

            const SizedBox(height: 100), // Spacing for bottom button
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(top: BorderSide(color: AppColors.borderLight)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2)),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Payable', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
                  Text(
                    CurrencyFormatter.format(cart.total),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              ),
              SizedBox(
                width: 180,
                child: AppButton(
                  text: 'PROCEED TO PAY',
                  onPressed: () => context.push('/checkout'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isDiscount = false, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? AppColors.textPrimaryLight : AppColors.textSecondaryLight,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isDiscount
                ? AppColors.success
                : (isBold ? AppColors.primary : AppColors.textPrimaryLight),
          ),
        ),
      ],
    );
  }
}
