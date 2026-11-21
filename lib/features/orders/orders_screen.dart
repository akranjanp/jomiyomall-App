import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/error_state_view.dart';
import '../../shared/providers/app_providers.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    if (!auth.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Orders', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: EmptyStateView(
          icon: Icons.lock_outline,
          title: 'Sign In Required',
          message: 'Please sign in to your Jomiyo account to view and track your orders.',
          buttonText: 'SIGN IN',
          onButtonPressed: () => context.push('/login'),
        ),
      );
    }

    final ordersAsync = ref.watch(customerOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ordersAsync.when(
        data: (orders) {
          if (orders.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(customerOrdersProvider),
              child: ListView(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                  EmptyStateView(
                    icon: Icons.inventory_2_outlined,
                    title: 'No Orders Found',
                    message: 'You have not placed any orders yet. Start exploring our collections!',
                    buttonText: 'SHOP NOW',
                    onButtonPressed: () => context.go('/home'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(customerOrdersProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final order = orders[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order #${order.number}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          _buildStatusBadge(order.status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Placed on ${order.dateCreated}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                      ),
                      const Divider(height: 20),
                      for (final item in order.lineItems) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            children: [
                              const Icon(Icons.circle, size: 6, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${item.quantity}x ${item.name}',
                                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimaryLight),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                CurrencyFormatter.format(item.total),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Paid via ${order.paymentMethodTitle}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                          ),
                          Row(
                            children: [
                              const Text('Total: ', style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight)),
                              Text(
                                CurrencyFormatter.format(order.total),
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ErrorStateView(
          message: 'Unable to load orders: $err',
          onRetry: () => ref.invalidate(customerOrdersProvider),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = AppColors.primary.withOpacity(0.12);
    Color text = AppColors.primary;

    if (status == 'completed') {
      bg = AppColors.success.withOpacity(0.12);
      text = AppColors.success;
    } else if (status == 'cancelled' || status == 'failed') {
      bg = AppColors.error.withOpacity(0.12);
      text = AppColors.error;
    } else if (status == 'processing') {
      bg = AppColors.secondary.withOpacity(0.15);
      text = AppColors.secondaryDark;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: text, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
