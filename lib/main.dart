import 'package:ff/screens/subscription/subscription_adapter.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'app.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
  await Hive.openBox<SavingsTransaction>('transactionsBox');
  await Hive.openBox<Subscription>('subscriptions');

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
