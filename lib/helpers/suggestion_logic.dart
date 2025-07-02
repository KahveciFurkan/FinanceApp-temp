import 'dart:math';
import 'package:flutter/material.dart';
import '../types/type.dart';

class SuggestionService {
  /// Kategori başına aylık bütçe tanımları
  final Map<String, double> categoryBudgets;

  SuggestionService(this.categoryBudgets);

  /// [e] harcama, [allExpenses] tüm kayıtlı giderler
  String getSuggestion(Expense e, List<Expense> allExpenses) {
    final now = DateTime.now();

    // 1. Bu ayki kategori giderleri
    final monthExpenses = allExpenses.where(
      (x) =>
          x.category == e.category &&
          x.date.year == now.year &&
          x.date.month == now.month,
    );
    final monthlyTotal = monthExpenses.fold<double>(
      0,
      (sum, x) => sum + x.amount,
    );

    // 2. Aylık bütçe ve yüzde kullanımı
    final budget = categoryBudgets[e.category] ?? monthlyTotal;
    final percentOfBudget =
        budget > 0 ? (monthlyTotal / budget).clamp(0.0, 2.0) : 0.0;

    // 3. Gün bazlı məlumatlar
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final day = now.day;
    final daysLeft = max(daysInMonth - day, 0);
    final avgSpentPerDay = monthlyTotal / max(day, 1);
    final dailyBudget = budget / daysInMonth;

    // 4. Ay sonu tahmini
    final projectedTotal = avgSpentPerDay * daysInMonth;
    final forecastText =
        projectedTotal > budget
            ? 'Bu hızla devam edersen ay sonunda ₺${projectedTotal.toInt()} harcarsın.'
            : 'Projeksiyon: ay sonunda ₺${projectedTotal.toInt()} harcarsın.';

    // 5. Geçen ay karşılaştırması
    final lastMonth =
        now.month == 1
            ? DateTime(now.year - 1, 12)
            : DateTime(now.year, now.month - 1);
    final prevExpenses = allExpenses.where(
      (x) =>
          x.category == e.category &&
          x.date.year == lastMonth.year &&
          x.date.month == lastMonth.month,
    );
    final prevTotal = prevExpenses.fold<double>(0, (s, x) => s + x.amount);
    final prevAvg =
        prevTotal / DateUtils.getDaysInMonth(lastMonth.year, lastMonth.month);
    final compareText =
        'Geçen ay ortalama ₺${prevAvg.toInt()}, bu ay günde ₺${avgSpentPerDay.toInt()}.';

    // 6. Haftalık trend (% değişim)
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final lastWeekStart = weekStart.subtract(const Duration(days: 7));
    final thisWeekSum = allExpenses
        .where(
          (x) =>
              x.category == e.category &&
              x.date.isAfter(weekStart.subtract(const Duration(seconds: 1))) &&
              x.date.isBefore(now.add(const Duration(days: 1))),
        )
        .fold<double>(0, (s, x) => s + x.amount);
    final lastWeekSum = allExpenses
        .where(
          (x) =>
              x.category == e.category &&
              x.date.isAfter(
                lastWeekStart.subtract(const Duration(seconds: 1)),
              ) &&
              x.date.isBefore(weekStart.add(const Duration(seconds: 1))),
        )
        .fold<double>(0, (s, x) => s + x.amount);
    final weekChange =
        lastWeekSum > 0
            ? ((thisWeekSum - lastWeekSum) / lastWeekSum * 100).toInt()
            : 0;
    final trendText =
        'Son 7 gün ₺${thisWeekSum.toInt()}, değişim %${weekChange.abs()}.';

    // 7. En yoğun gün tayini
    final byWeekday = <int, double>{};
    for (var x in monthExpenses) {
      byWeekday[x.date.weekday] = (byWeekday[x.date.weekday] ?? 0) + x.amount;
    }
    final busiest = byWeekday.entries.fold<MapEntry<int, double>?>(null, (
      best,
      entry,
    ) {
      if (best == null || entry.value > best.value) return entry;
      return best;
    });
    final weekdayNames = {
      1: 'Pazartesi',
      2: 'Salı',
      3: 'Çarşamba',
      4: 'Perşembe',
      5: 'Cuma',
      6: 'Cumartesi',
      7: 'Pazar',
    };
    final busiestText =
        busiest != null
            ? 'En çok ${weekdayNames[busiest.key]} günü (%${((busiest.value / monthlyTotal) * 100).toInt()}).'
            : '';

    // 8. Tekrarlayan gider hatırlatması
    final recurringCount =
        allExpenses.where((x) => x.category == e.category).length;
    final recurringText =
        recurringCount > 1
            ? 'Bu kategori için tekrarlayan giderlerin var, bir sonraki kesintiyi kontrol et.'
            : '';

    // 9. Pozitif ödül önerisi
    final positiveText =
        projectedTotal < budget
            ? 'Bu hızla ilerleyerek ₺${(budget - projectedTotal).toInt()} tasarruf edebilirsin!'
            : '';

    // 10. Kişiselleştirilmiş ipuçları
    final tips = <String>[];
    if (e.category == 'Yemek') {
      tips.add('Evde daha sık yemek yapmayı deneyebilirsin.');
    }
    if (e.category == 'Ulaşım') {
      tips.add('Toplu taşıma kullanarak tasarruf edebilirsin.');
    }
    if (e.category == 'Eğlence') {
      tips.add('Ücretsiz etkinlikleri keşfetmeyi düşün.');
    }
    final tipText = tips.isNotEmpty ? tips[Random().nextInt(tips.length)] : '';

    // Tüm mesajları birleştir
    final parts =
        [
          if (percentOfBudget >= 1.0)
            '⚠️ Bütçeni aştın! Toplam %${(percentOfBudget * 100).toInt()}.',
          if (percentOfBudget < 1.0) forecastText,
          compareText,
          trendText,
          busiestText,
          recurringText,
          positiveText,
          tipText,
        ].where((s) => s.isNotEmpty).toList();

    return parts.join(' ');
  }
}
