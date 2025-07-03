import 'dart:math';
import 'package:flutter/material.dart';
import '../types/type.dart';

/// Expense list extension for common aggregations.
extension ExpenseListExt on List<Expense> {
  /// Returns total amount for [category] between [start] and [end] inclusive.
  double total({
    required String category,
    required DateTime start,
    required DateTime end,
  }) {
    return where(
      (e) =>
          e.category == category &&
          !e.date.isBefore(start) &&
          !e.date.isAfter(end),
    ).fold(0.0, (sum, e) => sum + e.amount);
  }

  /// Total for this month.
  double totalThisMonth(String category, DateTime now) {
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(
      now.year,
      now.month + 1,
      1,
    ).subtract(const Duration(seconds: 1));
    return total(category: category, start: start, end: end);
  }

  /// Total for last 7 days (including today).
  double totalLast7Days(String category, DateTime now) {
    final start = now.subtract(const Duration(days: 6));
    return total(category: category, start: start, end: now);
  }
}

/// Holds aggregated usage data for a category.
class CategoryUsage {
  final String category;
  final double totalSpent;
  final double budget;
  final double percentOfBudget;
  final List<Expense> details;

  CategoryUsage({
    required this.category,
    required this.totalSpent,
    required this.budget,
    required this.percentOfBudget,
    required this.details,
  });
}

/// Service for generating suggestions based on expenses.
class SuggestionService {
  final Map<String, double> categoryBudgets;
  final Random _rand;

  /// Message templates with placeholders.
  static const Map<String, String> _templates = {
    'overBudget': '⚠️ Bütçeni aştın! Toplam %{percent}%',
    'forecast': 'Projeksiyon: Ay sonunda ₺%{projected} harcarsın.',
    'forecastWarn':
        'Bu hızla devam edersen ay sonunda ₺%{projected} harcarsın.',
    'compare': 'Geçen ay ort. ₺%{prevAvg}, bu ay günde ₺%{currentAvg}.',
    'trend': 'Son 7 gün: ₺%{thisWeek}, değişim %{weekChange}%.',
    'busiest': 'En yoğun gün %{dayName} (%{dayPercent}%).',
    'recurring': 'Tekrarlayan gider var, bir sonraki kesintiyi kontrol et.',
    'positive': 'Bu hızla ₺%{savings} tasarruf edebilirsin!',
    'tip': '%{tip}',
  };

  /// [seed] sayesinde testlerde deterministik sonuç alınabilir.
  SuggestionService(this.categoryBudgets, {int? seed})
    : _rand = seed != null ? Random(seed) : Random();

