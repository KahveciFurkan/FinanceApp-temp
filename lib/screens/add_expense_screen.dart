import 'package:flutter/material.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? editingExpense;
  final Function(Expense) addExpense;

  const AddExpenseScreen({
    Key? key,
    this.editingExpense,
    required this.addExpense,
  }) : super(key: key);

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String? _category;
  bool _isLoading = false;

  final List<String> _categories = [
    'Yiyecek',
    'Ulaşım',
    'Eğlence',
    'Fatura',
    'Diğer',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.editingExpense != null) {
      _titleController.text = widget.editingExpense!.title;
      _amountController.text = widget.editingExpense!.amount.toString();
      _category = widget.editingExpense!.category;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _saveExpense() {
    final title = _titleController.text.trim();
    final amountText = _amountController.text.trim();
    final category = _category;

    if (title.isEmpty || amountText.isEmpty || category == null) {
      _showAlert('Lütfen tüm alanları doldurun');
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null) {
      _showAlert('Geçerli bir tutar girin');
      return;
    }

    final expense = Expense(
      id:
          widget.editingExpense?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      category: category,
      date: widget.editingExpense?.date ?? DateTime.now(),
    );

    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 700), () {
      widget.addExpense(expense);
      setState(() => _isLoading = false);
      Navigator.of(context).pop();
    });
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Uyarı'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Tamam'),
              ),
            ],
          ),
    );
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2c2c2e),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (ctx) => SizedBox(
            height: 250,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Kategori Seçin',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: _categories.length,
                    separatorBuilder:
                        (_, __) => const Divider(color: Colors.orange),
                    itemBuilder: (ctx, i) {
                      final cat = _categories[i];
                      return ListTile(
                        title: Text(
                          cat,
                          style: const TextStyle(color: Colors.white),
                        ),
                        onTap: () {
                          setState(() {
                            _category = cat;
                          });
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editingExpense != null;

    return Scaffold(
      backgroundColor: const Color(0xFF404448),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2c2c2e),
        title: Text(isEditing ? 'Gideri Düzenle' : 'Gider Ekle'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: CircularProgressIndicator(color: Colors.orange),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Başlık
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Başlık',
                labelStyle: const TextStyle(color: Colors.white),
                hintText: 'Örneğin: Fatura',
                hintStyle: const TextStyle(color: Colors.white54),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFFFF9F40)),
                  borderRadius: BorderRadius.circular(5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFFFF9F40)),
                  borderRadius: BorderRadius.circular(5),
                ),
                filled: true,
                fillColor: const Color(0xFF2c2c2e),
              ),
            ),

            const SizedBox(height: 12),

            // Tutar
            TextField(
              controller: _amountController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Tutar',
                labelStyle: const TextStyle(color: Colors.white),
                hintText: 'Örneğin: 250',
                hintStyle: const TextStyle(color: Colors.white54),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFFFF9F40)),
                  borderRadius: BorderRadius.circular(5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFFFF9F40)),
                  borderRadius: BorderRadius.circular(5),
                ),
                filled: true,
                fillColor: const Color(0xFF2c2c2e),
              ),
            ),

            const SizedBox(height: 12),

            // Kategori Seçici
            GestureDetector(
              onTap: _showCategoryPicker,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 10,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFFF9F40)),
                  borderRadius: BorderRadius.circular(5),
                  color: const Color(0xFF2c2c2e),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _category ?? 'Kategori Seçin...',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const Icon(Icons.arrow_drop_down, color: Colors.white),
                  ],
                ),
              ),
            ),

            const Spacer(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Kaydet/Güncelle
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7043),
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 25,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  onPressed: _isLoading ? null : _saveExpense,
                  child: Text(
                    isEditing ? 'Güncelle' : 'Kaydet',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),

                // Anasayfaya Dön
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0288d1),
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 25,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Anasayfaya dön',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  });
}
