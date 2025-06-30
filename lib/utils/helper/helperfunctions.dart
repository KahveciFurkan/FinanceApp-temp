import 'package:intl/intl.dart';

String formatAmount(double amount) {
  return NumberFormat("#,##0.00", "tr_TR").format(amount);
}

const String macAddres = '2C:F0:5D:6E:A6:25';
const String ipv4Add = '192.168.1.255';
