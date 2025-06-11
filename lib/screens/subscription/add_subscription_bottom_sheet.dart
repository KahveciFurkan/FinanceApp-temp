import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../types/type.dart';

class AddSubscriptionBottomSheet extends StatefulWidget {
  final Box<Subscription> subscriptionBox;

  const AddSubscriptionBottomSheet({super.key, required this.subscriptionBox});

  @override
  State<AddSubscriptionBottomSheet> createState() =>
      _AddSubscriptionBottomSheetState();
}

class _AddSubscriptionBottomSheetState
    extends State<AddSubscriptionBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  DateTime? _renewDate;
  String? _selectedCategory;
  int? _selectedIconCodePoint;
  int? _selectedColorValue;

  final List<Map<String, dynamic>> exampleSubscriptions = [
    {
      'name': 'Netflix',
      'price': 59.99,
      'category': 'Eğlence',
      'icon': Icons.movie,
      'color': Colors.red,
    },
    {
      'name': 'Spotify',
      'price': 29.99,
      'category': 'Müzik',
      'icon': Icons.music_note,
      'color': Colors.green,
    },

    // Faturalar ve Temel Hizmetler
    {
      'name': 'Elektrik Faturası',
      'price': 250.0,
      'category': 'Fatura',
      'icon': Icons.bolt,
      'color': Colors.yellow[700],
    },
    {
      'name': 'Su Faturası',
      'price': 85.0,
      'category': 'Fatura',
      'icon': Icons.water_drop,
      'color': Colors.blue[300],
    },
    {
      'name': 'Doğalgaz Faturası',
      'price': 320.0,
      'category': 'Fatura',
      'icon': Icons.fireplace,
      'color': Colors.orange,
    },
    {
      'name': 'İnternet Faturası',
      'price': 149.99,
      'category': 'Fatura',
      'icon': Icons.wifi,
      'color': Colors.indigo,
    },
    {
      'name': 'Mobil Fatura',
      'price': 79.99,
      'category': 'Fatura',
      'icon': Icons.phone_android,
      'color': Colors.teal,
    },

    // Diğer Düzenli Ödemeler
    {
      'name': 'Apartman Aidatı',
      'price': 400.0,
      'category': 'Kira',
      'icon': Icons.apartment,
      'color': Colors.brown,
    },
    {
      'name': 'Fitness Üyeliği',
      'price': 199.99,
      'category': 'Spor',
      'icon': Icons.fitness_center,
      'color': Colors.deepOrange,
    },
  ];

  void _fillForm(Map<String, dynamic> subscription) {
    setState(() {
      _nameController.text = subscription['name'];
      _priceController.text = subscription['price'].toString();
      _selectedCategory = subscription['category'];
      _selectedIconCodePoint = (subscription['icon'] as IconData).codePoint;
      _selectedColorValue = (subscription['color'] as Color).value;
      _renewDate = DateTime.now().add(const Duration(days: 30));
    });
  }

  void _clearForm() {
    setState(() {
      _nameController.clear();
      _priceController.clear();
      _selectedCategory = null;
      _selectedIconCodePoint = null;
      _selectedColorValue = null;
      _renewDate = null;
    });
  }

  void _save() {
    if (_formKey.currentState!.validate() && _renewDate != null) {
      final newSubscription = Subscription(
        name: _nameController.text,
        price: double.parse(_priceController.text.replaceAll(',', '.')),
        renewDate: _renewDate!,
        category: _selectedCategory ?? 'Diğer',
        iconCodePoint: _selectedIconCodePoint ?? Icons.subscriptions.codePoint,
        colorValue: _selectedColorValue ?? Colors.blue.value,
        isFrozen: false,
        isPaid: false,
        paidMonth: DateTime.now(),
        onTogglePaid: () {},
      );
      widget.subscriptionBox.add(newSubscription);
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${newSubscription.name} eklendi")),
      );
    } else if (_renewDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen yenileme tarihini seçin')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            color: Color(0xFF1C1C1E),
          ),
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.drag_handle, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text(
                    'Örnek Abonelikler',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orangeAccent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.18,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: exampleSubscriptions.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final item = exampleSubscriptions[index];
                        final selected = _nameController.text == item['name'];
                        return GestureDetector(
                          onTap: () => _fillForm(item),
                          child: Card(
                            color:
                                selected
                                    ? Colors.orangeAccent.withOpacity(0.7)
                                    : Colors.grey[850],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side:
                                  selected
                                      ? const BorderSide(
                                        color: Colors.orange,
                                        width: 2,
                                      )
                                      : BorderSide.none,
                            ),
                            child: Container(
                              width: 140,
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    item['icon'],
                                    size: 36,
                                    color: item['color'],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    item['name'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item['price']} ₺',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Abonelik Bilgileri',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orangeAccent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Abonelik Adı',
                            labelStyle: TextStyle(color: Colors.white70),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.orangeAccent,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.orangeAccent,
                              ),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          validator:
                              (val) =>
                                  val == null || val.isEmpty
                                      ? 'Ad gerekli'
                                      : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _priceController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Fiyat (₺)',
                            labelStyle: TextStyle(color: Colors.white70),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.orangeAccent,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.orangeAccent,
                              ),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          validator: (val) {
                            if (val == null || val.isEmpty)
                              return 'Fiyat gerekli';
                            final parsed = double.tryParse(
                              val.replaceAll(',', '.'),
                            );
                            return (parsed == null || parsed < 0)
                                ? 'Geçerli bir fiyat girin'
                                : null;
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _renewDate == null
                                    ? 'Yenileme tarihi seçilmedi'
                                    : 'Tarih: ${_renewDate!.day}.${_renewDate!.month}.${_renewDate!.year}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: _renewDate ?? DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                  builder:
                                      (context, child) => Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: ColorScheme.dark(
                                            primary: Colors.orangeAccent,
                                            onPrimary: Colors.black,
                                            surface: const Color(0xFF1C1C1E),
                                            onSurface: Colors.white,
                                          ),
                                          dialogBackgroundColor: const Color(
                                            0xFF1C1C1E,
                                          ),
                                        ),
                                        child: child!,
                                      ),
                                );
                                if (picked != null) {
                                  setState(() => _renewDate = picked);
                                }
                              },
                              child: const Text('Seç'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          initialValue: _selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Kategori',
                            labelStyle: TextStyle(color: Colors.white70),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.orangeAccent,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.orangeAccent,
                              ),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                          onChanged: (val) => _selectedCategory = val,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: _clearForm,
                              child: const Text(
                                'Temizle',
                                style: TextStyle(color: Colors.orangeAccent),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _save,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orangeAccent,
                              ),
                              child: const Text('Kaydet'),
                            ),
                          ],
                        ),
                      ],
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
}
