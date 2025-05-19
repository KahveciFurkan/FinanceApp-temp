import 'package:flutter/material.dart';
import '../types/type.dart';

class EditGoalBottomSheet extends StatefulWidget {
  final SavingsGoal goal;
  final Function(SavingsGoal) onSave;

  const EditGoalBottomSheet({
    Key? key,
    required this.goal,
    required this.onSave,
  }) : super(key: key);

  @override
  State<EditGoalBottomSheet> createState() => _EditGoalBottomSheetState();
}

class _EditGoalBottomSheetState extends State<EditGoalBottomSheet> {
  late TextEditingController titleController;
  late TextEditingController targetAmountController;
  late TextEditingController savedAmountController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.goal.title);
    targetAmountController = TextEditingController(text: widget.goal.targetAmount.toString());
    savedAmountController = TextEditingController(text: widget.goal.savedAmount.toString());
  }

  @override
  void dispose() {
    titleController.dispose();
    targetAmountController.dispose();
    savedAmountController.dispose();
    super.dispose();
  }

  void save() {
    final updatedGoal = SavingsGoal(
      title: titleController.text,
      targetAmount: double.tryParse(targetAmountController.text) ?? 0,
      savedAmount: double.tryParse(savedAmountController.text) ?? 0,
    );
    widget.onSave(updatedGoal);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Colors.white;
    final borderColor = Colors.orangeAccent;

    return Container(
      color: const Color(0xFF1C1C1E),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24,
        left: 16,
        right: 16,
      ),
      child: Wrap(
        children: [
          Text(
            'Hedefi Düzenle',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orangeAccent,
                ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: titleController,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              labelText: 'Hedef Adı',
              labelStyle: TextStyle(color: borderColor),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: borderColor, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: targetAmountController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              labelText: 'Hedef Tutarı (₺)',
              labelStyle: TextStyle(color: borderColor),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: borderColor, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: savedAmountController,
            keyboardType: TextInputType.number,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              labelText: 'Şu Anki Birikim (₺)',
              labelStyle: TextStyle(color: borderColor),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: borderColor, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 44),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: save,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Kaydet',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
