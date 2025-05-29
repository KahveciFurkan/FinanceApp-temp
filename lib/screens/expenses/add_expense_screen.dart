import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../types/type.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? editingExpense;

  const AddExpenseScreen({Key? key, this.editingExpense}) : super(key: key);

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String? _category;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Yiyecek', 'icon': Icons.fastfood, 'color': Colors.orangeAccent},
    {
      'name': 'Ulaşım',
      'icon': Icons.directions_car,
      'color': Colors.blueAccent,
    },
    {'name': 'Eğlence', 'icon': Icons.movie, 'color': Colors.purpleAccent},
    {'name': 'Fatura', 'icon': Icons.receipt_long, 'color': Colors.greenAccent},
    {'name': 'Diğer', 'icon': Icons.more_horiz, 'color': Colors.grey},
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

  final List<String> _titleSuggestions = [
    'Kira',
    'Fatura',
    'AVM Alışverişi',
    'Eğitim',
    'Spor',
    'Seyahat',
    'Diyet',
    'Hastane',
    'Giyim',
    'Market',
    'Ulaşım',
    'Eğlence',
  ];

  Future<void> _saveExpense() async {
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
      date: DateTime.now(),
    );

    final box = await Hive.openBox<Expense>('expenses');

    if (widget.editingExpense != null) {
      final key = box.keys.firstWhere((k) => box.get(k)?.id == expense.id);
      await box.put(key, expense);
    } else {
      await box.add(expense);
    }

    Navigator.of(context).pop();
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: const Color(0xFF2C2C2E),
            title: const Text(
              'Uyarı',
              style: TextStyle(color: Colors.orangeAccent),
            ),
            content: Text(
              message,
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Tamam',
                  style: TextStyle(color: Colors.orangeAccent),
                ),
              ),
            ],
          ),
    );
  }

  void _showCategoryGridPicker() {
    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            backgroundColor: const Color(0xFF1C1C1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              constraints: const BoxConstraints(maxHeight: 320),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Kategori Seçin',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orangeAccent,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: GridView.builder(
                      shrinkWrap: true,
                      itemCount: _categories.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1,
                          ),
                      itemBuilder: (ctx, index) {
                        final cat = _categories[index];
                        final isSelected = _category == cat['name'];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _category = cat['name'];
                            });
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? cat['color']
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: cat['color'], width: 2),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  cat['icon'],
                                  size: 40,
                                  color:
                                      isSelected ? Colors.black : cat['color'],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  cat['name'],
                                  style: TextStyle(
                                    color:
                                        isSelected
                                            ? Colors.black
                                            : Colors.orangeAccent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editingExpense != null;

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2C2E),
        iconTheme: const IconThemeData(color: Colors.orangeAccent),
        title: Text(
          isEditing ? 'Gideri Düzenle' : 'Harcama Ekle',
          style: const TextStyle(
            color: Colors.orangeAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Başlık kutusu
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color.fromARGB(255, 231, 230, 229),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orangeAccent.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _titleController,
                style: const TextStyle(color: Colors.orangeAccent),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.title, color: Colors.orangeAccent),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  labelText: 'Başlık',
                  labelStyle: TextStyle(color: Colors.orangeAccent),
                  hintText: 'Örneğin: Kira',
                  hintStyle: TextStyle(color: Colors.orangeAccent),
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 8),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _titleSuggestions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final suggestion = _titleSuggestions[index];
                  return OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: const Color(0xFFC0C0C0),
                      side: const BorderSide(
                        color: Color.fromARGB(255, 233, 231, 228),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      foregroundColor: const Color.fromARGB(255, 231, 230, 229),
                    ),
                    onPressed: () {
                      setState(() {
                        _titleController.text = suggestion;
                      });
                    },
                    child: Text(
                      suggestion,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C2C2E),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Tutar kutusu
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color.fromARGB(255, 233, 232, 230),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orangeAccent.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: const TextStyle(color: Colors.orangeAccent),
                decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Icons.attach_money,
                    color: Colors.orangeAccent,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  labelText: 'Tutar',
                  labelStyle: TextStyle(color: Colors.orangeAccent),
                  hintText: 'Örneğin: 1500',
                  hintStyle: TextStyle(color: Colors.orangeAccent),
                  border: InputBorder.none,
                ),
              ),
            ),
            // Tutar hızlı giriş butonları
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:
                    [200, 300, 500, 600].map((amount) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            216,
                            214,
                            212,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _amountController.text = amount.toString();
                          });
                        },
                        child: Text(
                          amount.toString(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Kategori seçici
            InkWell(
              onTap: _showCategoryGridPicker,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 70,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color.fromARGB(255, 238, 237, 235),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orangeAccent.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (_category != null)
                      Icon(
                        _categories.firstWhere(
                          (c) => c['name'] == _category,
                        )['icon'],
                        color: Colors.orangeAccent,
                        size: 32,
                      )
                    else
                      const Icon(
                        Icons.label_outline,
                        color: Colors.orangeAccent,
                        size: 32,
                      ),
                    const SizedBox(width: 12),
                    Text(
                      _category ?? 'Kategori Seçin...',
                      style: const TextStyle(
                        color: Colors.orangeAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.orangeAccent,
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Butonlar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: Text(
                    widget.editingExpense != null ? 'Güncelle' : 'Kaydet',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: _saveExpense,
                ),
                if (widget.editingExpense != null)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.close),
                    label: const Text('İptal'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade800,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orangeAccent,
                      ),
                      foregroundColor: Colors.orangeAccent,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
