import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../types/type.dart';
import '../../widgets/subscription/subscription_calendar.dart';
import '../../widgets/subscription/subscription_card.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  late Box<Subscription> subscriptionBox;

  // Form kontrolcüleri
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  DateTime? _renewDate;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    subscriptionBox = Hive.box<Subscription>('subscriptions');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Widget _buildMonthlyTotalSummary() {
    final selectedMonth = _selectedDay.month;
    final selectedYear = _selectedDay.year;

    double total = subscriptionBox.values
        .where(
          (abone) =>
              abone.renewDate.month == selectedMonth &&
              abone.renewDate.year == selectedYear,
        )
        .fold(0.0, (sum, abone) => sum + abone.price);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 173, 52, 243).withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Aylık Toplam",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              "₺${total.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleFreezeSubscription(int index) {
    final sub = subscriptionBox.getAt(index);
    if (sub != null) {
      subscriptionBox.putAt(
        index,
        Subscription(
          key: sub.key,
          name: sub.name,
          price: sub.price,
          renewDate: sub.renewDate,
          category: sub.category,
          iconCodePoint: sub.iconCodePoint,
          colorValue: sub.colorValue,
          isFrozen: !sub.isFrozen,
          isPaid: sub.isPaid,
          paidMonth: sub.paidMonth,
          onTogglePaid: sub.onTogglePaid,
        ),
      );
    }
  }

  void _deleteSubscription(int index) {
    subscriptionBox.deleteAt(index);
  }

  void _togglePaidStatus(int index) {
    final sub = subscriptionBox.getAt(index);
    if (sub != null) {
      final now = DateTime.now();
      final isSameMonth =
          sub.paidMonth.month == now.month && sub.paidMonth.year == now.year;

      subscriptionBox.putAt(
        index,
        Subscription(
          key: sub.key,
          name: sub.name,
          price: sub.price,
          renewDate: sub.renewDate,
          category: sub.category,
          iconCodePoint: sub.iconCodePoint,
          colorValue: sub.colorValue,
          isFrozen: sub.isFrozen,
          isPaid: true,
          paidMonth: now,
          onTogglePaid: sub.onTogglePaid,
        ),
      );
    }
  }

  void _showAddSubscriptionDialog() {
    _nameController.clear();
    _priceController.clear();
    _renewDate = null;
    _selectedCategory = null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Yeni Abonelik Ekle"),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Abonelik Adı',
                        ),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Ad gerekli'
                                    : null,
                      ),
                      TextFormField(
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Fiyat (₺)',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Fiyat gerekli';
                          }
                          final parsed = double.tryParse(
                            value.replaceAll(',', '.'),
                          );
                          if (parsed == null || parsed < 0) {
                            return 'Geçerli bir fiyat girin';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _renewDate == null
                                  ? 'Yenileme Tarihi Seçin'
                                  : 'Tarih: ${_renewDate!.day}.${_renewDate!.month}.${_renewDate!.year}',
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setState(() {
                                  _renewDate = picked;
                                });
                              }
                            },
                            child: const Text('Seç'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Kategori',
                        ),
                        onChanged: (val) => _selectedCategory = val,
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Kategori gerekli'
                                    : null,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              child: const Text("İptal"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text("Ekle"),
              onPressed: () {
                if (_formKey.currentState!.validate() && _renewDate != null) {
                  final newSubscription = Subscription(
                    name: _nameController.text,
                    price: double.parse(
                      _priceController.text.replaceAll(',', '.'),
                    ),
                    renewDate: _renewDate!,
                    category: _selectedCategory ?? 'Diğer',
                    iconCodePoint: Icons.subscriptions.codePoint,
                    colorValue: Colors.blue.value,
                    isFrozen: false,
                    isPaid: false,
                    paidMonth: DateTime.now(),
                    onTogglePaid: () {},
                  );
                  subscriptionBox.add(newSubscription);
                  Navigator.of(context).pop();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${newSubscription.name} eklendi")),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Set<DateTime> markedDates =
        subscriptionBox.values
            .map(
              (sub) => DateTime(
                sub.renewDate.year,
                sub.renewDate.month,
                sub.renewDate.day,
              ),
            )
            .toSet();
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(elevation: 0, backgroundColor: Colors.transparent),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildMonthlyTotalSummary(),
                  SubscriptionCalendar(
                    selectedDay: _selectedDay,
                    focusedDay: _focusedDay,
                    markedDates:
                        markedDates, // Bu parametreyi calendar widget'ına eklemeniz lazım
                    onDaySelected: (selected, focused) {
                      setState(() {
                        _selectedDay = selected;
                        _focusedDay = focused;
                      });
                    },
                  ),
                ],
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              sliver: ValueListenableBuilder(
                valueListenable: subscriptionBox.listenable(),
                builder: (context, Box<Subscription> box, _) {
                  if (box.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Text(
                          'Henüz abonelik yok',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      // Abonelikleri liste olarak al
                      final allSubs = box.values.toList();

                      // Ödenmişler en alta gelecek şekilde sıralama yap
                      final sortedSubscriptions =
                          allSubs..sort((a, b) {
                            // Ödenmemişler (isPaid == false) yukarıda, ödenmişler aşağıda
                            if (a.isPaid && !b.isPaid) return 1;
                            if (!a.isPaid && b.isPaid) return -1;
                            return 0;
                          });

                      final abone = sortedSubscriptions[index];

                      return SubscriptionCard(
                        sub: abone,
                        onFreeze: () {
                          final originalIndex = box.values.toList().indexOf(
                            abone,
                          );
                          _toggleFreezeSubscription(originalIndex);
                          final updatedAbone = box.getAt(originalIndex)!;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                updatedAbone.isFrozen
                                    ? "${updatedAbone.name} donduruldu"
                                    : "${updatedAbone.name} tekrar aktif",
                              ),
                            ),
                          );
                        },
                        onDelete: () {
                          final originalIndex = box.values.toList().indexOf(
                            abone,
                          );
                          final deletedName = abone.name;
                          _deleteSubscription(originalIndex);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("$deletedName silindi")),
                          );
                        },
                        onTogglePaid: () {
                          final originalIndex = box.values.toList().indexOf(
                            abone,
                          );
                          _togglePaidStatus(originalIndex);
                          final updatedAbone = box.getAt(originalIndex)!;

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                updatedAbone.isPaid
                                    ? "${updatedAbone.name} bu ay ödendi"
                                    : "${updatedAbone.name} ödeme kaldırıldı",
                              ),
                            ),
                          );
                        },
                      );
                    }, childCount: box.length),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSubscriptionDialog,
        child: const Icon(Icons.add),
        tooltip: 'Yeni Abonelik Ekle',
      ),
    );
  }
}
