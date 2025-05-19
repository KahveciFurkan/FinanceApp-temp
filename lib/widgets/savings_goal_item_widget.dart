import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../types/type.dart';
import '../utils/helper/helperfunctions.dart';

class SavingsGoalItemWidget extends StatelessWidget {
  final SavingsGoal goal;

  const SavingsGoalItemWidget({Key? key, required this.goal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    double progress = goal.savedAmount / goal.targetAmount;
    if (progress > 1) progress = 1;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            goal.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          LinearPercentIndicator(
            lineHeight: 12,
            percent: progress,
            backgroundColor: Colors.grey.shade300,
            progressColor: Colors.greenAccent.shade400,
            barRadius: const Radius.circular(8),
          ),
          const SizedBox(height: 8),
          Text(
            '₺${formatAmount(goal.savedAmount)} / ₺${formatAmount(goal.targetAmount)}',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
