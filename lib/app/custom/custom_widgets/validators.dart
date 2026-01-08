class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  //  validat password with 8 char, symbol, and number
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters long';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    final phoneRegex = RegExp(r'^[0-9]{10}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  static String? validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return 'Age is required';
    }
    final age = int.tryParse(value);
    if (age == null || age < 1 || age > 100) {
      return 'Enter a valid age between 1 and 100';
    }
    return null;
  }

  static String? validateNumber(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (int.tryParse(value) == null) {
      return '$fieldName must be a number';
    }
    return null;
  }

  static String? validatePinCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'PIN Code is required';
    }
    final pinRegex = RegExp(r'^[0-9]{6}$');
    if (!pinRegex.hasMatch(value)) {
      return 'Enter a valid 6-digit PIN Code';
    }
    return null;
  }

  // validete height in cm
  static String? validateHeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Height is required';
    }
    final height = int.tryParse(value);
    if (height == null || height < 30 || height > 250) {
      return 'Enter a valid height in cm (e.g., 170)';
    }
    return null;
  }

  // validat weight
  static String? validateWeight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Weight is required';
    }
    final weight = int.tryParse(value);
    if (weight == null || weight < 1 || weight > 300) {
      return 'Enter a valid weight in kg (e.g., 70)';
    }
    return null;
  }
  
  static String? validateAadhar(String? value) {
    if (value == null || value.isEmpty) {
      return 'Aadhar number is required';
    }
    final aadharRegex = RegExp(r'^[0-9]{12}$');
    if (!aadharRegex.hasMatch(value)) {
      return 'Enter a valid 12-digit Aadhar number';
    }
    return null;
  }
}
