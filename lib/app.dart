import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/savings_screen.dart';
import 'screens/admin_screen.dart';
import 'routes.dart';

class FFApp extends StatelessWidget {
  const FFApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  title: 'FF',
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1C1C1E),  // Koyu arka plan
      iconTheme: IconThemeData(color: Colors.orangeAccent),  // İkon rengi
      titleTextStyle: TextStyle(
        color: Colors.orangeAccent,  // Başlık rengi
        fontWeight: FontWeight.bold,
        fontSize: 22,
      ),
      elevation: 0, // İstersen gölgeyi azaltabilirsin
    ),
    scaffoldBackgroundColor: const Color(0xFF1C1C1E), // Genel arka plan
  ),
  initialRoute: Routes.home,
  routes: {
    Routes.home: (context) => const HomeScreen(),
    Routes.savings: (context) => const SavingsScreen(),
    // diğer rotalar
    Routes.admin: (context) => const AdminScreen(),
  },
);

  }
}
