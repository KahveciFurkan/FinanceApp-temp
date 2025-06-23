import 'package:flutter/material.dart';
import '../../types/node_model.dart';

class NodeWidget extends StatefulWidget {
  final NodeModel node;
  // onPositionChanged artık isDragEnd parametresi alacak
  final void Function(
    NodeModel updatedNode, {
    required Offset globalPosition,
    bool isDragEnd,
  })
  onPositionChanged;
  final void Function(NodeModel updatedNode) onEdit;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const NodeWidget({
    super.key,
    required this.node,
    required this.onPositionChanged,
    required this.onEdit,
    this.onTap,
    this.onDelete,
  });

  @override
  State<NodeWidget> createState() => _NodeWidgetState();
}

class _NodeWidgetState extends State<NodeWidget> {
  late Offset position;

  @override
  void initState() {
    super.initState();
    position = Offset(widget.node.posX, widget.node.posY);
  }

  void _updatePosition(Offset newLocalPosition, DragUpdateDetails details) {
    setState(() {
      position = newLocalPosition;
    });

    final globalPosition = details.globalPosition;

    final updatedNode = widget.node.copyWith(
      posX: newLocalPosition.dx,
      posY: newLocalPosition.dy,
    );

    widget.onPositionChanged(
      updatedNode,
      globalPosition: globalPosition,
      isDragEnd: false,
    );
  }

  void _handlePanEnd(DragEndDetails details) {
    final updatedNode = widget.node.copyWith(
      posX: position.dx,
      posY: position.dy,
    );

    // Burada globalPosition yok, ama _updatePosition'da zaten en son güncelledik
    // Yine de silme için son pozisyon gerekli. Kısaca position'ın global karşılığını bulabiliriz:
    final renderBox = context.findRenderObject() as RenderBox;
    final globalPosition = renderBox.localToGlobal(Offset.zero);

    widget.onPositionChanged(
      updatedNode,
      globalPosition: globalPosition,
      isDragEnd: true,
    );
  }

  void _editNodePopup() {
    final controller = TextEditingController(text: widget.node.title);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Notu Düzenle"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Başlık"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (widget.onDelete != null) {
                  widget.onDelete!();
                }
                Navigator.of(context).pop();
              },
              child: const Text("Sil", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                final updatedNode = widget.node.copyWith(
                  title: controller.text,
                );
                widget.onEdit(updatedNode);
                Navigator.of(context).pop();
              },
              child: const Text("Kaydet"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          _updatePosition(position + details.delta, details);
        },
        onPanEnd: (_) => _handlePanEnd,
        onLongPress: _editNodePopup,
        onTap: widget.onTap,
        child: Card(
          elevation: 6,
          color: Colors.blueGrey[800],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              widget.node.title,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
