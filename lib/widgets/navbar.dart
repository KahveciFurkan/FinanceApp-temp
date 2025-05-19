import 'package:flutter/material.dart';

class SimpleBottomMenu extends StatelessWidget {
  final String activeTab;
  final void Function(String tab) onTabSelected;

  const SimpleBottomMenu({
    Key? key,
    required this.activeTab,
    required this.onTabSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color activeColor = Colors.orangeAccent;
    Color inactiveColor = Colors.grey;

    return Container(
      color: const Color(0xFF2C2C2E),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(
              Icons.home,
              color: activeTab == 'Home' ? activeColor : inactiveColor,
            ),
            onPressed: () => onTabSelected('Home'),
            tooltip: 'Ana Sayfa',
          ),
          IconButton(
            icon: Icon(
              Icons.savings,
              color: activeTab == 'Savings' ? activeColor : inactiveColor,
            ),
            onPressed: () => onTabSelected('Savings'),
            tooltip: 'Birikimlerim',
          ),
          IconButton(
            icon: Icon(
              Icons.assistant,
              color:
                  activeTab == 'FinanceAssistant' ? activeColor : inactiveColor,
            ),
            onPressed: () => onTabSelected('FinanceAssistant'),
            tooltip: 'Finans Yardımcısı',
          ),
        ],
      ),
    );
  }
}
