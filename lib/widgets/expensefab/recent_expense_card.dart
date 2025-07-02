import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';

import '../../types/type.dart';

class RecentExpenseCard extends StatefulWidget {
  final Expense e;
  final double monthlyCategoryTotal;
  final String suggestion;

  const RecentExpenseCard({
    required this.e,
    required this.monthlyCategoryTotal,
    required this.suggestion,
    Key? key,
  }) : super(key: key);

  @override
  _RecentExpenseCardState createState() => _RecentExpenseCardState();
}

class _RecentExpenseCardState extends State<RecentExpenseCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
      lowerBound: 0.95,
      upperBound: 1.05,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  /*************  ✨ Windsurf Command ⭐  *************/
  /// Shows a dialog with a suggestion given by the bot for this expense.
  /// The suggestion is shown in a centered [Text] widget with a smaller font size.
  /// The dialog has a single [TextButton] with the text "Tamam 😊" which
  /// dismisses the dialog when pressed.
  /*******  975fc4fd-ed35-4841-be2e-9d804db0fc2d  *******/
  void _showSuggestionDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: Colors.grey[850],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Center(
              child: Text(
                '💡 Bot Önerisi',
                style: TextStyle(
                  color: Colors.orangeAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            content: Text(
              widget.suggestion,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Tamam 😊'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.e;
    final percent =
        widget.monthlyCategoryTotal > 0
            ? (e.amount / widget.monthlyCategoryTotal).clamp(0.0, 1.0)
            : 0.0;
    final baseColor = _colorForCategory(e.category);
    final isHigh = percent > 0.75;

    return ScaleTransition(
      scale: isHigh ? _pulseController : const AlwaysStoppedAnimation(1.0),
      child: GestureDetector(
        onTap: _showSuggestionDialog,
        child: Card(
          color: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
          child: SizedBox(
            width: 180,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final iconSize = w * 0.3; // %30
                  final circleSize = w * 0.3; // %30

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: animation + percent circle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: iconSize,
                            height: iconSize,
                            child: Lottie.asset(
                              'assets/money.json',
                              fit: BoxFit.contain,
                              repeat: true,
                            ),
                          ),
                          CircularPercentIndicator(
                            radius: circleSize,
                            lineWidth: circleSize * 0.15,
                            percent: percent,
                            center: Text(
                              '${(percent * 100).toInt()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            progressColor: baseColor,
                            backgroundColor: Colors.grey[800]!,
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Title
                      Text(
                        e.title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const Spacer(),

                      // Date & Amount aligned baseline
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            DateFormat('dd MMM', 'tr_TR').format(e.date),
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${e.amount.toStringAsFixed(2)} ₺',
                            style: TextStyle(
                              color: isHigh ? Colors.redAccent : baseColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 4),
                      // Hint: Tap card to see full suggestion
                      const Center(
                        child: Text(
                          '💡 Dokun, öneriyi gör',
                          style: TextStyle(color: Colors.white38, fontSize: 10),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _colorForCategory(String cat) {
    switch (cat) {
      case 'Yemek':
        return Colors.redAccent;
      case 'Ulaşım':
        return Colors.blueAccent;
      case 'Eğlence':
        return Colors.purpleAccent;
      default:
        return Colors.orangeAccent;
    }
  }
}
