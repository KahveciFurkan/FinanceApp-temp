import 'package:flutter/material.dart';
import 'connection_model.dart';
import 'connection_painter.dart';

class MindMapCanvas extends StatelessWidget {
  final List<Map<String, dynamic>> nodes;
  final List<ConnectionModel> connections;
  final Map<String, Offset> nodePositions;
  final double scale;
  final Offset offset;
  final void Function(ScaleStartDetails) onScaleStart;
  final void Function(ScaleUpdateDetails) onScaleUpdate;
  final Widget Function() buildNodes;
  final String? connectingNodeId;
  final String? hoveredConnectionId;
  final double nodeWidth;
  final double nodeHeight;
  final VoidCallback clearHighlights;
  final String? selectedNodeId;

  const MindMapCanvas({
    required this.nodes,
    required this.connections,
    required this.nodePositions,
    required this.scale,
    required this.offset,
    required this.onScaleStart,
    required this.onScaleUpdate,
    required this.buildNodes,
    this.connectingNodeId,
    this.hoveredConnectionId,
    required this.nodeWidth,
    required this.nodeHeight,
    required this.clearHighlights,
    this.selectedNodeId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundGradient =
        isDark
            ? const [Color(0xFF1a1a2e), Color(0xFF16213e)]
            : [Colors.grey.shade100, Colors.white];

    return GestureDetector(
      onScaleStart: onScaleStart,
      onScaleUpdate: onScaleUpdate,
      child: ClipRect(
        child: Transform(
          transform:
              Matrix4.identity()
                ..translate(offset.dx, offset.dy)
                ..scale(scale),
          alignment: Alignment.topLeft,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: backgroundGradient,
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CustomPaint(
                  size: Size.infinite,
                  painter: ConnectionPainter(
                    connections: connections,
                    nodePositions: nodePositions,
                    highlightNodeId: selectedNodeId,
                    animationProgress: 1.0,
                    nodeSize: Size(
                      nodeWidth,
                      nodeHeight,
                    ), // ← Burada nodeSize ekliyoruz
                  ),
                ),
                buildNodes(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
