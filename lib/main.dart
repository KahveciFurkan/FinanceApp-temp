import 'package:ff/screens/expenses/expense_adapter.dart';
import 'package:ff/screens/subscription/subscription_adapter.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import './types/type.dart';
import './types/savings_transaction_adapter.dart';
import 'screens/splash/splash_screen.dart';
import 'service/weather_notifier.dart';
import 'types/node_model.dart';
import 'utils/hive/rejected_suggestion.dart';
import 'widgets/node/connection_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Intl.defaultLocale = 'tr_TR';
  await initializeDateFormatting('tr_TR');
  Hive.registerAdapter(SavingsTransactionAdapter()); // Adapter'ı burada kaydet
  Hive.registerAdapter(SubscriptionAdapter()); // Adapter'ı burada kaydet
  Hive.registerAdapter(ExpenseAdapter()); // Adapter'ı burada kaydet
  Hive.registerAdapter(NodeModelAdapter());
  Hive.registerAdapter(ConnectionModelAdapter());

  await Hive.openBox<NodeModel>('nodes');
  await Hive.openBox<ConnectionModel>('connections');
  await Hive.openBox<SavingsTransaction>('transactionsBox');
  await Hive.openBox<Subscription>('subscriptions');
  await Hive.openBox<RejectedSuggestion>('rejectedSuggestions');
  // await Hive.deleteBoxFromDisk('expenses');
  await Hive.openBox<Expense>('expenses');

  final weatherNotifier = WeatherNotifier();
  await weatherNotifier.initialize();
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
