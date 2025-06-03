import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../types/type.dart';
import 'package:wake_on_lan/wake_on_lan.dart';
import '../utils/helper/helperfunctions.dart';
import '../widgets/expensefab/expensefab.dart';
import 'expenses/add_expense_screen.dart';
import 'package:http/http.dart' as http;
import 'expenses/expense_adapter.dart'; // Expense modelinin olduğu dosya (varsayılan import)

// Öncelikle Expense modelin Hive uyumlu olmalı (TypeAdapter ile) -> Bunu sağlamalısın.
// Burada varsayıyorum zaten adapter kayıtlı.

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<int, List<Expense>> yearlyExpenses = {};
  int selectedYear = DateTime.now().year;
  int selectedMonthIndex = -1;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initHiveAndLoad();
  }

  Future<void> initHiveAndLoad() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(
        ExpenseAdapter(),
      ); // Expense adapter id 0 olduğunu varsayıyorum
    }
    await Hive.openBox<Expense>('expenses');
    await loadAllYears();
  }

  Future<void> sleepPc() async {
    final url = Uri.parse('http://192.168.1.5:5000/pc/sleep');
    await http.post(url);
  }

  bool isPcOn = false;

  // WakeOnLan fonksiyonunu çağır
  Future<void> wakePc() async {
    String ipv4 = '192.168.1.255';
    String mac = '2C:F0:5D:6E:A6:25';
    IPAddress ipv4Address = IPAddress(ipv4);
    MACAddress macAddress = MACAddress(mac);
    await WakeOnLAN(ipv4Address, macAddress).wake();

    // 10 saniye sonra kapalıya çekelim örnek için (test amaçlı)
    Future.delayed(const Duration(seconds: 10), () {
      setState(() {
        isPcOn = false;
      });
    });
  }

  Future<void> loadAllYears() async {
    int currentYear = DateTime.now().year;
    final yearsToLoad = [currentYear - 2, currentYear - 1, currentYear];
    Map<int, List<Expense>> temp = {};
    for (var year in yearsToLoad) {
      temp[year] = await loadYearExpenses(year);
    }
    setState(() {
      yearlyExpenses = temp;
      isLoading = false;
    });
  }

  Future<List<Expense>> loadYearExpenses(int year) async {
    final box = Hive.box<Expense>('expenses');
    // Tüm expense'leri al ve sadece seçili yıla ait olanları filtrele
    final allExpenses = box.values.toList();
    final filtered = allExpenses.where((e) => e.date.year == year).toList();
    return filtered;
  }

  List<int> get currentYearExpenses {
    List<Expense> expenses = yearlyExpenses[selectedYear] ?? [];
    List<int> monthTotals = List.filled(12, 0);
    for (var expense in expenses) {
      int month = expense.date.month - 1; // Ay 1-12 arası, index için -1
      int amount =
          expense.amount.toInt(); // double ise int'e çeviriyoruz (gerekirse)
      if (month >= 0 && month < 12) {
        monthTotals[month] += amount;
      }
    }
    return monthTotals;
  }

  int get totalYearlyExpense {
    return currentYearExpenses.fold(0, (sum, amount) => sum + amount);
  }

  // Örnek olarak, aşağıda buildYearDropdown() fonksiyonunda ufak güncelleme:
  Widget buildYearDropdown() {
    final years = yearlyExpenses.keys.toList()..sort();

    return DropdownButton<int>(
      dropdownColor: const Color(0xFF2C2C2E),
      value: selectedYear,
      items:
          years
              .map(
                (year) => DropdownMenuItem<int>(
                  value: year,
                  child: Text(
                    year.toString(),
                    style: const TextStyle(color: Colors.orangeAccent),
                  ),
                ),
              )
              .toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            selectedYear = value;
            selectedMonthIndex = -1;
          });
        }
      },
    );
  }

  // Diğer widgetlar aynı şekilde kalabilir, çünkü monthly ve yearly expenses
  // hesaplama kısmını yukarıda hallettik.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        title: const Text(
          'Harcama Takip',
          style: TextStyle(
            color: Colors.orangeAccent,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF2C2C2E),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.admin_panel_settings,
              color: Colors.orangeAccent,
            ),
            onPressed: showAdminPasswordDialog,
          ),
          IconButton(
            icon: Icon(
              Icons.computer,
              color:
                  isPcOn
                      ? Colors.greenAccent
                      : Colors.greenAccent.withOpacity(0.5),
            ),
            onPressed: wakePc,
          ),
          IconButton(
            icon: const Icon(
              Icons
                  .bedtime, // Uyku moduna uygun bir ikon (yoksa başka ikon da kullanabilirsin)
              color: Colors.blueAccent,
            ),
            onPressed: sleepPc, // Uyku fonksiyonunu burada çağıracağız
          ),
        ],
      ),
      floatingActionButton: ExpenseFAB(onPressed: openAddExpenseScreen),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    buildYearDropdown(),
                    const SizedBox(height: 12),
                    buildBarChart(),
                    const SizedBox(height: 20),
                    buildTotalExpenseText(),
                  ],
                ),
              ),
    );
  }

  void showAdminPasswordDialog() {
    // Mevcut kodun aynen kalabilir
  }

  void openAddExpenseScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
    );
    await loadAllYears(); // Geri dönüldüğünde listeyi yenile
  }

  Widget buildBarChart() {
    // Mevcut kodun aynen kalabilir
    final currentExpenses = currentYearExpenses;
    if (currentExpenses.isEmpty) return const SizedBox();

    final maxExpense = currentExpenses.reduce((a, b) => a > b ? a : b);
    final Map<String, String> monthMap = {
      'Oca': 'Ocak',
      'Şub': 'Şubat',
      'Mar': 'Mart',
      'Nis': 'Nisan',
      'May': 'Mayıs',
      'Haz': 'Haziran',
      'Tem': 'Temmuz',
      'Ağu': 'Ağustos',
      'Eyl': 'Eylül',
      'Eki': 'Ekim',
      'Kas': 'Kasım',
      'Ara': 'Aralık',
    };
    final List<String> monthKeys = monthMap.keys.toList();
    return SizedBox(
      height: 180,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;
          final barWidth = (availableWidth / 15).clamp(12, 30).toDouble();

          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(12, (index) {
              final currentExpense = currentExpenses[index];
              final height =
                  currentExpense == 0
                      ? 10.0
                      : (maxExpense == 0
                          ? 0.0
                          : (currentExpense / maxExpense) * 150);
              final isSelected = selectedMonthIndex == index;

              return GestureDetector(
                onTap: () {
                  setState(() => selectedMonthIndex = index);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${monthMap[monthKeys[index]] ?? ''} Ayı Harcama Toplamı: $currentExpense ₺',
                        style: const TextStyle(color: Colors.black87),
                      ),
                      backgroundColor: Colors.orangeAccent,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: barWidth,
                      height: height,
                      decoration: BoxDecoration(
                        color:
                            isSelected ? Colors.orangeAccent : Colors.grey[700],
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      monthKeys[index], // burada uzun ay ismini gösteriyoruz
                      style: const TextStyle(color: Colors.orangeAccent),
                    ),
                  ],
                ),
              );
            }),
          );
        },
      ),
    );
  }

  Widget buildTotalExpenseText() {
    return Text(
      'Toplam Gider: $totalYearlyExpense ₺',
      style: const TextStyle(
        color: Colors.orangeAccent,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
