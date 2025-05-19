import 'package:flutter/material.dart';
import '../types/type.dart';
import 'package:hive/hive.dart';


class AddTransactionBottomSheet extends StatefulWidget {
  final Function(SavingsTransaction) onSave;

  const AddTransactionBottomSheet({Key? key, required this.onSave})
    : super(key: key);

  @override
  State<AddTransactionBottomSheet> createState() =>
      _AddTransactionBottomSheetState();
}

class _AddTransactionBottomSheetState extends State<AddTransactionBottomSheet> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  String type = 'Ekleme'; // Varsayılan işlem tipi
  String currency = '₺'; // Varsayılan para birimi

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    super.dispose();
  }

  

  void  save()  async{
    var box = Hive.box<SavingsTransaction>('transactionsBox');
    final amount = double.tryParse(amountController.text) ?? 0;
    if (titleController.text.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen geçerli değerler girin')),
      );
      return;
    }

    final transaction = SavingsTransaction(
      title: titleController.text,
      amount: amount,
      date: DateTime.now(),
      type: type,
      currency: currency,
    );

    await widget.onSave(transaction); // Burada onAdd kullanılıyor
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24,
        left: 16,
        right: 16,
      ),
      child: Wrap(
        children: [
          Text(
            'Yeni İşlem Ekle',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'İşlem Adı'),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText:
                  (currency == 'Altın' || currency == 'Gümüş')
                      ? 'Gram Cinsinden Miktar'
                      : 'Tutar',
            ),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: type,
            decoration: const InputDecoration(labelText: 'İşlem Tipi'),
            items:
                ['Ekleme', 'Çekme']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
            onChanged: (val) {
              setState(() {
                type = val ?? 'Ekleme';
              });
            },
            dropdownColor: const Color(0xFF1C1C1E),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: currency,
            decoration: const InputDecoration(labelText: 'Para Birimi'),
            items:
                ['₺', 'USD', 'EUR', 'Altın', 'Gümüş']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
            onChanged: (val) {
              setState(() {
                currency = val ?? '₺';
              });
            },
            dropdownColor: const Color(0xFF1C1C1E),
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: save,
              child: const Text('Kaydet'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
