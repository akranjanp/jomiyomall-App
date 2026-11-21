# Jomiyo Mall — Mobile Application (Flutter)

A complete, production-ready, cross-platform e-commerce mobile application for **Jomiyo Mall** (`https://jomiyomall.com`), built with **Flutter 3.38+**, **Riverpod 2.5+**, **GoRouter 14+**, and **Dio 5+**.

Connected directly to the live WordPress + WooCommerce + WCFM Multi-Vendor backend via REST APIs and the custom `mobile-commerce-api-bridge` companion plugin.

---

## 📱 Features

- **Storefront & Discovery**:
  - Hero banner carousel with auto-play and promotional deeplinks.
  - Interactive category selector and dynamic rails (Featured, On Sale, New Arrivals).
  - High-performance debounced live search with search history.
  - Category browse screen with 2-column grid.
- **Product Details**:
  - Multi-image photo gallery with zoom and indicator.
  - Dynamic pricing (regular vs sale price display with percentage discount badge).
  - Variation selector (Color, Size, etc.) for variable products.
  - Instant Add to Cart and Buy Now workflows.
- **Cart & Checkout**:
  - Real-time cart calculations (subtotal, coupon discounts, shipping, total).
  - Promo code system (try `JOMIYO10`).
  - Indian address checkout form with validation for 29 states and 6-digit PIN codes.
  - Payment options: Cash on Delivery (COD) and Razorpay integration.
- **Customer Account**:
  - Profile management, order tracking, address book, wishlist, support via WhatsApp/Phone/Email.
- **Resilience Architecture**:
  - Cold-start offline protection: Built-in catalog fallback ensures **zero white/blue screens** even during backend maintenance or connection dropouts.

---

## 🛠️ Architecture & Tech Stack

```
lib/
├── app/
│   ├── app.dart                   # Root MaterialApp with theme & routing
│   ├── config/api_constants.dart   # WooCommerce & Razorpay configuration
│   ├── router/app_router.dart     # GoRouter routing table
│   └── theme/                     # Material 3 Royal Blue & Amber themes
├── core/
│   ├── api/                       # Dio network client & StoreApiClient repository
│   └── storage/                   # SharedPreferences & FlutterSecureStorage
├── shared/
│   ├── models/                    # Product, Category, Cart, Order, Customer models
│   ├── providers/app_providers.dart # Riverpod state providers
│   └── widgets/                   # Custom buttons, input fields, badges
└── features/
    ├── splash/                    # Animated brand splash screen
    ├── onboarding/                # 3-step introductory slider
    ├── home/                      # Dynamic home screen with carousels & rails
    ├── categories/                # Category browser
    ├── products/                  # Product listing, filtering, and cards
    ├── product_details/           # Full product gallery, variations & review
    ├── search/                    # Instant search
    ├── wishlist/                  # Saved items
    ├── cart/                      # Cart management & coupons
    ├── checkout/                  # Address & payment selection
    ├── payments/                  # Order success & Razorpay handler
    ├── authentication/            # Login & registration
    ├── profile/                   # My Account
    ├── orders/                    # Order history & status tracking
    ├── settings/                  # App preferences
    └── support/                   # Help center & direct contact
```

---

## 🚀 Quick Start

```bash
# 1. Clone/Navigate
cd /Users/ashishranjan/.gemini/antigravity/scratch/jomiyo_mall

# 2. Set Java 17 path (macOS)
export JAVA_HOME="/Users/ashishranjan/Library/Java/JavaVirtualMachines/jbr-17.0.14/Contents/Home"

# 3. Install packages
flutter pub get

# 4. Verify code health
flutter analyze
flutter test

# 5. Build Release APK
flutter build apk --release
```

---

## 📖 Documentation Suite

Comprehensive guides are located in the [`docs/`](docs/) directory:
- [Installation & Setup](docs/INSTALLATION.md)
- [API Architecture & Endpoints](docs/API_CONFIGURATION.md)
- [WordPress Companion Plugin Setup](docs/WORDPRESS_PLUGIN_SETUP.md)
- [Payment Gateway Integration (Razorpay + COD)](docs/PAYMENT_INTEGRATION.md)
- [QA & Testing Report](docs/TESTING_REPORT.md)

---

## 📦 Companion WordPress Plugin

The custom WordPress API bridge plugin is available at:
`wordpress-plugin/mobile-commerce-api-bridge.zip`

Upload this ZIP via **WordPress Admin** → **Plugins** → **Add New** → **Upload Plugin** to activate secure mobile authentication, dynamic banners, and server-side Razorpay order generation.
