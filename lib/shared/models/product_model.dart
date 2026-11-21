class ProductModel {
  final int id;
  final String name;
  final String slug;
  final String type; // 'simple' or 'variable'
  final String description;
  final String shortDescription;
  final double price;
  final double regularPrice;
  final double salePrice;
  final bool onSale;
  final bool isInStock;
  final double rating;
  final int ratingCount;
  final List<String> images;
  final List<ProductAttribute> attributes;

  ProductModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.type,
    required this.description,
    required this.shortDescription,
    required this.price,
    required this.regularPrice,
    required this.salePrice,
    required this.onSale,
    required this.isInStock,
    required this.rating,
    required this.ratingCount,
    required this.images,
    required this.attributes,
  });

  bool get isVariable => type == 'variable';

  int get discountPercentage {
    if (regularPrice > 0 && salePrice > 0 && regularPrice > salePrice) {
      return (((regularPrice - salePrice) / regularPrice) * 100).round();
    }
    return 0;
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Handle Store API v1 & WC v3 prices
    double parsedPrice = 0.0;
    double parsedRegPrice = 0.0;
    double parsedSalePrice = 0.0;

    if (json['prices'] != null && json['prices'] is Map) {
      final p = json['prices'];
      // Store API returns amounts in minor units (paise)
      final rawPrice = double.tryParse(p['price']?.toString() ?? '0') ?? 0.0;
      final rawReg = double.tryParse(p['regular_price']?.toString() ?? '0') ?? 0.0;
      final rawSale = double.tryParse(p['sale_price']?.toString() ?? '0') ?? 0.0;

      parsedPrice = rawPrice > 1000 ? rawPrice / 100 : rawPrice;
      parsedRegPrice = rawReg > 1000 ? rawReg / 100 : rawReg;
      parsedSalePrice = rawSale > 1000 ? rawSale / 100 : rawSale;
    } else {
      parsedPrice = double.tryParse(json['price']?.toString() ?? '0') ?? 0.0;
      parsedRegPrice = double.tryParse(json['regular_price']?.toString() ?? '0') ?? parsedPrice;
      parsedSalePrice = double.tryParse(json['sale_price']?.toString() ?? '0') ?? parsedPrice;
    }

    if (parsedRegPrice == 0.0) parsedRegPrice = parsedPrice;
    if (parsedSalePrice == 0.0) parsedSalePrice = parsedPrice;

    // Images
    final List<String> imgList = [];
    if (json['images'] is List) {
      for (final img in json['images']) {
        if (img is Map && img['src'] != null) {
          imgList.add(img['src'].toString());
        }
      }
    }
    if (imgList.isEmpty) {
      imgList.add('https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600');
    }

    // Attributes
    final List<ProductAttribute> attrList = [];
    final rawAttrs = json['attributes'] ?? json['attributesData'] ?? json['variation_attributes'];
    if (rawAttrs is List) {
      for (final a in rawAttrs) {
        if (a is Map) {
          attrList.add(ProductAttribute.fromJson(a as Map<String, dynamic>));
        }
      }
    }

    return ProductModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      type: json['type']?.toString() ?? 'simple',
      description: json['description']?.toString() ?? '',
      shortDescription: json['short_description']?.toString() ?? '',
      price: parsedPrice,
      regularPrice: parsedRegPrice,
      salePrice: parsedSalePrice,
      onSale: json['on_sale'] == true || (parsedRegPrice > parsedSalePrice),
      isInStock: json['is_in_stock'] != false && json['stock_status'] != 'outofstock',
      rating: double.tryParse(json['average_rating']?.toString() ?? '4.5') ?? 4.5,
      ratingCount: int.tryParse(json['rating_count']?.toString() ?? '10') ?? 10,
      images: imgList,
      attributes: attrList,
    );
  }
}

class ProductAttribute {
  final int id;
  final String name;
  final List<String> options;

  ProductAttribute({
    required this.id,
    required this.name,
    required this.options,
  });

  factory ProductAttribute.fromJson(Map<String, dynamic> json) {
    final List<String> opts = [];
    if (json['options'] is List) {
      for (final o in json['options']) {
        if (o is Map) {
          final val = o['name'] ?? o['option'] ?? o['slug'];
          if (val != null) opts.add(val.toString());
        } else if (o != null) {
          opts.add(o.toString());
        }
      }
    } else if (json['terms'] is List) {
      for (final t in json['terms']) {
        if (t is Map) {
          final val = t['name'] ?? t['slug'];
          if (val != null) opts.add(val.toString());
        } else if (t != null) {
          opts.add(t.toString());
        }
      }
    } else if (json['values'] is List) {
      for (final v in json['values']) {
        if (v is Map) {
          final val = v['name'] ?? v['slug'];
          if (val != null) opts.add(val.toString());
        } else if (v != null) {
          opts.add(v.toString());
        }
      }
    }

    return ProductAttribute(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      options: opts,
    );
  }
}
