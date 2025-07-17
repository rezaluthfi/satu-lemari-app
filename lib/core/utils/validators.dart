class Validators {
  // Validate email format
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email cannot be empty';
    }

    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Invalid email format';
    }

    return null;
  }

  // Validate password strength
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    return null;
  }

  // Validate password confirmation
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Password confirmation cannot be empty';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  // Validate name input
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name cannot be empty';
    }

    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }

    return null;
  }

  // Validate phone number format
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number cannot be empty';
    }

    final phoneRegex = RegExp(r'^[0-9]{10,13}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'[^0-9]'), ''))) {
      return 'Invalid phone number format';
    }

    return null;
  }

  // Validate required field
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName cannot be empty';
    }
    return null;
  }
}
