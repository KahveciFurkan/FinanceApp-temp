import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppDrawer extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const AppDrawer({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color activeColor = Colors.orangeAccent;
    Color backgroundColor = const Color(0xFF1C1C1E);
    Color inactiveColor = Colors.grey;

    Widget buildMenuItem(String title, IconData icon, int index) {
      final bool isActive = selectedIndex == index;

      return ListTile(
        leading: Icon(icon, color: isActive ? activeColor : inactiveColor),
        title: Text(
          title,
          style: GoogleFonts.gochiHand(
            color: isActive ? activeColor : inactiveColor,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          if (!isActive) {
            onItemSelected(index);
          }
        },
      );
    }

    return Drawer(
      backgroundColor: backgroundColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: backgroundColor, // Dark temaya uyumlu koyu gri ton
                boxShadow: [
                  BoxShadow(
                    color: backgroundColor,
                    offset: const Offset(0, 3),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Text(
                'Akıllı Finans Asistanı',
                style: GoogleFonts.gochiHand(
                  color: activeColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            const Divider(color: Colors.grey),
            buildMenuItem('Ana Sayfa', Icons.home, 0),
            buildMenuItem('Birikimler', Icons.savings, 1),
            buildMenuItem('Asistan', Icons.assistant, 2),
            buildMenuItem('Islemler', Icons.list_alt, 3), // Daha uygun ikon
            buildMenuItem('Abonelikler', Icons.autorenew, 4), // Daha uygun ikon
            buildMenuItem('Notlar', Icons.sticky_note_2, 5), // Daha uygun ikon
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '© 2025 FFinity',
                style: GoogleFonts.gochiHand(
                  color: inactiveColor,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
