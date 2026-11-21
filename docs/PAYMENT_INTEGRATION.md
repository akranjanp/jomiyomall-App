# Jomiyo Mall — Payment Gateway Integration Guide

This document describes how payment processing is architected and configured in the Jomiyo Mall mobile application.

---

## 1. Supported Payment Methods

1. **Cash on Delivery (COD)**:
   - Built-in WooCommerce COD gateway.
   - Ideal for Indian e-commerce customers.
   - Orders placed with COD are automatically set to `processing` status.
2. **Razorpay Payments (UPI / Cards / NetBanking / Wallets)**:
   - India's leading payment gateway supporting Google Pay, PhonePe, Paytm, BHIM, all major credit/debit cards, and 50+ net banking banks.
   - Compliant with RBI guidelines and tokenization regulations.

---

## 2. Security Architecture: The 2-Tier Model

A critical flaw in naive mobile commerce apps is storing the **Razorpay Key Secret** directly in the mobile app binary. Doing so allows malicious actors to reverse-engineer the APK and drain merchant balances.

### Jomiyo Mall Implements the Secure 2-Tier Architecture:
```
[Flutter Mobile App]
       │
       │ 1. POST /wp-json/jomiyo/v1/payments/create-order
       │    (Sends cart items & total amount in INR)
       ▼
[WordPress Backend Bridge]  ──(uses secret key)──► [Razorpay API Server]
       │                                                    │
       │ 2. Returns Razorpay Order ID (`order_...`)         │
       ◄────────────────────────────────────────────────────┘
       │
       │ 3. Flutter opens native Razorpay Checkout with Order ID & Public Key ID
       │ 4. Customer authorizes payment (UPI / Card / NetBanking)
       ▼
[Razorpay Checkout] ──► Returns `razorpay_payment_id` & `razorpay_signature`
       │
       │ 5. POST /wp-json/wc/v3/orders
       │    (Submits order with payment token & verified signature)
       ▼
[WooCommerce Database] ──► Status updated to 'Processing' & Inventory decremented
```

---

## 3. Configuration & Credentials

### File: `lib/app/config/api_constants.dart`
```dart
class ApiConstants {
  // Public Razorpay Key ID (Safe to include in app bundle)
  static const String razorpayKeyId = 'rzp_test_YOUR_KEY_HERE'; // Replace with live key
}
```

### WordPress Backend (`wp-config.php` or Plugin Settings):
Store the **Razorpay Key Secret** strictly on the WordPress server:
```php
define('RAZORPAY_KEY_ID', 'rzp_live_...');
define('RAZORPAY_KEY_SECRET', 'YOUR_PRIVATE_SECRET_HERE');
```

---

## 4. Testing with Razorpay Test Mode

1. In Razorpay Dashboard (`dashboard.razorpay.com`), switch to **Test Mode**.
2. Copy your **Test Key ID** and paste it into `lib/app/config/api_constants.dart`.
3. In the mobile app, add an item to cart and proceed to Checkout.
4. Select **Razorpay** and click **Place Order**.
5. When Razorpay modal appears:
   - For **UPI**: Enter `success@razorpay` to simulate approved payment.
   - For **Cards**: Use test card `4111 1111 1111 1111` with any future expiry date and CVV `123`.
6. Once payment completes, the app displays the **Order Confirmation Screen** with the generated WooCommerce Order ID.
