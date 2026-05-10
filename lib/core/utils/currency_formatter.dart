import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount, {String currency = 'PKR'}) {
    final format = NumberFormat.currency(
      symbol: '$currency ',
      decimalDigits: 2,
    );
    return format.format(amount);
  }
}
