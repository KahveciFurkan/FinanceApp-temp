import 'package:flutter/material.dart';
import '../../types/node_model.dart';
import 'connection_model.dart';

class NodeWidget extends StatefulWidget {
  final NodeModel node;
  final void Function(NodeModel) onEdit;
  final void Function(NodeModel, Offset globalCenter, {bool isDragEnd})
  onPositionChanged;
  final List<ConnectionModel> connections;
  final Map<String, Offset> nodeCenters;
  final double nodeWidth;
  final double nodeHeight;
  final bool isSelected;
  final bool isInConnectionMode;
  final String? connectionStartId;
  final void Function(String fromId, String toId) onConnect;
  final void Function(String?) onStartConnection;
  final GlobalKey trashKey;
  final void Function(String) onDelete;
  final void Function(bool) onDraggingChanged;
  final void Function(String) onSelect;

  const NodeWidget({
    super.key,
    required this.node,
    required this.onEdit,
    required this.onPositionChanged,
    required this.connections,
    required this.nodeCenters,
    required this.nodeWidth,
    required this.nodeHeight,
    required this.isSelected,
    required this.isInConnectionMode,
    required this.connectionStartId,
    required this.onConnect,
    required this.onStartConnection,
    required this.trashKey,
    required this.onDelete,
    required this.onDraggingChanged,
    required this.onSelect,
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.nodeCenters[widget.node.id] = _getCenter();
    });
  }

  @override
  void didUpdateWidget(covariant NodeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.node.posX != widget.node.posX ||
        oldWidget.node.posY != widget.node.posY) {
      setState(() => position = Offset(widget.node.posX, widget.node.posY));
    }
  }

  void _updatePosition(Offset newLocal, DragUpdateDetails details) {
    final snapped = Offset(
      (newLocal.dx / 10).round() * 10.0,
      (newLocal.dy / 10).round() * 10.0,
    );
    setState(() => position = snapped);
    widget.nodeCenters[widget.node.id] = _getCenter();
    widget.onPositionChanged(
      widget.node.copyWith(posX: snapped.dx, posY: snapped.dy),
      _getCenter(),
      isDragEnd: false,
    );
  }

  void _handlePanEnd(DragEndDetails details) {
    widget.onDraggingChanged(false);
    final RenderBox? trashBox =
        widget.trashKey.currentContext?.findRenderObject() as RenderBox?;
    final RenderBox? myBox = context.findRenderObject() as RenderBox?;
    if (trashBox != null && myBox != null) {
      final trashPos = trashBox.localToGlobal(Offset.zero);
      final nodePos = myBox.localToGlobal(Offset.zero);
      if ((trashPos & trashBox.size).overlaps(nodePos & myBox.size)) {
        widget.onDelete(widget.node.id);
        return;
      }
    }
    widget.onPositionChanged(
      widget.node.copyWith(posX: position.dx, posY: position.dy),
      _getCenter(),
      isDragEnd: true,
    );
  }

  Offset _getCenter() => Offset(
    position.dx + widget.nodeWidth / 2,
    position.dy + widget.nodeHeight / 2,
  );

  void _showEditPopup() {
    final controller = TextEditingController(text: widget.node.title);
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Notu Düzenle'),
            content: TextField(
              controller: controller,
              autofocus: true,
              maxLines: 3,
              decoration: const InputDecoration(hintText: 'Başlığı girin'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('İptal'),
              ),
              ElevatedButton(
                onPressed: () {
                  final newTitle = controller.text.trim();
                  if (newTitle.isNotEmpty && newTitle != widget.node.title) {
                    widget.onEdit(widget.node.copyWith(title: newTitle));
                  }
                  Navigator.of(ctx).pop();
                },
                child: const Text('Kaydet'),
              ),
            ],
          ),
    );
  }

  void _handleDoubleTap() {
    // Eğer bağlantı modu kapalıysa, çift dokunarak başlat
    if (!widget.isInConnectionMode) {
      widget.onStartConnection(widget.node.id);
    } else {
      // Mod açıksa, ve farklı notaya çift dokunduysn, bağlantıyı tamamla
      final startId = widget.connectionStartId;
      if (startId != null && startId != widget.node.id) {
        widget.onConnect(startId, widget.node.id);
      }
      // Bağlantı işleminden sonra modu kapat
      widget.onStartConnection(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor =
        widget.isSelected ? theme.colorScheme.primary : Colors.transparent;
    final backgroundColor =
        widget.isSelected
            ? theme.colorScheme.primary.withOpacity(0.1)
            : theme.colorScheme.surface;

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onPanStart: (_) => widget.onDraggingChanged(true),
        onPanUpdate: (d) => _updatePosition(position + d.delta, d),
        onPanEnd: _handlePanEnd,
        onLongPress: () => widget.onSelect(widget.node.id),
        onTap: _showEditPopup,
        onDoubleTap: _handleDoubleTap,
        child: Material(
          elevation: widget.isSelected ? 8 : 4,
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(32),
            side: BorderSide(color: borderColor, width: 2),
          ),
          color: backgroundColor,
          child: Container(
            width: widget.nodeWidth,
            height: widget.nodeHeight,
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  widget.node.noteType == 'idea'
                      ? Icons.lightbulb
                      : widget.node.noteType == 'task'
                      ? Icons.check_circle
                      : Icons.image,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.node.title,
                    style: theme.textTheme.bodyLarge,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