  /// Generates suggestion string for expense [e], using [allExpenses] list.
  String getSuggestion(
    Expense e,
    List<Expense> allExpenses, {
    DateTime? forDate,
  }) {
    final category = e.category;
    final now = forDate ?? DateTime.now();
    final budget = categoryBudgets[category] ?? 0.0;

    // 1. Bu ay toplam harcama ve yüzde
    final monthlyTotal = allExpenses.totalThisMonth(category, now);
    final pctRaw = budget > 0 ? (monthlyTotal / budget) : 0.0;
    final pct = pctRaw.isFinite ? pctRaw.clamp(0.0, 2.0) : 0.0;

    // 2. Günlük ortalama ve projeksiyon
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final avgPerDay = _calcAvgPerDay(monthlyTotal, now.day);
    final projectedRaw = _calcProjected(avgPerDay, daysInMonth);
    final projected = projectedRaw.isFinite ? projectedRaw : 0.0;

    // 3. Geçen ay ortalama
    final lastMonth =
        now.month == 1
            ? DateTime(now.year - 1, 12)
            : DateTime(now.year, now.month - 1);
    final prevAvg = _calcPrevMonthAvg(allExpenses, category, lastMonth);

    // 4. Haftalık trend
    final thisWeek = allExpenses.totalLast7Days(category, now);
    final lastWeekEnd = now.subtract(Duration(days: now.weekday));
    final lastWeekStart = lastWeekEnd.subtract(const Duration(days: 6));
    final lastWeek = allExpenses.total(
      category: category,
      start: lastWeekStart,
      end: lastWeekEnd,
    );
    final weekChangeRaw =
        lastWeek > 0 ? ((thisWeek - lastWeek) / lastWeek * 100) : 0.0;
    final weekChange = weekChangeRaw.isFinite ? weekChangeRaw.abs().toInt() : 0;

    // 5. En yoğun gün
    final byWeekday = <int, double>{};
    for (var x in allExpenses.where(
      (x) =>
          x.category == category &&
          x.date.year == now.year &&
          x.date.month == now.month,
    )) {
      byWeekday[x.date.weekday] = (byWeekday[x.date.weekday] ?? 0) + x.amount;
    }
    final busiestEntry = byWeekday.entries.fold<MapEntry<int, double>?>(
      null,
      (best, entry) =>
          (best == null || entry.value > best.value) ? entry : best,
    );

    // 6. İpuçları
    final tips = <String>[];
    if (category == 'Yemek')
      tips.add('Evde daha sık yemek yapmayı deneyebilirsin.');
    if (category == 'Ulaşım')
      tips.add('Toplu taşıma kullanarak tasarruf edebilirsin.');
    if (category == 'Eğlence')
      tips.add('Ücretsiz etkinlikleri keşfetmeyi düşün.');
    final tipText = tips.isNotEmpty ? tips[_rand.nextInt(tips.length)] : '';

    // 7. Parçaları birleştir
    final parts = <String>[];
    if (pct >= 1.0) {
      final pctInt = (pct * 100).toInt();
      parts.add(
        _fill(_templates['overBudget']!, {'percent': pctInt.toString()}),
      );
    }
    parts.add(
      _fill(
        monthlyTotal > budget
            ? _templates['forecastWarn']!
            : _templates['forecast']!,
        {'projected': projected.toInt().toString()},
      ),
    );
    parts.add(
      _fill(_templates['compare']!, {
        'prevAvg': prevAvg.toInt().toString(),
        'currentAvg': avgPerDay.toInt().toString(),
      }),
    );
    parts.add(
      _fill(_templates['trend']!, {
        'thisWeek': thisWeek.toInt().toString(),
        'weekChange': weekChange.toString(),
      }),
    );
    if (busiestEntry != null && monthlyTotal > 0) {
      final dayName = _weekdayName(busiestEntry.key);
      final dayPct =
          ((busiestEntry.value / monthlyTotal) * 100).toInt().toString();
      parts.add(
        _fill(_templates['busiest']!, {
          'dayName': dayName,
          'dayPercent': dayPct,
        }),
      );
    }
    if (_hasRecurring(allExpenses, category)) {
      parts.add(_templates['recurring']!);
    }
    if (projected < budget) {
      parts.add(
        _fill(_templates['positive']!, {
          'savings': (budget - projected).toInt().toString(),
        }),
      );
    }
    if (tipText.isNotEmpty) {
      parts.add(_fill(_templates['tip']!, {'tip': tipText}));
    }

    return parts.join(' ');
  }

  double _calcAvgPerDay(double total, int day) => total / max(day, 1);

  double _calcProjected(double avgPerDay, int daysInMonth) =>
      avgPerDay * daysInMonth;

  double _calcPrevMonthAvg(List<Expense> all, String cat, DateTime lastMonth) {
    final days = DateUtils.getDaysInMonth(lastMonth.year, lastMonth.month);
    final spent = all.totalThisMonth(cat, lastMonth);
    return days > 0 ? spent / days : 0.0;
  }

  bool _hasRecurring(List<Expense> all, String cat) =>
      all.where((e) => e.category == cat).length > 1;

  String _weekdayName(int wd) {
    const names = {
      1: 'Pazartesi',
      2: 'Salı',
      3: 'Çarşamba',
      4: 'Perşembe',
      5: 'Cuma',
      6: 'Cumartesi',
      7: 'Pazar',
    };
    return names[wd] ?? '';
  }

  String _fill(String template, Map<String, String> vals) {
    var result = template;
    vals.forEach((k, v) => result = result.replaceAll('%{$k}', v));
    return result;
  }
}
