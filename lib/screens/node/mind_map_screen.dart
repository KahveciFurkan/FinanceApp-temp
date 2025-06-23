import 'package:flutter/material.dart';
import '../../types/node_model.dart';
import '../../widgets/node/node_widget.dart';
import 'package:uuid/uuid.dart';

class ConnectionModel {
  final String fromId;
  final String toId;

  ConnectionModel({required this.fromId, required this.toId});
}

class MindMapScreen extends StatefulWidget {
  const MindMapScreen({super.key});

  @override
  State<MindMapScreen> createState() => _MindMapScreenState();
}

class _MindMapScreenState extends State<MindMapScreen> {
  final List<Map<String, dynamic>> nodes = [];
  final List<ConnectionModel> connections = [];
  final uuid = const Uuid();

  String? _connectingNodeId;

  // Drag & drop için
  bool isDragging = false;
  Offset? dragPosition;
  String? draggingNodeId;

  // Çöp kutusu widget'ının konumu için key
  final GlobalKey trashKey = GlobalKey();

  void _addNode() {
    setState(() {
      nodes.add({
        "id": uuid.v4(),
        "title": "Yeni Not",
        "posX": 50.0,
        "posY": 50.0,
      });
    });
  }

  void _deleteNode(String id) {
    setState(() {
      nodes.removeWhere((node) => node['id'] == id);
      connections.removeWhere((conn) => conn.fromId == id || conn.toId == id);
    });
  }

  void _updateNodePosition(
    String id,
    Offset localOffset, {
    required Offset globalPosition,
    bool isDragEnd = false,
  }) {
    setState(() {
      final node = nodes.firstWhere((element) => element['id'] == id);
      node['posX'] = localOffset.dx;
      node['posY'] = localOffset.dy;

      dragPosition = localOffset;
      draggingNodeId = id;
      isDragging = !isDragEnd;

      if (isDragEnd) {
        if (_isOverTrash(globalPosition)) {
          _deleteNode(id);
        }
        isDragging = false;
        dragPosition = null;
        draggingNodeId = null;
      }
    });
  }

  bool _isOverTrash(Offset globalPosition) {
    final RenderBox? trashRenderBox =
        trashKey.currentContext?.findRenderObject() as RenderBox?;
    if (trashRenderBox == null) return false;

    final trashPos = trashRenderBox.localToGlobal(Offset.zero);
    final trashSize = trashRenderBox.size;

    final rect = Rect.fromLTWH(
      trashPos.dx,
      trashPos.dy,
      trashSize.width,
      trashSize.height,
    );

    return rect.contains(globalPosition);
  }

  void _startConnection(String nodeId) {
    setState(() {
      if (_connectingNodeId == null) {
        _connectingNodeId = nodeId;
      } else if (_connectingNodeId != nodeId) {
        connections.add(
          ConnectionModel(fromId: _connectingNodeId!, toId: nodeId),
        );
        _connectingNodeId = null;
      } else {
        _connectingNodeId = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, Offset> nodePositions = {
      for (var node in nodes)
        node['id'] as String: Offset(node['posX'], node['posY']),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text("Zihin Haritası"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addNode,
            tooltip: "Not Ekle",
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: ConnectionPainter(
                connections: connections,
                nodePositions: nodePositions,
                highlightNodeId: _connectingNodeId,
              ),
            ),
          ),
          ...nodes.map((node) {
            return NodeWidget(
              node: NodeModel(
                id: node['id'],
                title: node['title'],
                posX: node['posX'],
                posY: node['posY'],
              ),
              onPositionChanged: (
                updatedNode, {
                required Offset globalPosition,
                bool isDragEnd = false,
              }) {
                _updateNodePosition(
                  updatedNode.id,
                  Offset(updatedNode.posX, updatedNode.posY),
                  globalPosition: globalPosition,
                  isDragEnd: isDragEnd,
                );
              },
              onTap: () {
                _startConnection(node['id']);
              },
              onDelete: () => _deleteNode(node['id']),
              onEdit: (updatedNode) {
                setState(() {
                  final targetNode = nodes.firstWhere(
                    (n) => n['id'] == updatedNode.id,
                  );
                  targetNode['title'] = updatedNode.title;
                });
              },
            );
          }).toList(),

          // Çöp kutusu, sadece sürükleme sırasında gösterilir
          if (isDragging)
            Positioned(
              key: trashKey,
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
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.white,
                  size: 34,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ConnectionPainter extends CustomPainter {
  final List<ConnectionModel> connections;
  final Map<String, Offset> nodePositions;
  final String? highlightNodeId;

  ConnectionPainter({
    required this.connections,
    required this.nodePositions,
    this.highlightNodeId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white70
          ..strokeWidth = 3.0;

    final highlightPaint =
        Paint()
          ..color = Colors.orangeAccent
          ..strokeWidth = 4.0;

    for (var connection in connections) {
      final from = nodePositions[connection.fromId];
      final to = nodePositions[connection.toId];

      if (from != null && to != null) {
        final isHighlighted =
            highlightNodeId == connection.fromId ||
            highlightNodeId == connection.toId;
        canvas.drawLine(from, to, isHighlighted ? highlightPaint : paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant ConnectionPainter oldDelegate) {
    return connections != oldDelegate.connections ||
        nodePositions != oldDelegate.nodePositions ||
        highlightNodeId != oldDelegate.highlightNodeId;
  }
}
