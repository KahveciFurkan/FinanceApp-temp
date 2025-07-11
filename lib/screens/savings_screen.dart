import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/bank_widget.dart';
import '../widgets/savings_goal_item_widget.dart';
import '../types/type.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({Key? key}) : super(key: key);

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  double userTotalSavings = 0;

  List<SavingsTransaction> transactions = [];

  List<SavingsGoal> goals = [
    const SavingsGoal(
      title: 'Tatil',
      targetAmount: 15000,
      savedAmount: 5600.75,
    ),
    const SavingsGoal(title: 'Telefon', targetAmount: 25000, savedAmount: 8000),
    const SavingsGoal(title: 'Düğün', targetAmount: 60000, savedAmount: 25000),
  ];

  @override
  void initState() {
    super.initState();
    // Mevcut hedeflerin tamamlanan toplamını hesapla
    userTotalSavings = goals.fold(0.0, (sum, g) => sum + g.savedAmount);
  }

  // Hedef düzenleme popup'ı
  void editGoalPopup(int index) {
    final goal = goals[index];
    final titleController = TextEditingController(text: goal.title);
    final targetController = TextEditingController(
      text: goal.targetAmount.toString(),
    );
    final savedController = TextEditingController(
      text: goal.savedAmount.toString(),
    );

    showDialog(
      context: context,
      builder:
          (_) => Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Card(
                color: const Color(0xFF2C2C2E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '🎯 ',
                            style: GoogleFonts.gochiHand(
                              fontSize: 24,
                              color: Colors.orangeAccent,
                            ),
                          ),
                          Text(
                            'Hedefi Düzenle',
                            style: GoogleFonts.gochiHand(
                              fontSize: 24,
                              color: Colors.orangeAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildEmojiTextField(
                        controller: titleController,
                        label: '🥅 Başlık',
                      ),
                      _buildEmojiTextField(
                        controller: targetController,
                        label: '🏆 Hedef Tutar (₺)',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      _buildEmojiTextField(
                        controller: savedController,
                        label: '💰 Şuanki Birikim (₺)',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Canlı gradient buton
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFAB40), Color(0xFFFF6F00)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            splashColor: Colors.white24,
                            onTap: () {
                              final updated = SavingsGoal(
                                title: titleController.text,
                                targetAmount:
                                    double.tryParse(targetController.text) ??
                                    goal.targetAmount,
                                savedAmount:
                                    double.tryParse(savedController.text) ??
                                    goal.savedAmount,
                              );
                              setState(() {
                                goals[index] = updated;
                                userTotalSavings = goals.fold(
                                  0.0,
                                  (sum, g) => sum + g.savedAmount,
                                );
                              });
                              Navigator.pop(context);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Kaydet',
                                    style: GoogleFonts.gochiHand(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }

  // Manuel birikim düzenleme
  void _showEditTotalSavings() {
    final controller = TextEditingController(text: userTotalSavings.toString());
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 32.0,
              vertical: 24.0,
            ),
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '🔄 Birikimi Güncelle',
                    style: GoogleFonts.gochiHand(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.orangeAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Toplam Birikim (₺)',
                      filled: true,
                      fillColor: Colors.white10,
                      labelStyle: const TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final value = double.tryParse(controller.text);
                        if (value != null) {
                          setState(() {
                            userTotalSavings = value;
                          });
                        }
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orangeAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        elevation: 4,
                      ),
                      child: Text(
                        'Kaydet',
                        style: GoogleFonts.gochiHand(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromARGB(
                            255,
                            51,
                            50,
                            50,
                          ), // buton metni artık beyaz
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildEmojiTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white10,
          labelStyle: const TextStyle(color: Colors.white70),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1E),
        surfaceTintColor: const Color(0xFF1C1C1E),
        elevation: 0,
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _showEditTotalSavings,
            tooltip: 'Birikimi Düzenle',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _showEditTotalSavings,
              child: PiggyBankWidget(totalSavings: userTotalSavings),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Hedefler',
                style: GoogleFonts.gochiHand().copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orangeAccent,
                  fontSize: 24,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              flex: 3,
              child: ListView(
                children:
                    goals
                        .asMap()
                        .entries
                        .map(
                          (entry) => GestureDetector(
                            onTap: () => editGoalPopup(entry.key),
                            child: SavingsGoalItemWidget(goal: entry.value),
                          ),
                        )
                        .toList(),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
