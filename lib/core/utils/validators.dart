class Validators {
  static String? required(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? amount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Enter a valid amount';
    }
    if (amount <= 0) {
      return 'Amount must be greater than zero';
    }
    return null;
  }

  static String? percent(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Optional
    }
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Enter a valid number';
    }
    if (amount < 0) {
      return 'Cannot be negative';
    }
    return null;
  }
}
