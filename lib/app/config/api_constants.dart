class ApiConstants {
  static const String baseUrl = 'https://jomiyomall.com';
  
  // Custom API Bridge endpoints
  static const String bridgeConfig = '/wp-json/jomiyo/v1/config';
  static const String bridgeRegister = '/wp-json/jomiyo/v1/auth/register';
  static const String bridgeLogin = '/wp-json/jomiyo/v1/auth/login';
  static const String bridgeProfile = '/wp-json/jomiyo/v1/auth/me';
  static const String bridgeUpdateProfile = '/wp-json/jomiyo/v1/auth/update-profile';
  static const String bridgeWishlist = '/wp-json/jomiyo/v1/wishlist';
  static const String bridgeRazorpayCreate = '/wp-json/jomiyo/v1/razorpay/create-order';
  static const String bridgeRazorpayVerify = '/wp-json/jomiyo/v1/razorpay/verify-payment';

  // WooCommerce Store API v1 endpoints (public store endpoints)
  static const String storeProducts = '/wp-json/wc/store/v1/products';
  static const String storeCategories = '/wp-json/wc/store/v1/products/categories';
  static const String storeCart = '/wp-json/wc/store/v1/cart';
  static const String storeCartItems = '/wp-json/wc/store/v1/cart/items';
  static const String storeApplyCoupon = '/wp-json/wc/store/v1/cart/apply-coupon';
  static const String storeRemoveCoupon = '/wp-json/wc/store/v1/cart/remove-coupon';
  static const String storeCheckout = '/wp-json/wc/store/v1/checkout';

  // WooCommerce REST API v3
  static const String wcV3Base = '/wp-json/wc/v3';
  static const String wcV3Orders = '/wp-json/wc/v3/orders';
  static const String wcV3Products = '/wp-json/wc/v3/products';
  static const String wcV3Categories = '/wp-json/wc/v3/products/categories';
  static const String wcV3Customers = '/wp-json/wc/v3/customers';

  // WooCommerce Keys (read/write credentials for catalog & order placement)
  static const String consumerKey = 'ck_a9d2eec3ed6f51085d18704ac27f79793cda24b4';
  static const String consumerSecret = 'cs_13515c63dbb2e4a2311eed4a5be98e34471d2c54';
}

class AppConfig {
  static const String appName = 'Jomiyo Mall';
  static const String appVersion = '1.0.0';
  static const String currency = 'INR';
  static const String currencySymbol = '₹';
  static const String supportEmail = 'support@jomiyomall.com';
  static const String supportPhone = '+91 9910403750';
  static const String whatsappNumber = '+919910403750';
  static const String privacyPolicyUrl = 'https://jomiyomall.com/privacy-policy';
  static const String termsUrl = 'https://jomiyomall.com/terms-and-conditions';
  static const String refundPolicyUrl = 'https://jomiyomall.com/refund-returns';
  static const String aboutUsUrl = 'https://jomiyomall.com/about-us';
  static const String faqUrl = 'https://jomiyomall.com/faq';

  // Verified Jomiyo Mall Razorpay Key
  static const String razorpayKeyId = 'rzp_test_SDo2WKBNQXDk5Y';
}
