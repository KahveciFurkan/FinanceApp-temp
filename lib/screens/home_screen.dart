import 'package:flutter/material.dart';
import '../widgets/navbar.dart';
import 'savings_screen.dart';
// import 'finance_assistant_screen.dart';
import 'admin_screen.dart';
import '../routes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String activeTab = 'Home';

  // artık kategorili harcama listesini tutuyoruz:
  Map<int, List<Map<String, dynamic>>> yearlyExpenses = {};

  int selectedYear = DateTime.now().year;
  int selectedMonthIndex = -1;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAllYears();
  }

  String activeScreen = 'Home';

  // Ekranı değiştiren fonksiyon
  void setActive(String screen) {
    setState(() {
      activeScreen = screen;
    });
  }

  // Ekranlar arası navigasyonu yapan fonksiyon (örnek)
  void navigate(String screen) {
    // Burada ekran değişimine göre sayfa yönlendirmesi yapabilirsin
    // Örnek:
    if (screen == 'Home') {
      // Zaten buradayız
    } else if (screen == 'Savings') {
      Navigator.pushNamed(context, '/savings');
    } 
  }

  Future<void> loadAllYears() async {
    int currentYear = DateTime.now().year;
    final yearsToLoad = [currentYear - 2, currentYear - 1, currentYear];
    Map<int, List<Map<String, dynamic>>> temp = {};
    for (var year in yearsToLoad) {
      temp[year] = await loadYearExpenses(year);
    }
    setState(() {
      yearlyExpenses = temp;
      isLoading = false;
    });
  }

  Future<List<Map<String, dynamic>>> loadYearExpenses(int year) async {
  final prefs = await SharedPreferences.getInstance();
  final jsonString = prefs.getString('expenses_$year');
  if (jsonString == null) return [];
  final List<dynamic> jsonList = jsonDecode(jsonString);
  try {
    return jsonList.map<Map<String, dynamic>>((e) {
      if (e is Map) {
        return Map<String, dynamic>.from(e);
      } else {
        // Eğer e map değilse boş map dön
        return {};
      }
    }).toList();
  } catch (e) {
    return [];
  }
}



  Future<void> saveYearExpenses(int year, List<Map<String, dynamic>> expenses) async {
  final prefs = await SharedPreferences.getInstance();
  final jsonString = jsonEncode(expenses);
  await prefs.setString('expenses_$year', jsonString);
}

  // Kategori bazlı harcama ekleme fonksiyonu
  Future<void> addExpenseWithCategory(int year, int monthIndex, int amount, String category) async {
  List<Map<String, dynamic>> expenses = yearlyExpenses[year] ?? [];
  expenses.add({
    'month': monthIndex,
    'amount': amount,
    'category': category,
  });
  await saveYearExpenses(year, expenses);
  setState(() {
    yearlyExpenses[year] = expenses;
    selectedYear = year;
    selectedMonthIndex = monthIndex;
  });
}

  // Şimdi aylık toplam harcamaları kategoriye bakmadan hesaplayan fonksiyon
  List<int> get currentYearExpenses {
    List<Map<String, dynamic>> expenses = yearlyExpenses[selectedYear] ?? [];
    List<int> monthTotals = List.filled(12, 0);
    for (var expense in expenses) {
      int month = expense['month'] ?? 0;
      int amount = expense['amount'] ?? 0;
      if (month >= 0 && month < 12) {
        monthTotals[month] += amount;
      }
    }
    return monthTotals;
  }

  int get totalExpense => currentYearExpenses.fold(0, (sum, item) => sum + item);

  void showAdminPasswordDialog() {
    final _passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2E),
          title: const Text('Admin Girişi', style: TextStyle(color: Colors.orangeAccent)),
          content: TextField(
            controller: _passwordController,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Şifre',
              labelStyle: TextStyle(color: Colors.orangeAccent),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.orangeAccent),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.orangeAccent),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('İptal', style: TextStyle(color: Colors.orangeAccent)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
              onPressed: () {
                final password = _passwordController.text.trim();
                const adminPassword = '1234'; // İstersen burayı değiştir

                if (password == adminPassword) {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AdminScreen()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Hatalı şifre'), backgroundColor: Colors.redAccent),
                  );
                }
              },
              child: const Text('Giriş'),
            ),
          ],
        );
      },
    );
  }

  List<String> categories = ['Yiyecek', 'Ulaşım', 'Eğlence', 'Fatura', 'Diğer'];

  void showAddExpenseDialog() {
    final _amountController = TextEditingController();
    int tempMonth = DateTime.now().month - 1;
    int tempYear = selectedYear;
    String tempCategory = categories[0];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF2C2C2E),
              title: const Text('Harcama Ekle', style: TextStyle(color: Colors.orangeAccent)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<int>(
                    dropdownColor: const Color(0xFF2C2C2E),
                    value: tempYear,
                    items: yearlyExpenses.keys.map((year) {
                      return DropdownMenuItem<int>(
                        value: year,
                        child: Text(year.toString(), style: const TextStyle(color: Colors.orangeAccent)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          tempYear = val;
                        });
                      }
                    },
                  ),
                  DropdownButton<int>(
                    dropdownColor: const Color(0xFF2C2C2E),
                    value: tempMonth,
                    items: List.generate(12, (i) => i)
                        .map((m) => DropdownMenuItem<int>(
                              value: m,
                              child: Text('${m + 1}. Ay', style: const TextStyle(color: Colors.orangeAccent)),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          tempMonth = val;
                        });
                      }
                    },
                  ),
                  DropdownButton<String>(
                    dropdownColor: const Color(0xFF2C2C2E),
                    value: tempCategory,
                    items: categories.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat,
                        child: Text(cat, style: const TextStyle(color: Colors.orangeAccent)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          tempCategory = val;
                        });
                      }
                    },
                  ),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Tutar (₺)',
                      labelStyle: TextStyle(color: Colors.orangeAccent),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.orangeAccent),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.orangeAccent),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('İptal', style: TextStyle(color: Colors.orangeAccent)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
                  onPressed: () {
                    final amount = int.tryParse(_amountController.text);
                    if (amount == null || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Geçerli bir tutar giriniz'), backgroundColor: Colors.redAccent),
                      );
                      return;
                    }
                    addExpenseWithCategory(tempYear, tempMonth, amount, tempCategory);
                    Navigator.pop(context);
                  },
                  child: const Text('Ekle'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget buildYearDropdown() {
    final years = yearlyExpenses.keys.toList()..sort();

    return DropdownButton<int>(
      dropdownColor: const Color(0xFF2C2C2E),
      value: selectedYear,
      items: years
          .map((year) => DropdownMenuItem<int>(
                value: year,
                child: Text(
                  year.toString(),
                  style: const TextStyle(color: Colors.orangeAccent),
                ),
              ))
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

  Widget buildBarChart() {
  final currentExpenses = currentYearExpenses;
  if (currentExpenses.isEmpty) return const SizedBox();

  final maxExpense = currentExpenses.reduce((a, b) => a > b ? a : b);
  final barWidth = 20.0;
  final List<String> monthNames = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];

  return SizedBox(
    height: 180,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(12, (index) {
        final height = maxExpense == 0 ? 0.0 : (currentExpenses[index] / maxExpense) * 150;
        final isSelected = selectedMonthIndex == index;

        return GestureDetector(
          onTap: () {
  setState(() {
    selectedMonthIndex = index;
  });
  final snackBar = SnackBar(
    content: Text(
      '${monthNames[index]} ayı gideri: ${currentExpenses[index]} ₺',
      style: const TextStyle(color: Colors.black87), // Koyu renk
    ),
    backgroundColor: Colors.orangeAccent,
    duration: const Duration(seconds: 2),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
},
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: barWidth,
                height: height,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.orangeAccent : Colors.grey[700],
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(height: 6),
              Text(monthNames[index], style: const TextStyle(color: Colors.orangeAccent)),
              // Tutarlari kaldırdık, o yüzden burayı çıkardık
            ],
          ),
        );
      }),
    ),
  );
}



 @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFF1C1C1E),
    appBar: AppBar(
      title: const Text('Gider Takip'),
      backgroundColor: const Color(0xFF2C2C2E),
      actions: [
        IconButton(
          icon: const Icon(Icons.admin_panel_settings, color: Colors.orangeAccent),
          onPressed: showAdminPasswordDialog,
        ),
      ],
    ),
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                buildYearDropdown(),
                const SizedBox(height: 12),
                buildBarChart(),
                const SizedBox(height: 12),
                Text(
                  'Toplam Gider: $totalExpense ₺',
                  style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                // Burada yeni butonumuz:
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      shadowColor: Colors.black54,
                      elevation: 8,
                    ),
                    onPressed: showAddExpenseDialog,
                    child: const Text(
                      'Harcama Ekle',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                
              ],
            ),
          ),
    bottomNavigationBar: BottomNavBar(
      active: activeScreen,
      setActive: setActive,
      navigate: navigate,
    ),
    // floatingActionButton: kaldırıldı
  );
}



}
