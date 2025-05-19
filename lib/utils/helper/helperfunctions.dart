import 'package:intl/intl.dart';

String formatAmount(double amount) {
  return NumberFormat("#,##0.00", "tr_TR").format(amount);
}
