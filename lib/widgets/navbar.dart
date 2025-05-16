import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  final String active;
  final Function(String) setActive;
  final Function(String) navigate;

  const BottomNavBar({
    super.key,
    required this.active,
    required this.setActive,
    required this.navigate,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  bool loading = false;

  final List<Map<String, String>> tabs = [
    {'label': '🏠', 'screen': 'Home'},
    {'label': '💰', 'screen': 'Savings'},
    {'label': '🧠', 'screen': 'FinanceAssistant'},
  ];

  void handlePress(String screen) {
    if (widget.active == screen || loading) return;

    setState(() => loading = true);

    Future.delayed(const Duration(milliseconds: 700), () {
      widget.setActive(screen);
      widget.navigate(screen);
      setState(() => loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Positioned(
        bottom: 15,
        left: 16,
        right: 16,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1c1c1e),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black38,
                offset: Offset(0, -2),
                blurRadius: 6,
              )
            ],
          ),
          child: Column(
            children: const [
              Text('🤖', style: TextStyle(fontSize: 28)),
              SizedBox(height: 8),
              Text(
                'Yükleniyor...',
                style: TextStyle(
                  color: Color(0xFFFF9F40),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Positioned(
      bottom: 15,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1c1c1e),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              offset: Offset(0, -2),
              blurRadius: 6,
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: tabs.map((tab) {
            final isActive = widget.active == tab['screen'];
            return GestureDetector(
              onTap: () => handlePress(tab['screen']!),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFFFF9F40) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tab['label']!,
                  style: TextStyle(
                    fontSize: isActive ? 28 : 24,
                    color: isActive ? const Color(0xFFFF9F40) : const Color(0xFFcfcfcf),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
