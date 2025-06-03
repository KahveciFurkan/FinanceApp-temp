import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../types/type.dart';
import '../../utils/hive/rejected_suggestion.dart';
import '../../utils/suggestions.dart';
import '../../widgets/aicard/ai_hint_card.dart'; // Expense model burada

class AddExpenseScreen extends StatefulWidget {
  final Expense? editingExpense;

  const AddExpenseScreen({Key? key, this.editingExpense}) : super(key: key);

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  List<String> _titleSuggestions = [];
  String? _category;
  String? _aiSuggestion;

  final _quickAmounts = [50, 100, 250, 500];

  final _categories = [
    {'name': 'Fatura', 'icon': Icons.receipt, 'color': Colors.green},
    {'name': 'Yiyecek', 'icon': Icons.fastfood, 'color': Colors.orange},
    {
      'name': 'Ulaşım',
      'icon': Icons.directions_bus,
      'color': Colors.blueAccent,
    },
    {'name': 'Eğlence', 'icon': Icons.movie, 'color': Colors.purple},
    {'name': 'Sağlık', 'icon': Icons.local_hospital, 'color': Colors.red},
    {'name': 'Giyim', 'icon': Icons.checkroom, 'color': Colors.pink},
    {'name': 'Ev', 'icon': Icons.home, 'color': Colors.brown},
    {'name': 'Eğitim', 'icon': Icons.school, 'color': Colors.indigo},
    {'name': 'Seyahat', 'icon': Icons.flight, 'color': Colors.teal},
    {'name': 'Kişisel Bakım', 'icon': Icons.spa, 'color': Colors.lightGreen},
    {'name': 'Spor', 'icon': Icons.sports_soccer, 'color': Colors.lightBlue},
    {'name': 'Teknoloji', 'icon': Icons.computer, 'color': Colors.deepPurple},
    {
      'name': 'Vergi & Sigorta',
      'icon': Icons.account_balance,
      'color': Colors.blueGrey,
    },
    {
      'name': 'Çocuk & Bebek',
      'icon': Icons.child_care,
      'color': Colors.purpleAccent,
    },
    {
      'name': 'Bağış & Hediye',
      'icon': Icons.card_giftcard,
      'color': Colors.redAccent,
    },
    {'name': 'Evcil Hayvan', 'icon': Icons.pets, 'color': Colors.amber},
    {'name': 'Ofis & İş', 'icon': Icons.work, 'color': Colors.blueGrey[800]},
    {'name': 'Tamir & Bakım', 'icon': Icons.build, 'color': Colors.deepOrange},
    {'name': 'Diğer', 'icon': Icons.more_horiz, 'color': Colors.grey},
  ];

  @override
  void initState() {
    super.initState();
    _updateSuggestions('');
    if (widget.editingExpense != null) {
      _titleController.text = widget.editingExpense!.title;
      _amountController.text = widget.editingExpense!.amount.toString();
      _category = widget.editingExpense!.category;
    }
  }

  String? _suggestedCategory;
  double? _confidenceScore;

  void _generateAISuggestion() async {
    final title = _titleController.text.toLowerCase();
    final warning = await getImprovedAISuggestion(title);
    if (warning != null) {
      setState(() {
        _aiSuggestion = warning;
        _category = null;
      });
      return;
    }
    _updateSuggestions(title);

    final result = generateAISuggestion(_titleController.text);
    setState(() {
      _aiSuggestion = result.suggestionText;
      _suggestedCategory = result.category;
      _confidenceScore = result.confidence;
    });
    getVisibleCategories(title, _suggestedCategory);
  }

  List<Map<String, Object?>> getVisibleCategories(
    String titleInput,
    String? aiSuggestedCategory,
  ) {
    final input = titleInput.toLowerCase();

    if (input.isEmpty) {
      return _categories.take(5).toList();
    }

    if (aiSuggestedCategory != null) {
      return [
        _categories.firstWhere((cat) => cat['name'] == aiSuggestedCategory),
      ];
    }

    return [_categories.firstWhere((cat) => cat['name'] == "Diğer")];
  }

