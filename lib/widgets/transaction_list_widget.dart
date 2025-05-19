import 'package:flutter/material.dart';
import '../types/type.dart';

class TransactionListWidget extends StatelessWidget {
  final List<SavingsTransaction> transactions;
  final Function(SavingsTransaction) onDelete;

  const TransactionListWidget({
    Key? key,
    required this.transactions,
    required this.onDelete,
  }) : super(key: key);

  String _getFormattedCurrency(SavingsTransaction tx) {
    if (tx.currency == 'Altın' || tx.currency == 'Gümüş') {
      return 'gram ${tx.currency}';
    } else {
      return tx.currency;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (ctx, index) {
        final tx = transactions[index];
        final isAddition = tx.type == 'Ekleme';

        return Dismissible(
          key: Key(tx.date.toIso8601String()),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: Colors.redAccent,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            onDelete(tx);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('İşlem silindi')),
            );
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
              '${isAddition ? '+' : '-'}${tx.amount.toStringAsFixed(2)} ${_getFormattedCurrency(tx)}',
              style: TextStyle(
                color: isAddition ? Colors.greenAccent : Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }
}
