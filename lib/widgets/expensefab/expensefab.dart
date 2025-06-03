import 'dart:math';
import 'package:flutter/material.dart';

class ExpenseFAB extends StatefulWidget {
  final VoidCallback onPressed;

  const ExpenseFAB({super.key, required this.onPressed});

  @override
  State<ExpenseFAB> createState() => _ExpenseFABState();
}

class _ExpenseFABState extends State<ExpenseFAB> {
  final List<String> emojis = ['💰', '💵', '🧾', '🪙'];
  String emoji = '💰'; // ✅ İlk değer verildi

  String _getRandomEmoji() {
    String newEmoji;
    do {
      newEmoji = emojis[Random().nextInt(emojis.length)];
    } while (newEmoji == emoji); // Aynı emoji üst üste gelmesin
    return newEmoji;
  }

  void _handleTap() {
    setState(() {
      emoji = _getRandomEmoji();
    });
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 10,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        onTap: _handleTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFC107), Color(0xFFFF5722)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.orangeAccent.withOpacity(0.6),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(
                    scale: CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutBack,
                    ),
                    child: child,
                  );
                },
                child: Text(
                  emoji,
                  key: ValueKey(emoji),
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                "Masraf Ekle",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
