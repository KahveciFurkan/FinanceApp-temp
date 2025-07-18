import 'package:ff/screens/assistant/assistant_screen.dart';
import 'package:ff/screens/subscription/subscription_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import './screens/home_screen.dart';
import './screens/savings_screen.dart';
import './screens/transactions_screen.dart';
import './widgets/app_drawer.dart';
import 'screens/node/mind_map_screen.dart'; // Drawer import

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SavingsScreen(),
    const FinanceAssistantScreen(),
    const TransactionsScreen(),
    const SubscriptionScreen(),
    const MindMapScreen(),
  ];

  final Map<int, String> _titles = {
    0: 'Ana Sayfa',
    1: 'Birikimler',
    2: 'Asistan',
    3: 'Islemler',
    4: 'Abonelikler',
    5: 'Notlar',
  };

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onDrawerItemSelected(int index) async {
    setState(() {
      _selectedIndex = index;
    });
    await Future.delayed(const Duration(milliseconds: 250));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(
        selectedIndex: _selectedIndex,
        onItemSelected: _onDrawerItemSelected,
      ),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1E), // Koyu arka plan
        surfaceTintColor: const Color(0xFF1C1C1E),
        title: Text(_titles[_selectedIndex]!),
        titleTextStyle: GoogleFonts.gochiHand(
          color: Colors.orangeAccent, // Başlık rengi
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
        iconTheme: const IconThemeData(
          color: Colors.orangeAccent, // Menü ve diğer ikonlar için renk
        ),
        elevation: 0,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex > 2 ? 0 : _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.orangeAccent,
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xFF1C1C1E),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana Sayfa'),
          BottomNavigationBarItem(
            icon: Icon(Icons.savings),
            label: 'Birikimler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assistant),
            label: 'Asistan',
          ),
        ],
      ),
    );
  }
}
