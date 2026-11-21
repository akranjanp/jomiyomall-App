import 'customer_model.dart';

class OrderItemModel {
  final int id;
  final String name;
  final int quantity;
  final double subtotal;
  final double total;

  OrderItemModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.subtotal,
    required this.total,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      quantity: int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0.0,
    );
  }
}

class OrderModel {
  final int id;
  final String number;
  final String status;
  final String dateCreated;
  final double total;
  final String currency;
  final String paymentMethodTitle;
  final List<OrderItemModel> lineItems;
  final AddressModel shipping;

  OrderModel({
    required this.id,
    required this.number,
    required this.status,
    required this.dateCreated,
    required this.total,
    required this.currency,
    required this.paymentMethodTitle,
    required this.lineItems,
    required this.shipping,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final List<OrderItemModel> items = [];
    if (json['line_items'] is List) {
      for (final item in json['line_items']) {
        if (item is Map<String, dynamic>) {
          items.add(OrderItemModel.fromJson(item));
        }
      }
    }

    return OrderModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      number: json['number']?.toString() ?? json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'processing',
      dateCreated: json['date_created']?.toString() ?? '',
      total: double.tryParse(json['total']?.toString() ?? '0') ?? 0.0,
      currency: json['currency']?.toString() ?? 'INR',
      paymentMethodTitle: json['payment_method_title']?.toString() ?? 'Razorpay Online',
      lineItems: items,
      shipping: json['shipping'] is Map<String, dynamic>
          ? AddressModel.fromJson(json['shipping'])
          : AddressModel.empty(),
    );
  }
}
