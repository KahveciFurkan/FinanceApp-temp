import 'package:ff/utils/helper/helperfunctions.dart';
import 'package:flutter/material.dart';
import '../types/type.dart';
import '../widgets/add_transaction_bottom_sheet.dart';
import 'package:hive/hive.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  List<SavingsTransaction> transactions = [];
  List<SavingsTransaction> _filteredTransactions = [];

  List<String> _months = [
    'Tümü',
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];
  late String _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = _months[now.month];
    _loadTransactions();
  }

  Future<void> _addTransaction(SavingsTransaction newTx) async {
  final box = Hive.box<SavingsTransaction>('transactionsBox');

  final totals = _calculateTotals(transactions);
  // Aynı normalize işlemi burada da olmalı:
  String currencyKey;
  switch (newTx.currency.toLowerCase()) {
    case 'usd':
    case 'dolar':
      currencyKey = 'Dolar';
      break;
    case 'eur':
    case 'euro':
      currencyKey = 'Euro';
      break;
    case 'altın':
    case 'altin':
      currencyKey = 'Altın';
      break;
    case 'gümüş':
    case 'gumus':
      currencyKey = 'Gümüş';
      break;
    default:
      currencyKey = newTx.currency; // bilinmeyen
  }

  final currentAmount = totals[currencyKey] ?? 0;

  if (newTx.type == 'Çekme' && newTx.amount > currentAmount) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Yetersiz bakiye!'),
        backgroundColor: Colors.redAccent,
      ),
    );
    return;
  }

  await box.add(newTx);
  await _loadTransactions();
}

  Map<String, double> _calculateTotals(List<SavingsTransaction> transactions) {
  Map<String, double> totals = {
    'Dolar': 0.0,
    'Euro': 0.0,
    'Altın': 0.0,
    'Gümüş': 0.0,
  };

  for (var tx in transactions) {
    // currency normalize et
    String currencyKey;
    switch (tx.currency.toLowerCase()) {
      case 'usd':
      case 'dolar':
        currencyKey = 'Dolar';
        break;
      case 'eur':
      case 'euro':
        currencyKey = 'Euro';
        break;
      case 'altın':
      case 'altin':
        currencyKey = 'Altın';
        break;
      case 'gümüş':
      case 'gumus':
        currencyKey = 'Gümüş';
        break;
      default:
        continue; // diğer para birimlerini yoksay
    }

    if (tx.type == 'Ekleme') {
      totals[currencyKey] = totals[currencyKey]! + tx.amount;
    } else if (tx.type == 'Çekme') {
      totals[currencyKey] = totals[currencyKey]! - tx.amount;
    }
  }
  return totals;
}


  Future<void> _loadTransactions() async {
  final box = Hive.box<SavingsTransaction>('transactionsBox');
  setState(() {
    transactions = box.values.toList().cast<SavingsTransaction>();
    _filterTransactions();
  });
}


  void _filterTransactions() {
    setState(() {
      if (_selectedMonth == 'Tümü') {
        _filteredTransactions = List.from(transactions);
      } else {
        _filteredTransactions =
            transactions.where((tx) {
              final txMonth = _months[tx.date.month];
              return txMonth == _selectedMonth;
            }).toList();
      }
    });
  }

  void _deleteTransaction(SavingsTransaction tx) {
    final box = Hive.box<SavingsTransaction>('transactionsBox');
    final keyToDelete = box.keys.firstWhere(
      (key) => box.get(key) == tx,
      orElse: () => null,
    );
    if (keyToDelete != null) {
      box.delete(keyToDelete);
      _loadTransactions();
    }
  }

  void _showAddTransactionSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return AddTransactionBottomSheet(onSave: _addTransaction);
      },
    );
  }

  Widget _buildSummary(Map<String, double> totals) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8),
    child: Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _buildSummaryCard('Dolar', totals['Dolar'] ?? 0, Icons.attach_money),
        _buildSummaryCard('Euro', totals['Euro'] ?? 0, Icons.euro),
        _buildSummaryCard('Altın', totals['Altın'] ?? 0, Icons.currency_bitcoin),
        _buildSummaryCard('Gümüş', totals['Gümüş'] ?? 0, Icons.diamond),
      ],
    ),
  );
}

  Widget _buildSummaryCard(String label, double amount, IconData icon) {
    return Container(
      width: (MediaQuery.of(context).size.width - 30) / 2,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.orangeAccent, size: 22),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            formatAmount(amount),
            style: const TextStyle(
              color: Colors.orangeAccent,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totals = _calculateTotals(transactions);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detaylar'),
        backgroundColor: const Color(0xFF1C1C1E),
        titleTextStyle: const TextStyle(
          color: Colors.orangeAccent,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        iconTheme: const IconThemeData(color: Colors.orangeAccent),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Column(
          children: [
            // Summary alanını ekran yüksekliğinin %20'si kadar yapalım
            SizedBox(height: screenHeight * 0.20, child: _buildSummary(totals)),
            // Dropdown ve padding
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: DropdownButton<String>(
                value: _selectedMonth,
                dropdownColor: const Color(0xFF1C1C1E),
                style: const TextStyle(color: Colors.white),
                isExpanded: true,
                items:
                    _months
                        .map(
                          (month) => DropdownMenuItem(
                            value: month,
                            child: Text(month),
                          ),
                        )
                        .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedMonth = val!;
                    _filterTransactions();
                  });
                },
              ),
            ),
            // Liste alanı, ekranın geri kalanını kaplasın
            Expanded(
              child:
                  _filteredTransactions.isEmpty
                      ? const Center(
                        child: Text(
                          'Henüz işlem yok',
                          style: TextStyle(color: Colors.grey, fontSize: 18),
                        ),
                      )
                      : ListView.builder(
                        itemCount: _filteredTransactions.length,
                        itemBuilder: (ctx, index) {
                          final tx = _filteredTransactions[index];
                          return Dismissible(
                            key: Key(tx.date.toString()),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (direction) {
                              _deleteTransaction(tx);
                            },
                            child: ListTile(
                              title: Text(
                                tx.title,
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                '${tx.date.day}.${tx.date.month}.${tx.date.year}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              trailing: Text(
                                '${tx.type == 'Ekleme' ? '+' : '-'}${formatAmount(tx.amount)} ${tx.currency == 'Altın' ? 'gram' : tx.currency}',
                                style: TextStyle(
                                  color:
                                      tx.type == 'Ekleme'
                                          ? Colors.greenAccent
                                          : Colors.redAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orangeAccent,
        onPressed: _showAddTransactionSheet,
        child: const Icon(Icons.add),
      ),
    );
  }
}
