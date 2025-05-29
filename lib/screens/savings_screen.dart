import 'package:flutter/material.dart';
import '../widgets/bank_widget.dart';
import '../widgets/edit_goal_bottom_sheet.dart';
import '../widgets/savings_goal_item_widget.dart';
import '../widgets/transaction_list_widget.dart';
import '../widgets/add_transaction_bottom_sheet.dart';
import '../types/type.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({Key? key}) : super(key: key);

  @override
  State<SavingsScreen> createState() => _SavingsScreenState();
}

class _SavingsScreenState extends State<SavingsScreen> {
  double userTotalSavings = 5600.75;

  List<SavingsTransaction> transactions =
      []; // boş başlangıç, istersen örnek veri ekleyebilirsin

  void _showAddTransaction() {
    // İşlem ekleme popup veya sayfası henüz yoksa basitçe snackbar göster
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('İşlem ekleme fonksiyonu henüz tanımlanmadı'),
      ),
    );
  }

  List<SavingsGoal> goals = [
    const SavingsGoal(
      title: 'Tatil',
      targetAmount: 15000,
      savedAmount: 5600.75,
    ),
    const SavingsGoal(title: 'Telefon', targetAmount: 25000, savedAmount: 8000),
    const SavingsGoal(title: 'Düğün', targetAmount: 60000, savedAmount: 25000),
  ];

  void editGoalPopup(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF2C2C2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return EditGoalBottomSheet(
          goal: goals[index],
          onSave: (updatedGoal) {
            setState(() {
              goals[index] = updatedGoal;
            });
          },
        );
      },
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PiggyBankWidget(totalSavings: userTotalSavings),
            const SizedBox(height: 24),
            // Hedefler Başlığı
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Hedefler',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orangeAccent,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Hedefler Listesi (ListView yerine Expanded ile sarmalıyoruz)
            Expanded(
              flex: 3, // Hedeflere daha fazla yer verebiliriz
              child: ListView(
                children:
                    goals.asMap().entries.map((entry) {
                      return GestureDetector(
                        onTap: () => editGoalPopup(entry.key),
                        child: SavingsGoalItemWidget(goal: entry.value),
                      );
                    }).toList(),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
