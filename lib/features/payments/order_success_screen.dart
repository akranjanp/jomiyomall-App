import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/app_button.dart';

class OrderSuccessScreen extends StatelessWidget {
  final String orderId;
  final String amount;
  final String method;

  const OrderSuccessScreen({
    super.key,
    required this.orderId,
    required this.amount,
    required this.method,
  });

  @override
  Widget build(BuildContext context) {
    final parsedAmount = double.tryParse(amount) ?? 0.0;

    return PopScope(
      canPop: false,
      onPopInvoked: (_) => context.go('/home'),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.check_circle_rounded, color: AppColors.success, size: 56),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Order Placed Successfully!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Thank you for shopping with Jomiyo Mall. Your order has been placed and will be delivered shortly.',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight, height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Order Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      _row('Order Number', orderId, isBold: true),
                      const Divider(height: 20),
                      _row('Total Paid', CurrencyFormatter.format(parsedAmount), isBold: true, color: AppColors.primary),
                      const Divider(height: 20),
                      _row('Payment Method', method == 'razorpay' ? 'Razorpay Online' : 'Cash on Delivery (COD)'),
                      const Divider(height: 20),
                      _row('Estimated Delivery', '3 - 5 Business Days'),
                    ],
                  ),
                ),

                const Spacer(),

                AppButton(
                  text: 'CONTINUE SHOPPING',
                  onPressed: () => context.go('/home'),
                ),
                const SizedBox(height: 12),
                AppButton(
                  text: 'VIEW MY ORDERS',
                  isOutlined: true,
                  onPressed: () => context.go('/orders'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight)),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: color ?? AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }
}
