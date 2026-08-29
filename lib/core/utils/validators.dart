class Validators {
  static bool isValidEmail(String email) {
    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return regex.hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    final regex = RegExp(r'^\+?[\d\s\-()]{7,15}$');
    return regex.hasMatch(phone);
  }

  static bool isValidName(String name) {
    return name.trim().length >= 2;
  }

  static bool isStrongPassword(String password) {
    if (password.length < 8) return false;
    final hasUpper = password.contains(RegExp(r'[A-Z]'));
    final hasLower = password.contains(RegExp(r'[a-z]'));
    final hasDigit = password.contains(RegExp(r'\d'));
    final hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    return hasUpper && hasLower && hasDigit && hasSpecial;
  }

  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) return 'Email is required';
    if (!isValidEmail(email)) return 'Please enter a valid email';
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) return 'Password is required';
    if (password.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  static String? validateName(String? name) {
    if (name == null || name.isEmpty) return 'Name is required';
    if (!isValidName(name)) return 'Please enter a valid name';
    return null;
  }

  static String? validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) return null;
    if (!isValidPhone(phone)) return 'Please enter a valid phone number';
    return null;
  }
}
