import 'product_model.dart';

class CartItemModel {
  final String key;
  final int id;
  final int? variationId;
  final int quantity;
  final String name;
  final double price;
  final double lineTotal;
  final String imageUrl;
  final Map<String, String>? selectedAttributes;

  CartItemModel({
    required this.key,
    required this.id,
    this.variationId,
    required this.quantity,
    required this.name,
    required this.price,
    required this.lineTotal,
    required this.imageUrl,
    this.selectedAttributes,
  });

  factory CartItemModel.fromProduct(ProductModel product, {int quantity = 1, Map<String, String>? attributes, int? variationId}) {
    return CartItemModel(
      key: '${product.id}_${variationId ?? attributes?.values.join("_") ?? "simple"}',
      id: product.id,
      variationId: variationId,
      quantity: quantity,
      name: product.name,
      price: product.price,
      lineTotal: product.price * quantity,
      imageUrl: product.images.isNotEmpty ? product.images.first : '',
      selectedAttributes: attributes,
    );
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    String img = '';
    if (json['images'] is List && (json['images'] as List).isNotEmpty) {
      img = json['images'][0]['src']?.toString() ?? '';
    }

    double parsedPrice = 0.0;
    if (json['prices'] is Map) {
      final p = json['prices'];
      final raw = double.tryParse(p['price']?.toString() ?? '0') ?? 0.0;
      parsedPrice = raw > 1000 ? raw / 100 : raw;
    } else {
      parsedPrice = double.tryParse(json['price']?.toString() ?? '0') ?? 0.0;
    }

    final qty = int.tryParse(json['quantity']?.toString() ?? '1') ?? 1;

    return CartItemModel(
      key: json['key']?.toString() ?? json['id']?.toString() ?? '',
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      variationId: json['variation_id'] != null ? int.tryParse(json['variation_id'].toString()) : null,
      quantity: qty,
      name: json['name']?.toString() ?? '',
      price: parsedPrice,
      lineTotal: parsedPrice * qty,
      imageUrl: img,
    );
  }
}

class CartModel {
  final List<CartItemModel> items;
  final double subtotal;
  final double discount;
  final double shipping;
  final double tax;
  final double total;
  final String? appliedCoupon;

  CartModel({
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.shipping,
    required this.tax,
    required this.total,
    this.appliedCoupon,
  });

  factory CartModel.empty() {
    return CartModel(
      items: [],
      subtotal: 0.0,
      discount: 0.0,
      shipping: 0.0,
      tax: 0.0,
      total: 0.0,
    );
  }

  CartModel copyWith({
    List<CartItemModel>? items,
    double? subtotal,
    double? discount,
    double? shipping,
    double? tax,
    double? total,
    String? appliedCoupon,
  }) {
    return CartModel(
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      shipping: shipping ?? this.shipping,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      appliedCoupon: appliedCoupon ?? this.appliedCoupon,
    );
  }
}
