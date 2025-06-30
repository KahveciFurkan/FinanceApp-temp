import 'package:flutter/material.dart';

class TrashBin extends StatelessWidget {
  final bool isVisible;

  const TrashBin({required this.isVisible, super.key});

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Positioned(
      bottom: 40,
      left: MediaQuery.of(context).size.width / 2 - 30,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.85),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withOpacity(0.6),
              blurRadius: 12,
              spreadRadius: 3,
            ),
          ],
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 34),
      ),
    );
  }
}
