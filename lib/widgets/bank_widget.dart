import 'package:ff/utils/helper/helperfunctions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';

class PiggyBankWidget extends StatelessWidget {
  final double totalSavings;

  const PiggyBankWidget({Key? key, required this.totalSavings})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Yuvarlak arkaplanlı büyük ikon
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.amber.shade600, Colors.orange.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons
                    .attach_money, // Burada dilersen Icons.savings, Icons.attach_money gibi değişebilir
                size: 72,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'TOPLAM BIRIKIM',
            style: GoogleFonts.gochiHand().copyWith(
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 234, 235, 229),
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₺${formatAmount(totalSavings)}',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.greenAccent,
            ),
          ),
        ],
      ),
    );
  }
}
