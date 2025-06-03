import 'package:flutter/material.dart';

class AIHintCard extends StatelessWidget {
  final String suggestion;
  final double confidence;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const AIHintCard({
    super.key,
    required this.suggestion,
    required this.confidence,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orange.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI Tahmini',
              style: TextStyle(
                color: Colors.orange.shade200,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              suggestion,
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Güven: %${(confidence * 100).round()}',
                  style: TextStyle(fontSize: 12, color: Colors.orange.shade100),
                ),
                const Spacer(),
                _MiniActionButton(
                  icon: Icons.check,
                  label: 'Doğru',
                  onTap: onAccept,
                  color: Colors.greenAccent,
                ),
                const SizedBox(width: 8),
                _MiniActionButton(
                  icon: Icons.close,
                  label: 'Yanlış',
                  onTap: onReject,
                  color: Colors.redAccent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _MiniActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        backgroundColor: color.withOpacity(0.15),
        label: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
      ),
    );
  }
}
