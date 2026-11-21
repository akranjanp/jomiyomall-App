import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _keyOnboardingDone = 'onboarding_completed';
  static const String _keyThemeMode = 'app_theme_mode';
  static const String _keyRecentSearches = 'recent_searches';
  static const String _keyLocalWishlist = 'local_wishlist_ids';
  static const String _keyCartNonce = 'wc_cart_nonce';
  static const String _keyCartToken = 'wc_cart_token';

  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static Future<LocalStorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorageService(prefs);
  }

  // Onboarding
  bool isOnboardingCompleted() => _prefs.getBool(_keyOnboardingDone) ?? false;
  Future<void> setOnboardingCompleted(bool value) => _prefs.setBool(_keyOnboardingDone, value);

  // Theme
  String getThemeMode() => _prefs.getString(_keyThemeMode) ?? 'system';
  Future<void> setThemeMode(String mode) => _prefs.setString(_keyThemeMode, mode);

  // Recent Searches
  List<String> getRecentSearches() => _prefs.getStringList(_keyRecentSearches) ?? [];
  Future<void> addRecentSearch(String query) async {
    final list = getRecentSearches();
    list.remove(query);
    list.insert(0, query);
    if (list.length > 10) list.removeLast();
    await _prefs.setStringList(_keyRecentSearches, list);
  }
  Future<void> clearRecentSearches() => _prefs.remove(_keyRecentSearches);

  // Local Wishlist (for guest)
  List<int> getLocalWishlist() {
    final list = _prefs.getStringList(_keyLocalWishlist) ?? [];
    return list.map((e) => int.tryParse(e) ?? 0).where((e) => e > 0).toList();
  }
  Future<void> setLocalWishlist(List<int> ids) {
    return _prefs.setStringList(_keyLocalWishlist, ids.map((e) => e.toString()).toList());
  }

  // WooCommerce Cart Token & Nonce
  String? getCartToken() => _prefs.getString(_keyCartToken);
  Future<void> setCartToken(String token) => _prefs.setString(_keyCartToken, token);

  String? getCartNonce() => _prefs.getString(_keyCartNonce);
  Future<void> setCartNonce(String nonce) => _prefs.setString(_keyCartNonce, nonce);

  // Cached Home Data for fast offline rendering
  String? getCachedHome() => _prefs.getString('cached_home_data');
  Future<void> setCachedHome(String jsonStr) => _prefs.setString('cached_home_data', jsonStr);
}
