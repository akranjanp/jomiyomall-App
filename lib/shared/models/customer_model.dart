class AddressModel {
  final String firstName;
  final String lastName;
  final String address1;
  final String address2;
  final String city;
  final String state;
  final String postcode;
  final String country;
  final String phone;
  final String email;

  AddressModel({
    required this.firstName,
    required this.lastName,
    required this.address1,
    this.address2 = '',
    required this.city,
    required this.state,
    required this.postcode,
    this.country = 'IN',
    required this.phone,
    this.email = '',
  });

  String get fullName => '$firstName $lastName'.trim();
  String get fullAddress => [address1, if (address2.isNotEmpty) address2, city, state, postcode].join(', ');

  factory AddressModel.empty() {
    return AddressModel(
      firstName: '',
      lastName: '',
      address1: '',
      address2: '',
      city: '',
      state: 'Delhi',
      postcode: '',
      country: 'IN',
      phone: '',
      email: '',
    );
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      address1: json['address_1']?.toString() ?? '',
      address2: json['address_2']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString() ?? 'Delhi',
      postcode: json['postcode']?.toString() ?? '',
      country: json['country']?.toString() ?? 'IN',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'address_1': address1,
      'address_2': address2,
      'city': city,
      'state': state,
      'postcode': postcode,
      'country': country,
      'phone': phone,
      'email': email,
    };
  }
}

class CustomerModel {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String displayName;
  final String phone;
  final AddressModel billing;
  final AddressModel shipping;

  CustomerModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.displayName,
    required this.phone,
    required this.billing,
    required this.shipping,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      displayName: json['display_name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      billing: json['billing'] is Map<String, dynamic>
          ? AddressModel.fromJson(json['billing'])
          : AddressModel.empty(),
      shipping: json['shipping'] is Map<String, dynamic>
          ? AddressModel.fromJson(json['shipping'])
          : AddressModel.empty(),
    );
  }
}
