import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../app/config/api_constants.dart';
import '../../app/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../shared/providers/app_providers.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _address1Controller = TextEditingController();
  final _address2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();
  String _selectedState = 'Maharashtra';
  String _selectedPaymentMethod = 'razorpay';
  bool _isPlacingOrder = false;

  late Razorpay _razorpay;

  final List<String> _indianStates = [
    'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
    'Delhi', 'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh',
    'Jharkhand', 'Karnataka', 'Kerala', 'Madhya Pradesh', 'Maharashtra',
    'Manipur', 'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha',
    'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu', 'Telangana',
    'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal',
  ];

  @override
  void initState() {
    super.initState();

    // Initialize Razorpay
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    final auth = ref.read(authProvider);
    if (auth.user != null) {
      _nameController.text = auth.user!.displayName.isNotEmpty
          ? auth.user!.displayName
          : '${auth.user!.firstName} ${auth.user!.lastName}'.trim();
      _phoneController.text = auth.user!.phone.isNotEmpty ? auth.user!.phone : '9910403750';
      _address1Controller.text = auth.user!.billing.address1.isNotEmpty ? auth.user!.billing.address1 : 'Plot 42, Green Park Avenue';
      _address2Controller.text = auth.user!.billing.address2;
      _cityController.text = auth.user!.billing.city.isNotEmpty ? auth.user!.billing.city : 'Mumbai';
      _pincodeController.text = auth.user!.billing.postcode.isNotEmpty ? auth.user!.billing.postcode : '400001';
      if (_indianStates.contains(auth.user!.billing.state)) {
        _selectedState = auth.user!.billing.state;
      }
    } else {
      // Default placeholder address
      _nameController.text = 'Ashish Ranjan';
      _phoneController.text = '9910403750';
      _address1Controller.text = 'Plot 42, Green Park Avenue';
      _cityController.text = 'Mumbai';
      _pincodeController.text = '400001';
      _selectedState = 'Maharashtra';
    }
  }

  @override
  void dispose() {
    _razorpay.clear();
    _nameController.dispose();
    _phoneController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _openRazorpayCheckout(double amountInRupees) {
    setState(() => _isPlacingOrder = true);
    final options = {
      'key': AppConfig.razorpayKeyId,
      'amount': (amountInRupees * 100).toInt(), // in paise
      'name': 'Jomiyo Mall',
      'description': 'Order Payment',
      'currency': 'INR',
      'prefill': {
        'contact': _phoneController.text.trim(),
        'email': ref.read(authProvider).user?.email ?? 'support@jomiyomall.com',
      },
      'theme': {
        'color': '#0037AB',
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      setState(() => _isPlacingOrder = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment initiation error: $e'), backgroundColor: AppColors.error),
      );
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    await _submitOrderToWooCommerce(
      paymentMethod: 'razorpay',
      paymentMethodTitle: 'Razorpay Online (UPI/Cards/NetBanking)',
      setPaid: true,
      transactionId: response.paymentId,
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isPlacingOrder = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Cancelled / Failed: ${response.message ?? "Transaction not completed"}'),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External Wallet selected: ${response.walletName}')),
    );
  }

  Future<void> _submitOrderToWooCommerce({
    required String paymentMethod,
    required String paymentMethodTitle,
    required bool setPaid,
    String? transactionId,
  }) async {
    setState(() => _isPlacingOrder = true);
    try {
      final cart = ref.read(cartProvider);
      final auth = ref.read(authProvider);

      final names = _nameController.text.trim().split(' ');
      final firstName = names.isNotEmpty ? names.first : 'Customer';
      final lastName = names.length > 1 ? names.sublist(1).join(' ') : '';

      final billingAddress = {
        'first_name': firstName,
        'last_name': lastName,
        'address_1': _address1Controller.text.trim(),
        'address_2': _address2Controller.text.trim(),
        'city': _cityController.text.trim(),
        'state': _selectedState,
        'postcode': _pincodeController.text.trim(),
        'country': 'IN',
        'email': auth.user?.email ?? 'support@jomiyomall.com',
        'phone': _phoneController.text.trim(),
      };

      final lineItems = cart.items.map((item) {
        final map = <String, dynamic>{
          'product_id': item.id,
          'quantity': item.quantity,
        };
        if (item.variationId != null) {
          map['variation_id'] = item.variationId;
        }
        return map;
      }).toList();

      final orderPayload = <String, dynamic>{
        'payment_method': paymentMethod,
        'payment_method_title': paymentMethodTitle,
        'set_paid': setPaid,
        'billing': billingAddress,
        'shipping': billingAddress,
        'line_items': lineItems,
        'total': cart.total.toStringAsFixed(2),
      };

      if (transactionId != null) {
        orderPayload['transaction_id'] = transactionId;
      }

      if (auth.user != null) {
        orderPayload['customer_id'] = auth.user!.id;
      }

      final api = ref.read(storeApiClientProvider);
      final createdOrder = await api.createOrder(orderPayload);

      final orderId = createdOrder['id']?.toString() ??
          createdOrder['number']?.toString() ??
          'JM-${100000 + Random().nextInt(900000)}';
      final totalAmount = cart.total;

      // Clear cart upon successful order
      ref.read(cartProvider.notifier).clearCart();
      ref.invalidate(customerOrdersProvider);

      setState(() => _isPlacingOrder = false);

      if (mounted) {
        context.go(
          '/order-success?orderId=$orderId&amount=${totalAmount.toStringAsFixed(2)}&method=$paymentMethod',
        );
      }
    } catch (e) {
      setState(() => _isPlacingOrder = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order submission error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _onPlaceOrderPressed() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPaymentMethod == 'razorpay') {
      final cart = ref.read(cartProvider);
      _openRazorpayCheckout(cart.total);
    } else {
      _submitOrderToWooCommerce(
        paymentMethod: 'cod',
        paymentMethodTitle: 'Cash on Delivery',
        setPaid: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shipping Address Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.location_on_outlined, color: AppColors.primary, size: 20),
                        SizedBox(width: 8),
                        Text('Shipping Address (India)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      controller: _nameController,
                      label: 'Full Name *',
                      hint: 'Enter your full name',
                      validator: (v) => Validators.required(v, 'Full Name'),
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _phoneController,
                      label: 'Mobile Number *',
                      hint: '10-digit mobile number',
                      keyboardType: TextInputType.phone,
                      validator: Validators.phone,
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _address1Controller,
                      label: 'Flat / House No. / Building *',
                      hint: 'Street address line 1',
                      validator: (v) => Validators.required(v, 'Address'),
                    ),
                    const SizedBox(height: 12),
                    AppTextField(
                      controller: _address2Controller,
                      label: 'Area / Colony / Street (Optional)',
                      hint: 'Landmark or sector',
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _cityController,
                            label: 'City / Town *',
                            hint: 'e.g. Mumbai',
                            validator: (v) => Validators.required(v, 'City'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppTextField(
                            controller: _pincodeController,
                            label: 'PIN Code *',
                            hint: '6-digit PIN',
                            keyboardType: TextInputType.number,
                            validator: Validators.pincode,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('State *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderLight),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedState,
                          isExpanded: true,
                          items: _indianStates.map((state) {
                            return DropdownMenuItem(value: state, child: Text(state));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedState = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Payment Method Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.payment_outlined, color: AppColors.primary, size: 20),
                        SizedBox(width: 8),
                        Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Razorpay Online
                    RadioListTile<String>(
                      value: 'razorpay',
                      groupValue: _selectedPaymentMethod,
                      activeColor: AppColors.primary,
                      title: const Text('Razorpay Online (UPI, Cards, NetBanking)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: const Text('Google Pay, PhonePe, Paytm, Visa/Mastercard, Net Banking', style: TextStyle(fontSize: 12)),
                      secondary: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('RECOMMENDED', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedPaymentMethod = val);
                      },
                    ),
                    const Divider(height: 1),
                    // Cash on Delivery
                    RadioListTile<String>(
                      value: 'cod',
                      groupValue: _selectedPaymentMethod,
                      activeColor: AppColors.primary,
                      title: const Text('Cash on Delivery (COD)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: const Text('Pay with cash or UPI at your doorstep upon delivery', style: TextStyle(fontSize: 12)),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedPaymentMethod = val);
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Order Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Order Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Items Total', style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight)),
                        Text(CurrencyFormatter.format(cart.subtotal), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    if (cart.discount > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Discount', style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight)),
                          Text('-${CurrencyFormatter.format(cart.discount)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.success)),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Shipping Charges', style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight)),
                        Text(cart.shipping == 0 ? 'FREE' : CurrencyFormatter.format(cart.shipping), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Payable', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(CurrencyFormatter.format(cart.total), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              AppButton(
                text: _selectedPaymentMethod == 'razorpay' ? 'PAY & PLACE ORDER' : 'CONFIRM COD ORDER',
                isLoading: _isPlacingOrder,
                onPressed: _onPlaceOrderPressed,
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
