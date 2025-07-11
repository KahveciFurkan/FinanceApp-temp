import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../helpers/suggestion_logic.dart';
import '../types/type.dart';
import 'package:wake_on_lan/wake_on_lan.dart';
import '../utils/helper/helperfunctions.dart';
import '../widgets/expensefab/expensefab.dart';
import '../widgets/expensefab/recent_expense_card.dart';
import 'assistant/voice_methods.dart';
import 'expenses/add_expense_screen.dart';
import 'package:http/http.dart' as http;
import 'expenses/expense_adapter.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Renk koyulaştırma fonksiyonu
Color darkenColor(Color color, [double amount = .2]) {
  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
  return hslDark.toColor();
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static final GlobalKey<_HomeScreenState> globalKey =
      GlobalKey<_HomeScreenState>();
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final SuggestionService _suggester;
  late stt.SpeechToText _speech;
  bool _listening = false;

  int _pressedIndex = -1;
  Map<int, List<Expense>> yearlyExpenses = {};
  int selectedYear = DateTime.now().year;
  int selectedMonthIndex = -1;
  bool isLoading = true;
  bool isPcOn = false;
  static const _monthMap = {
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
  static final _monthKeys = _monthMap.keys.toList();
  @override
  void initState() {
    super.initState();
    // Örnek kategori bütçeleri; istersen kullanıcı ayarından oku
    _suggester = SuggestionService({
      'Yemek': 2000.0,
      'Ulaşım': 1000.0,
      'Eğlence': 1500.0,
    });
    initHiveAndLoad();
    _initSpeech();
  }

  void _initSpeech() async {
    _speech = stt.SpeechToText();
    final available = await _speech.initialize();
    if (!available) return;

    setState(() => _listening = true);
    _speech.listen(
      onResult: (res) {
        if (res.finalResult) {
          _processCommand(res.recognizedWords.toLowerCase());
        }
      },
      listenFor: const Duration(seconds: 10),
      localeId: 'tr_TR',
      cancelOnError: true,
    );
    Future.delayed(const Duration(seconds: 10), () {
      _speech.stop();
      setState(() => _listening = false);
    });
  }

  void _processCommand(String cmd) {
    VoiceMethods.handleCommand(cmd, context);
  }

  Future<void> initHiveAndLoad() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ExpenseAdapter());
    }
    await Hive.openBox<Expense>('expenses');
    await loadAllYears();
  }

  Future<void> sleepPc() async {
    final url = Uri.parse('http://192.168.1.5:5000/pc/sleep');
    await http.post(url);
  }

  Future<void> wakePc() async {
    String ipv4 = ipv4Add;
    String mac = macAddres;
    IPAddress ipv4Address = IPAddress(ipv4);
    MACAddress macAddress = MACAddress(mac);
    await WakeOnLAN(ipv4Address, macAddress).wake();
    Future.delayed(const Duration(seconds: 10), () {
      setState(() => isPcOn = false);
    });
  }

  Future<void> loadAllYears() async {
    final currentYear = DateTime.now().year;
    final yearsToLoad = [currentYear - 2, currentYear - 1, currentYear];
    final temp = <int, List<Expense>>{};
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
    final all = box.values.toList();
    return all.where((e) => e.date.year == year).toList();
  }

  List<int> get currentYearExpenses {
    final expenses = yearlyExpenses[selectedYear] ?? [];
    final totals = List<int>.filled(12, 0);
    for (var e in expenses) {
      final m = e.date.month - 1;
      if (m >= 0 && m < 12) totals[m] += e.amount.toInt();
    }
    return totals;
  }

  int get totalYearlyExpense =>
      currentYearExpenses.fold(0, (sum, v) => sum + v);

  /// O ayın toplam giderini hesaplar
  double _getMonthlyTotal(DateTime date) {
    final all = Hive.box<Expense>('expenses').values;
    return all
        .where((e) => e.date.year == date.year && e.date.month == date.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  /// Son 3 harcamayı alıp en yüksek yüzdeli olandan başlatır
  Widget buildRecentExpenseCards() {
    final allExpenses =
        Hive.box<Expense>('expenses').values.toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    final lastThree = allExpenses.take(3).toList();

    if (lastThree.isEmpty) return const SizedBox();

    // Yüzdelere göre sırala
    lastThree.sort((a, b) {
      final ta = _getMonthlyTotal(a.date);
      final tb = _getMonthlyTotal(b.date);
      final pa = ta > 0 ? a.amount / ta : 0.0;
      final pb = tb > 0 ? b.amount / tb : 0.0;
      return pb.compareTo(pa);
    });

    return SizedBox(
      height: 260,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemCount: lastThree.length,
        itemBuilder: (ctx, i) {
          final e = lastThree[i];
          final monthlyTotal = _getMonthlyTotal(e.date);
          final suggestion = _suggester.getSuggestion(e, allExpenses);

          return RecentExpenseCard(
            e: e,
            monthlyCategoryTotal: monthlyTotal,
            suggestion: suggestion,
          );
        },
      ),
    );
  }

  Widget buildYearDropdown() {
    final years = yearlyExpenses.keys.toList()..sort();
    return DropdownButton<int>(
      dropdownColor: const Color(0xFF2C2C2E),
      value: selectedYear,
      items:
          years
              .map(
                (y) => DropdownMenuItem(
                  value: y,
                  child: Text(
                    y.toString(),
                    style: const TextStyle(color: Colors.orangeAccent),
                  ),
                ),
              )
              .toList(),
      onChanged: (v) {
        if (v != null) {
          setState(() {
            selectedYear = v;
            selectedMonthIndex = -1;
          });
        }
      },
    );
  }

  Widget buildBarChart() {
    final data = currentYearExpenses;
    if (data.isEmpty) return const SizedBox();
    final maxV = data.reduce(max);
    const monthMap = {
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
    final keys = monthMap.keys.toList();

    return SizedBox(
      height: 180,
      child: LayoutBuilder(
        builder: (ctx, cons) {
          final bw = (cons.maxWidth / 15).clamp(12, 30).toDouble();
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(12, (i) {
              final val = data[i];
              final h =
                  val == 0
                      ? 10.0
                      : maxV == 0
                      ? 0.0
                      : (val / maxV) * 150;
              final selected = selectedMonthIndex == i;
              return GestureDetector(
                onTap: () {
                  setState(() => selectedMonthIndex = i);
                  _showMonthDetail(i);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: bw,
                  height: h,
                  decoration: BoxDecoration(
                    color: selected ? Colors.orangeAccent : Colors.grey[700],
                    borderRadius: BorderRadius.circular(4),
                  ),
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
      'Toplam Gider: ${formatAmount(double.parse(totalYearlyExpense.toString()))} ₺',
      style: const TextStyle(
        color: Color.fromARGB(255, 244, 248, 237),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  void _showMonthDetail(int monthIndex) {
    final total = currentYearExpenses[monthIndex];
    final expenses =
        yearlyExpenses[selectedYear]
            ?.where((e) => e.date.month == monthIndex + 1)
            .toList() ??
        [];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color.fromARGB(
        0,
        159,
        238,
        11,
      ), // artık transparan değil
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (_) => DraggableScrollableSheet(
            initialChildSize: 0.5,
            maxChildSize: 0.85,
            minChildSize: 0.3,
            expand: false,
            builder:
                (_, controller) => Container(
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 61, 60, 60),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Text(
                        '${_monthMap[_monthKeys[monthIndex]]}  $total ₺',
                        style: const TextStyle(
                          color: Colors.orangeAccent,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child:
                            expenses.isEmpty
                                ? const Center(
                                  child: Text(
                                    'Bu ay için harcama bulunamadı.',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                )
                                : ListView.separated(
                                  controller: controller,
                                  itemCount: expenses.length,
                                  separatorBuilder:
                                      (_, __) =>
                                          const Divider(color: Colors.grey),
                                  itemBuilder: (_, i) {
                                    final e = expenses[i];
                                    return ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.orangeAccent,
                                        child: Text(
                                          DateFormat('d').format(e.date),
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        e.category,
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      subtitle: Text(
                                        DateFormat(
                                          'dd MMM yyyy, HH:mm',
                                        ).format(e.date),
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                      trailing: Text(
                                        '${e.amount.toStringAsFixed(2)} ₺',
                                        style: const TextStyle(
                                          color: Colors.orangeAccent,
                                          fontWeight: FontWeight.bold,
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
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C2C2E),
        title: Text(
          'Harcama Takip',
          style: GoogleFonts.gochiHand(
            color: Colors.orangeAccent,
            fontWeight: FontWeight.bold,
            fontSize: 24, // dilediğin boyutu ayarlayabilirsin
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.admin_panel_settings,
              color: Colors.orangeAccent,
            ),
            onPressed: showAdminPasswordDialog,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              _listening ? Icons.mic : Icons.mic_none,
              color: _listening ? Colors.redAccent : Colors.white70,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.computer,
              color:
                  isPcOn
                      ? Colors.greenAccent
                      : Colors.greenAccent.withOpacity(.5),
            ),
            onPressed: wakePc,
          ),
          IconButton(
            icon: const Icon(Icons.bedtime, color: Colors.blueAccent),
            onPressed: sleepPc,
          ),
        ],
      ),
      floatingActionButton: ExpenseFAB(onPressed: openAddExpenseScreen),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    buildYearDropdown(),
                    const SizedBox(height: 12),
                    buildBarChart(),
                    const SizedBox(height: 20),
                    buildTotalExpenseText(),
                    const SizedBox(height: 20),
                    buildRecentExpenseCards(),
                  ],
                ),
              ),
    );
  }

  void showAdminPasswordDialog() {
    // Aynen kalabilir
  }

  void openAddExpenseScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
    );
    await loadAllYears();
  }
}
