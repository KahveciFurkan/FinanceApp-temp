class SavingsGoal {
  final String title;
  final double targetAmount;
  final double savedAmount;

  const SavingsGoal({
    required this.title,
    required this.targetAmount,
    required this.savedAmount,
  });
}

class SavingsTransaction {
  final String title;
  final double amount;
  final DateTime date;
  final String type; // 'Ekleme' / 'Çekme'
  final String currency; // '₺', 'USD', 'EUR', 'Altın', 'Gümüş' vs.

  const SavingsTransaction({
    required this.title,
    required this.amount,
    required this.date,
    required this.type,
    required this.currency,
  });
}

