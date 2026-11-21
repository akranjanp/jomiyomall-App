class Validators {
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? "This field"} is required.';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required.';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required.';
    }
    final clean = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.length < 10) {
      return 'Please enter a valid 10-digit mobile number.';
    }
    return null;
  }

  static String? pincode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'PIN code is required.';
    }
    final clean = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.length != 6) {
      return 'Please enter a valid 6-digit Indian PIN code.';
    }
    return null;
  }
}