  void _updateSuggestions(String input) {
    setState(() {
      _titleSuggestions = getFilteredSuggestions(input);
    });
  }

  void _rejectAISuggestion(String title, String? category) async {
    final box = Hive.box<RejectedSuggestion>('rejectedSuggestions');
    final rejected = RejectedSuggestion(
      title: title,
      suggestedCategory: category,
      rejectedAt: DateTime.now(),
    );
    await box.add(rejected);
  }

  Future<void> _saveExpense() async {
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());
    if (title.isEmpty || amount == null || _category == null) {
      _showAlert('Lütfen tüm alanları eksiksiz doldurun.');
      return;
    }

    final newExpense = Expense(
      id:
          widget.editingExpense?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      category: _category!,
      date: DateTime.now(),
    );

    final box = await Hive.openBox<Expense>('expenses');
    if (widget.editingExpense != null) {
      final key = box.keys.firstWhere((k) => box.get(k)?.id == newExpense.id);
      await box.put(key, newExpense);
    } else {
      await box.add(newExpense);
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

  Widget _buildCategorySelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children:
          _categories.take(5).map((cat) {
            final isSelected = _category == cat['name'] as String?;
            return GestureDetector(
              onTap: () => setState(() => _category = cat['name'] as String?),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color:
                      isSelected ? cat['color'] as Color : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: cat['color'] as Color, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      cat['icon'] as IconData,
                      color: isSelected ? Colors.black : cat['color'] as Color,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      cat['name'] as String,
                      style: TextStyle(
                        color: isSelected ? Colors.black : Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
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
          style: const TextStyle(color: Colors.orangeAccent),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık
              TextField(
                controller: _titleController,
                onChanged: (_) => _generateAISuggestion(),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Başlık',
                  labelStyle: TextStyle(color: Colors.orangeAccent),
                  prefixIcon: Icon(Icons.edit, color: Colors.orangeAccent),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.orangeAccent),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children:
                    _titleSuggestions.map((s) {
                      return ActionChip(
                        backgroundColor: Colors.orange.withOpacity(0.2),
                        label: Text(
                          s,
                          style: const TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          _titleController.text = s;
                          _generateAISuggestion();
                        },
                      );
                    }).toList(),
              ),

              const SizedBox(height: 16),

              // Tutar
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Tutar',
                  labelStyle: TextStyle(color: Colors.orangeAccent),
                  prefixIcon: Icon(
                    Icons.attach_money,
                    color: Colors.orangeAccent,
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.orangeAccent),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children:
                    _quickAmounts.map((amount) {
                      return ElevatedButton(
                        onPressed:
                            () => setState(
                              () => _amountController.text = amount.toString(),
                            ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orangeAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          '$amount₺',
                          style: const TextStyle(color: Colors.black),
                        ),
                      );
                    }).toList(),
              ),

              const SizedBox(height: 20),

              // Kategori
              const Text(
                'Kategori Seçimi',
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildCategorySelector(),

              const SizedBox(height: 20),

              // AI Önerisi
              if (_suggestedCategory != null) ...[
                const SizedBox(height: 12),
                AIHintCard(
                  suggestion: _aiSuggestion as String,
                  confidence: _confidenceScore as double,
                  onAccept: () {
                    setState(() {
                      _category = _suggestedCategory!;
                      _aiSuggestion = 'Tahmin kabul edildi 🎯';
                      _suggestedCategory = null;
                    });
                  },
                  onReject: () {
                    _rejectAISuggestion(_titleController.text, _category);
                    setState(() {
                      _aiSuggestion = 'Tahmin reddedildi ❌';
                      _suggestedCategory = null;
                    });
                  },
                ),
              ],
              const SizedBox(height: 20),

              // Kaydet Butonu
              Center(
                child: ElevatedButton.icon(
                  onPressed: _saveExpense,
                  icon: const Icon(Icons.check_circle, color: Colors.black),
                  label: const Text(
                    'Kaydet',
                    style: TextStyle(color: Colors.black),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
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
}
