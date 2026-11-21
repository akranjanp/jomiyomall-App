import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/main_layout/main_layout_screen.dart';
import '../../features/categories/categories_screen.dart';
import '../../features/products/product_list_screen.dart';
import '../../features/product_details/product_details_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/wishlist/wishlist_screen.dart';
import '../../features/cart/cart_screen.dart';
import '../../features/checkout/checkout_screen.dart';
import '../../features/payments/order_success_screen.dart';
import '../../features/authentication/login_screen.dart';
import '../../features/authentication/register_screen.dart';
import '../../features/orders/orders_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/support/support_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const MainLayoutScreen(),
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        path: '/category-products/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          final title = state.uri.queryParameters['name'] ?? 'Category Products';
          return ProductListScreen(categoryId: id, title: title);
        },
      ),
      GoRoute(
        path: '/products-all',
        builder: (context, state) {
          final title = state.uri.queryParameters['title'] ?? 'All Products';
          return ProductListScreen(title: title);
        },
      ),
      GoRoute(
        path: '/products',
        builder: (context, state) {
          final title = state.uri.queryParameters['title'] ?? 'Products';
          final catId = int.tryParse(state.uri.queryParameters['category'] ?? '');
          return ProductListScreen(categoryId: catId, title: title);
        },
      ),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
          return ProductDetailsScreen(productId: id);
        },
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/wishlist',
        builder: (context, state) => const WishlistScreen(),
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: '/order-success',
        builder: (context, state) {
          final orderId = state.uri.queryParameters['orderId'] ?? 'JM-100000';
          final amount = state.uri.queryParameters['amount'] ?? '0.00';
          final method = state.uri.queryParameters['method'] ?? 'razorpay';
          return OrderSuccessScreen(orderId: orderId, amount: amount, method: method);
        },
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/account',
        redirect: (context, state) => '/orders',
      ),
      GoRoute(
        path: '/profile',
        redirect: (context, state) => '/home',
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/support',
        builder: (context, state) => const SupportScreen(),
      ),
    ],
  );
}
