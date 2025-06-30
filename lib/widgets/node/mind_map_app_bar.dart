import 'package:flutter/material.dart';

class MindMapAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onAddNode;
  final VoidCallback onAutoLayout;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final ValueChanged<Color> onCreateGroup;
  final VoidCallback onShowHelp;

  const MindMapAppBar({
    required this.onAddNode,
    required this.onAutoLayout,
    required this.onUndo,
    required this.onRedo,
    required this.onCreateGroup,
    required this.onShowHelp,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white : Colors.black;

    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: iconColor,
      elevation: 2,
      title: const Text(
        "Zihin Haritası",
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: "Not Ekle",
          onPressed: onAddNode,
        ),
        IconButton(
          icon: const Icon(Icons.auto_fix_high),
          tooltip: "Otomatik Yerleşim",
          onPressed: onAutoLayout,
        ),
        IconButton(
          icon: const Icon(Icons.undo),
          tooltip: "Geri Al",
          onPressed: onUndo,
        ),
        IconButton(
          icon: const Icon(Icons.redo),
          tooltip: "Yinele",
          onPressed: onRedo,
        ),
        _buildGroupMenu(context),
        _buildMoreMenu(context),
      ],
    );
  }

  Widget _buildGroupMenu(BuildContext context) {
    return PopupMenuButton<Color>(
      tooltip: "Grup Oluştur",
      icon: const Icon(Icons.palette),
      onSelected: onCreateGroup,
      itemBuilder:
          (context) => [
            _buildColorItem(Colors.blue, "Mavi Grup"),
            _buildColorItem(Colors.green, "Yeşil Grup"),
            _buildColorItem(Colors.orange, "Turuncu Grup"),
          ],
    );
  }

  PopupMenuItem<Color> _buildColorItem(Color color, String label) {
    return PopupMenuItem(
      value: color,
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color, radius: 10),
        title: Text(label),
      ),
    );
  }

  Widget _buildMoreMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        if (value == 'help') onShowHelp();
      },
      itemBuilder:
          (context) => [
            const PopupMenuItem<String>(
              value: 'help',
              child: ListTile(
                leading: Icon(Icons.help_outline),
                title: Text("Yardım"),
              ),
            ),
          ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
