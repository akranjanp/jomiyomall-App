import 'package:flutter_test/flutter_test.dart';
import 'package:jomiyo_mall/shared/models/product_model.dart';
import 'package:jomiyo_mall/shared/providers/app_providers.dart';

void main() {
  group('Cart & Product Business Logic Tests', () {
    final testProduct = ProductModel(
      id: 501,
      name: 'Test Cotton Shirt',
      slug: 'test-cotton-shirt',
      type: 'simple',
      description: 'Comfortable cotton shirt',
      shortDescription: 'Cotton shirt',
      price: 999.0,
      regularPrice: 1499.0,
      salePrice: 999.0,
      onSale: true,
      isInStock: true,
      rating: 4.8,
      ratingCount: 15,
      images: ['https://example.com/shirt.jpg'],
      attributes: [],
    );

    test('Product discount percentage calculates correctly', () {
      expect(testProduct.discountPercentage, equals(33));
    });

    test('CartNotifier adds item and calculates total correctly', () {
      final cartNotifier = CartNotifier();
      expect(cartNotifier.state.items.isEmpty, isTrue);

      cartNotifier.addToCart(testProduct, quantity: 2);
      expect(cartNotifier.state.items.length, equals(1));
      expect(cartNotifier.state.items.first.quantity, equals(2));
      expect(cartNotifier.state.subtotal, equals(1998.0));
      // Over ₹999 free shipping
      expect(cartNotifier.state.shipping, equals(0.0));
      expect(cartNotifier.state.total, equals(1998.0));
    });

    test('Coupon JOMIYO10 applies 10% discount', () {
      final cartNotifier = CartNotifier();
      cartNotifier.addToCart(testProduct, quantity: 1); // 999.0
      expect(cartNotifier.state.subtotal, equals(999.0));

      final applied = cartNotifier.applyCoupon('JOMIYO10');
      expect(applied, isTrue);
      expect(cartNotifier.state.appliedCoupon, equals('JOMIYO10'));
      expect(cartNotifier.state.discount, equals(99.9));
    });

    test('CartNotifier quantity update and remove works correctly', () {
      final cartNotifier = CartNotifier();
      cartNotifier.addToCart(testProduct, quantity: 1);
      final key = cartNotifier.state.items.first.key;

      cartNotifier.updateQuantity(key, 3);
      expect(cartNotifier.state.items.first.quantity, equals(3));
      expect(cartNotifier.state.subtotal, equals(2997.0));

      cartNotifier.removeFromCart(key);
      expect(cartNotifier.state.items.isEmpty, isTrue);
      expect(cartNotifier.state.total, equals(0.0));
    });
  });
}
