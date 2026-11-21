import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/api/dio_client.dart';
import '../../core/api/store_api_client.dart';
import '../../core/storage/local_storage_service.dart';
import '../../core/storage/secure_storage_service.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/cart_model.dart';
import '../models/customer_model.dart';
import '../models/order_model.dart';

// Storage Providers
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize sharedPreferencesProvider in main()');
});

final localStorageProvider = Provider<LocalStorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalStorageService(prefs);
});

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

// Network Providers
final dioClientProvider = Provider<DioClient>((ref) {
  final secure = ref.watch(secureStorageProvider);
  final local = ref.watch(localStorageProvider);
  return DioClient(secure, local);
});

final storeApiClientProvider = Provider<StoreApiClient>((ref) {
  final client = ref.watch(dioClientProvider);
  return StoreApiClient(client);
});

// App Config & Banners Provider
final appConfigProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(storeApiClientProvider);
  return api.getAppConfig();
});

// Categories Provider
final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  final api = ref.watch(storeApiClientProvider);
  final rawList = await api.getCategories();
  return rawList.map((c) => CategoryModel.fromJson(c)).toList();
});

// Products Providers
final featuredProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final api = ref.watch(storeApiClientProvider);
  final rawList = await api.getProducts(featured: true, perPage: 8);
  return rawList.map((p) => ProductModel.fromJson(p)).toList();
});

final saleProductsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final api = ref.watch(storeApiClientProvider);
  final rawList = await api.getProducts(onSale: true, perPage: 8);
  return rawList.map((p) => ProductModel.fromJson(p)).toList();
});

final newArrivalsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final api = ref.watch(storeApiClientProvider);
  final rawList = await api.getProducts(orderBy: 'date', order: 'desc', perPage: 8);
  return rawList.map((p) => ProductModel.fromJson(p)).toList();
});

// Single Product Details Provider Family
final productDetailsProvider = FutureProvider.family<ProductModel, int>((ref, productId) async {
  final api = ref.watch(storeApiClientProvider);
  final data = await api.getProductDetails(productId);
  return ProductModel.fromJson(data);
});

// Product Variations Provider Family
final productVariationsProvider = FutureProvider.family<List<Map<String, dynamic>>, int>((ref, productId) async {
  final api = ref.watch(storeApiClientProvider);
  return await api.getProductVariations(productId);
});

// Category Products Provider Family
final categoryProductsProvider = FutureProvider.family<List<ProductModel>, int>((ref, categoryId) async {
  final api = ref.watch(storeApiClientProvider);
  final rawList = await api.getProducts(categoryId: categoryId, perPage: 20);
  return rawList.map((p) => ProductModel.fromJson(p)).toList();
});

// Search Query & Search Results
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider<List<ProductModel>>((ref) async {
  final query = ref.watch(searchQueryProvider).trim();
  if (query.isEmpty) return [];
  final api = ref.watch(storeApiClientProvider);
  final rawList = await api.getProducts(search: query, perPage: 20);
  return rawList.map((p) => ProductModel.fromJson(p)).toList();
});

// Wishlist State Notifier
class WishlistNotifier extends StateNotifier<List<int>> {
  final LocalStorageService _local;

  WishlistNotifier(this._local) : super([]) {
    _loadInitial();
  }

  void _loadInitial() {
    state = _local.getLocalWishlist();
  }

  void toggleWishlist(int productId) {
    if (state.contains(productId)) {
      state = state.where((id) => id != productId).toList();
    } else {
      state = [...state, productId];
    }
    _local.setLocalWishlist(state);
  }

  bool isFavorite(int productId) => state.contains(productId);
}

final wishlistProvider = StateNotifierProvider<WishlistNotifier, List<int>>((ref) {
  final local = ref.watch(localStorageProvider);
  return WishlistNotifier(local);
});

// Cart State Notifier
class CartNotifier extends StateNotifier<CartModel> {
  CartNotifier() : super(CartModel.empty());

  void addToCart(
    ProductModel product, {
    int quantity = 1,
    Map<String, String>? attributes,
    int? variationId,
    double? price,
  }) {
    final effectivePrice = price ?? product.price;
    final existingIndex = state.items.indexWhere(
      (item) => item.id == product.id && item.variationId == variationId && _attributesMatch(item.selectedAttributes, attributes),
    );

    List<CartItemModel> updatedItems = List.from(state.items);

    if (existingIndex >= 0) {
      final existing = updatedItems[existingIndex];
      final newQty = existing.quantity + quantity;
      updatedItems[existingIndex] = CartItemModel(
        key: existing.key,
        id: existing.id,
        variationId: variationId ?? existing.variationId,
        quantity: newQty,
        name: existing.name,
        price: existing.price,
        lineTotal: existing.price * newQty,
        imageUrl: existing.imageUrl,
        selectedAttributes: existing.selectedAttributes,
      );
    } else {
      updatedItems.add(
        CartItemModel(
          key: '${product.id}_${variationId ?? attributes?.values.join("_") ?? "simple"}',
          id: product.id,
          variationId: variationId,
          quantity: quantity,
          name: product.name,
          price: effectivePrice,
          lineTotal: effectivePrice * quantity,
          imageUrl: product.images.isNotEmpty ? product.images.first : '',
          selectedAttributes: attributes,
        ),
      );
    }

    _recalculateTotals(updatedItems, state.appliedCoupon);
  }

