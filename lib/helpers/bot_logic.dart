import '../types/type.dart';
import 'expense_utils.dart';

String generateBotReply(String input, List<Expense> expenses) {
  final message = input.toLowerCase();
  if (message.contains("ne kadar") || message.contains("toplam")) {
    return generateReplyFromCommand("bu_ay_toplam", expenses);
  } else if (message.contains("en çok")) {
    return generateReplyFromCommand("en_cok_kategori", expenses);
  } else if (message.contains("kategori")) {
    return generateReplyFromCommand("kategori_ozet", expenses);
  } else if (message.contains("7 gün") || message.contains("son yedi")) {
    return generateReplyFromCommand("son_7_gun", expenses);
  } else {
    return "Sorunu tam anlayamadım. Örnek: 'Bu ay ne kadar harcadım?'";
  }
}

String generateReplyFromCommand(String command, List<Expense> expenses) {
  final now = DateTime.now();

  switch (command) {
    case "bu_ay_toplam":
      final total = getMonthlyTotal(expenses, now);
      return "Bu ay toplam harcaman ${total.toStringAsFixed(2)}₺.";
    case "en_cok_kategori":
      final result = getTopSpendingCategory(expenses, now);
      return result ?? "Bu ay harcama bulunamadı.";
    case "kategori_ozet":
      final summary = getCategorySummary(expenses, now);
      return summary;
    case "son_7_gun":
      final total = getLast7DaysTotal(expenses);
      return "Son 7 gün içinde toplam ${total.toStringAsFixed(2)}₺ harcadın.";
    default:
      return "Bu komutu anlayamadım.";
  }
}
