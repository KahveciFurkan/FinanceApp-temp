import '../types/type.dart';

double getMonthlyTotal(List<Expense> expenses, DateTime now) {
  return expenses
      .where((e) => e.date.year == now.year && e.date.month == now.month)
      .fold(0.0, (sum, e) => sum + e.amount);
}

String? getTopSpendingCategory(List<Expense> expenses, DateTime now) {
  final categoryTotals = <String, double>{};
  for (var e in expenses) {
    if (e.date.year == now.year && e.date.month == now.month) {
      categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
    }
  }
  if (categoryTotals.isEmpty) return null;
  final highest = categoryTotals.entries.reduce(
    (a, b) => a.value > b.value ? a : b,
  );
  return "En çok harcama ${highest.key} kategorisinde: ${highest.value.toStringAsFixed(2)}₺.";
}

String getCategorySummary(List<Expense> expenses, DateTime now) {
  final categoryTotals = <String, double>{};
  for (var e in expenses) {
    if (e.date.year == now.year && e.date.month == now.month) {
      categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
    }
  }
  if (categoryTotals.isEmpty) return "Bu ay harcama bulunamadı.";
  final buffer = StringBuffer();
  buffer.writeln("Kategori bazlı harcama özetin:");
  categoryTotals.forEach((key, value) {
    buffer.writeln("- $key: ${value.toStringAsFixed(2)}₺");
  });
  return buffer.toString();
}

double getLast7DaysTotal(List<Expense> expenses) {
  final now = DateTime.now();
  final sevenDaysAgo = now.subtract(const Duration(days: 7));
  return expenses
      .where((e) => e.date.isAfter(sevenDaysAgo))
      .fold(0.0, (sum, e) => sum + e.amount);
}
