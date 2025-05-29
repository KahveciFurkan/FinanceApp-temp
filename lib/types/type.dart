import 'package:flutter/material.dart';

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

class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
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

class Subscription {
  final dynamic key;
  final String name;
  final double price;
  final DateTime renewDate;
  final String category;
  final int iconCodePoint; // IconData yerine iconun codePoint'ini tutacağız
  final int colorValue; // Renk için color.value
  final bool isFrozen;
  final bool isPaid;
  final DateTime paidMonth;
  final VoidCallback? onTogglePaid;

  Subscription({
    this.key,
    required this.name,
    required this.price,
    required this.renewDate,
    required this.category,
    required this.iconCodePoint,
    required this.colorValue,
    this.isFrozen = false,
    this.isPaid = false,
    DateTime? paidMonth,
    this.onTogglePaid,
  }) : paidMonth = paidMonth ?? DateTime.now();

  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  Color get color => Color(colorValue);
}
