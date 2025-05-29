import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../helpers/bot_logic.dart';
import '../../types/type.dart';

class FinanceAssistantScreen extends StatefulWidget {
  const FinanceAssistantScreen({super.key});

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

  List<Expense> _getAllExpenses() => expenseBox.values.toList();

  void _sendMessage() {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    final expenses = _getAllExpenses();
    final reply = generateBotReply(input, expenses);

    setState(() {
      _messages.add({"role": "user", "text": input});
      _messages.add({"role": "bot", "text": reply});
      _controller.clear();
    });
  }

  void _handleButtonClick(String command) {
    final expenses = _getAllExpenses();
    final label =
        _buttonCommands.firstWhere((e) => e["command"] == command)["label"]!;
    final reply = generateReplyFromCommand(command, expenses);

    setState(() {
      _messages.add({"role": "user", "text": label});
      _messages.add({"role": "bot", "text": reply});
    });
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
                      decoration: BoxDecoration(
                        color: isUser ? Colors.orangeAccent : Colors.grey[300],
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
                child: Row(
                  children:
                      _buttonCommands.map((btn) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orangeAccent,
                              foregroundColor: Colors.black,
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
              padding: const EdgeInsets.all(8),
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
