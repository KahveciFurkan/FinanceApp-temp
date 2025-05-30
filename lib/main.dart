import 'package:ff/screens/expenses/expense_adapter.dart';
import 'package:ff/screens/subscription/subscription_adapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './types/type.dart';
import './types/savings_transaction_adapter.dart';
import 'screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Intl.defaultLocale = 'tr_TR';
  await initializeDateFormatting('tr_TR');
  Hive.registerAdapter(SavingsTransactionAdapter()); // Adapter'ı burada kaydet
  Hive.registerAdapter(SubscriptionAdapter()); // Adapter'ı burada kaydet
  Hive.registerAdapter(ExpenseAdapter()); // Adapter'ı burada kaydet
  await Hive.openBox<SavingsTransaction>('transactionsBox');
  await Hive.openBox<Subscription>('subscriptions');
  // await Hive.deleteBoxFromDisk('expenses');
  await Hive.openBox<Expense>('expenses');

  QuickExpenseChannel.initListener();
  runApp(const FFApp());
}

class FFApp extends StatelessWidget {
  const FFApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Benim Finans AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const SplashScreen(),
    );
  }
}

class QuickExpenseChannel {
  static const MethodChannel _channel = MethodChannel('quick_expense_channel');

  static void initListener() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == "addQuickExpense") {
        final data = call.arguments as String;
        final parts = data.split('|');
        if (parts.length == 2) {
          final category = parts[0];
          final amount = double.tryParse(parts[1].replaceAll(",", ".")) ?? 0.0;

          final box = await Hive.openBox('expenses');
          await box.add({
            'category': category,
            'amount': amount,
            'date': DateTime.now().toIso8601String(),
          });

          print("✅ Hızlı harcama kaydedildi: $category - $amount");
        }
      }
    });
  }
}
