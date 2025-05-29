import 'package:ff/utils/helper/helperfunctions.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../types/type.dart';

class FinanceAssistantScreen extends StatefulWidget {
  const FinanceAssistantScreen({Key? key}) : super(key: key);

  @override
  State<FinanceAssistantScreen> createState() => _FinanceAssistantScreenState();
}

class _FinanceAssistantScreenState extends State<FinanceAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];

  final List<Map<String, String>> _buttonCommands = [
    {"label": "Bu ay toplam harcama", "command": "bu_ay_toplam"},
    {"label": "En çok harcama kategorisi", "command": "en_cok_kategori"},
    {
      "label": "Harcamaları kategorilere göre göster",
      "command": "kategori_ozet",
    },
    {"label": "Son 7 gün harcaması", "command": "son_7_gun"},
  ];

  late Box<Expense> expenseBox;

  @override
  void initState() {
    super.initState();
    expenseBox = Hive.box<Expense>('expenses');
    _messages.add({
      "role": "bot",
      "text": "Merhaba, nasıl yardımcı olabilirim?",
    });
  }

  List<Expense> _getAllExpenses() {
    return expenseBox.values.toList();
  }

  void _sendMessage() {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "text": input});
      _messages.add({"role": "bot", "text": _generateBotReply(input)});
      _controller.clear();
    });
  }

  void _handleButtonClick(String command) {
    setState(() {
      String botReply = _generateBotReplyFromCommand(command);
      _messages.add({"role": "user", "text": _getLabelByCommand(command)});
      _messages.add({"role": "bot", "text": botReply});
    });
  }

  String _getLabelByCommand(String command) {
    return _buttonCommands.firstWhere(
          (btn) => btn["command"] == command,
        )["label"] ??
        "";
  }

  String _generateBotReply(String message) {
    message = message.toLowerCase();
    if (message.contains("ne kadar") || message.contains("toplam")) {
      return _generateBotReplyFromCommand("bu_ay_toplam");
    } else if (message.contains("en çok")) {
      return _generateBotReplyFromCommand("en_cok_kategori");
    } else if (message.contains("kategori")) {
      return _generateBotReplyFromCommand("kategori_ozet");
    } else if (message.contains("7 gün") || message.contains("son yedi")) {
      return _generateBotReplyFromCommand("son_7_gun");
    } else {
      return "Sorunu tam anlayamadım. Örnek: 'Bu ay ne kadar harcadım?'";
    }
  }

  String _generateBotReplyFromCommand(String command) {
    final now = DateTime.now();
    final expenses = _getAllExpenses();

    switch (command) {
      case "bu_ay_toplam":
        double total = expenses
            .where((e) => e.date.year == now.year && e.date.month == now.month)
            .fold(0.0, (sum, e) => sum + e.amount);
        return "Bu ay toplam harcaman ${formatAmount(total)}₺.";

      case "en_cok_kategori":
        Map<String, double> categoryTotals = {};
        for (var e in expenses) {
          if (e.date.year == now.year && e.date.month == now.month) {
            categoryTotals[e.category] =
                (categoryTotals[e.category] ?? 0) + e.amount;
          }
        }
        if (categoryTotals.isEmpty) return "Bu ay harcama bulunamadı.";
        final highest = categoryTotals.entries.reduce(
          (a, b) => a.value > b.value ? a : b,
        );
        return "En çok harcama ${highest.key} kategorisinde: ${formatAmount(highest.value)}₺.";

      case "kategori_ozet":
        Map<String, double> categoryTotals = {};
        for (var e in expenses) {
          if (e.date.year == now.year && e.date.month == now.month) {
            categoryTotals[e.category] =
                (categoryTotals[e.category] ?? 0) + e.amount;
          }
        }
        if (categoryTotals.isEmpty) return "Bu ay harcama bulunamadı.";
        final buffer = StringBuffer();
        buffer.writeln("Kategori bazlı harcama özetin:");
        categoryTotals.forEach((key, value) {
          buffer.writeln("- $key: ${formatAmount(value)}₺");
        });
        return buffer.toString();

      case "son_7_gun":
        final sevenDaysAgo = now.subtract(const Duration(days: 7));
        double last7Days = expenses
            .where((e) => e.date.isAfter(sevenDaysAgo))
            .fold(0.0, (sum, e) => sum + e.amount);
        return "Son 7 gün içinde toplam ${formatAmount(last7Days)}₺ harcadın.";

      default:
        return "Bu konu hakkında en ufak fikrim yok.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg["role"] == "user";
                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isUser
                                ? Colors.orangeAccent
                                : const Color.fromARGB(255, 243, 220, 220),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        msg["text"]!,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              color: const Color(0xFF2C2C2E),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children:
                      _buttonCommands.map((btn) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orangeAccent,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            onPressed:
                                () => _handleButtonClick(btn["command"]!),
                            child: Text(btn["label"]!),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
            Container(
              color: const Color(0xFF2C2C2E),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Bir şeyler sor...",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.orangeAccent),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