  void updateQuantity(String itemKey, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(itemKey);
      return;
    }

    final updatedItems = state.items.map((item) {
      if (item.key == itemKey) {
        return CartItemModel(
          key: item.key,
          id: item.id,
          quantity: newQuantity,
          name: item.name,
          price: item.price,
          lineTotal: item.price * newQuantity,
          imageUrl: item.imageUrl,
          selectedAttributes: item.selectedAttributes,
        );
      }
      return item;
    }).toList();

    _recalculateTotals(updatedItems, state.appliedCoupon);
  }

  void removeFromCart(String itemKey) {
    final updatedItems = state.items.where((i) => i.key != itemKey).toList();
    _recalculateTotals(updatedItems, state.appliedCoupon);
  }

  void clearCart() {
    state = CartModel.empty();
  }

  bool applyCoupon(String code) {
    final clean = code.trim().toUpperCase();
    if (clean == 'JOMIYO10' || clean == 'WELCOME10') {
      _recalculateTotals(state.items, clean);
      return true;
    }
    return false;
  }

  void removeCoupon() {
    _recalculateTotals(state.items, null);
  }

  void _recalculateTotals(List<CartItemModel> items, String? coupon) {
    double subtotal = 0.0;
    for (final item in items) {
      subtotal += item.lineTotal;
    }

    double discount = 0.0;
    if (coupon != null && subtotal > 0) {
      discount = subtotal * 0.10; // 10% coupon discount
    }

    // Free shipping above ₹999, else ₹99
    double shipping = (subtotal - discount) >= 999 ? 0.0 : (items.isEmpty ? 0.0 : 99.0);
    // GST included in price or 5% tax
    double tax = 0.0; 
    double total = (subtotal - discount) + shipping + tax;
    if (total < 0) total = 0.0;

    state = CartModel(
      items: items,
      subtotal: subtotal,
      discount: discount,
      shipping: shipping,
      tax: tax,
      total: total,
      appliedCoupon: coupon,
    );
  }

  bool _attributesMatch(Map<String, String>? a, Map<String, String>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartModel>((ref) {
  return CartNotifier();
});

// Authentication State
class AuthState {
  final bool isAuthenticated;
  final CustomerModel? user;
  final String? token;
  final bool isLoading;
  final String? error;

  AuthState({
    required this.isAuthenticated,
    this.user,
    this.token,
    this.isLoading = false,
    this.error,
  });

  factory AuthState.initial() => AuthState(isAuthenticated: false);
}

class AuthNotifier extends StateNotifier<AuthState> {
  final SecureStorageService _secure;
  final StoreApiClient _api;

  AuthNotifier(this._secure, this._api) : super(AuthState.initial()) {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      final token = await _secure.getAuthToken();
      final userJson = await _secure.getUserData();
      if (token != null && userJson != null) {
        final decoded = json.decode(userJson);
        final user = CustomerModel.fromJson(decoded);
        state = AuthState(isAuthenticated: true, user: user, token: token);
      }
    } catch (_) {}
  }

  Future<bool> login(String usernameOrEmail, String password) async {
    state = AuthState(isAuthenticated: false, isLoading: true);
    try {
      final res = await _api.loginCustomer(usernameOrEmail, password);
      if (res['status'] == 'success' && res['token'] != null) {
        final token = res['token'].toString();
        final user = CustomerModel.fromJson(res['user']);
        await _secure.saveAuthToken(token);
        await _secure.saveUserData(json.encode(res['user']));
        state = AuthState(isAuthenticated: true, user: user, token: token);
        return true;
      }
      state = AuthState(isAuthenticated: false, error: res['message'] ?? 'Login failed');
      return false;
    } catch (e) {
      state = AuthState(isAuthenticated: false, error: e.toString());
      return false;
    }
  }

  Future<bool> register(Map<String, dynamic> data) async {
    state = AuthState(isAuthenticated: false, isLoading: true);
    try {
      final res = await _api.registerCustomer(data);
      if (res['status'] == 'success' && res['token'] != null) {
        final token = res['token'].toString();
        final user = CustomerModel.fromJson(res['user']);
        await _secure.saveAuthToken(token);
        await _secure.saveUserData(json.encode(res['user']));
        state = AuthState(isAuthenticated: true, user: user, token: token);
        return true;
      }
      state = AuthState(isAuthenticated: false, error: res['message'] ?? 'Registration failed');
      return false;
    } catch (e) {
      state = AuthState(isAuthenticated: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _secure.clearAuth();
    state = AuthState(isAuthenticated: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final secure = ref.watch(secureStorageProvider);
  final api = ref.watch(storeApiClientProvider);
  return AuthNotifier(secure, api);
});

// Real Customer Orders Provider from WooCommerce REST v3
final customerOrdersProvider = FutureProvider<List<OrderModel>>((ref) async {
  final auth = ref.watch(authProvider);
  if (!auth.isAuthenticated || auth.user == null) {
    return [];
  }

  final api = ref.watch(storeApiClientProvider);
  final rawOrders = await api.getCustomerOrders(
    customerId: auth.user!.id,
    email: auth.user!.email,
  );

  return rawOrders.map((o) => OrderModel.fromJson(o)).toList();
});
