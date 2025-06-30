import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'connection_model.dart';

class ConnectionPainter extends CustomPainter {
  final List<ConnectionModel> connections;
  final Map<String, Offset> nodePositions; // Node’ların top-left pozisyonları
  final String? highlightNodeId;
  final double animationProgress;
  final Size nodeSize;

  ConnectionPainter({
    required this.connections,
    required this.nodePositions,
    this.highlightNodeId,
    this.animationProgress = 1.0,
    required this.nodeSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final conn in connections) {
      final fromTL = nodePositions[conn.fromId];
      final toTL = nodePositions[conn.toId];
      if (fromTL == null || toTL == null) continue;

      // Top-left pozisyondan önce merkezleri hesapla
      final fromCenter =
          fromTL + Offset(nodeSize.width / 2, nodeSize.height / 2);
      final toCenter = toTL + Offset(nodeSize.width / 2, nodeSize.height / 2);

      // Kesişim noktalarını al
      final start = _edgePoint(fromCenter, toCenter);
      final end = _edgePoint(toCenter, fromCenter);

      final isHighlighted =
          highlightNodeId != null &&
          (conn.fromId == highlightNodeId || conn.toId == highlightNodeId);

      final paint =
          Paint()
            ..color = _getColor(conn.type, isHighlighted)
            ..strokeWidth = isHighlighted ? 3.5 : 2.0
            ..style = PaintingStyle.stroke;

      final path =
          Path()
            ..moveTo(start.dx, start.dy)
            ..quadraticBezierTo(
              (start.dx + end.dx) / 2,
              (start.dy + end.dy) / 2 - 60,
              end.dx,
              end.dy,
            );

      for (final metric in path.computeMetrics()) {
        final segment = metric.extractPath(
          0,
          metric.length * animationProgress,
        );
        if (conn.type == 'dashed') {
          _drawDashedLine(canvas, segment, paint);
        } else {
          canvas.drawPath(segment, paint);
        }
      }
    }
  }

  /// Merkezler arası çizgiyi, düğüm kenarıyla kesişen noktaya bağlar
  Offset _edgePoint(Offset fromCenter, Offset toCenter) {
    final dx = toCenter.dx - fromCenter.dx;
    final dy = toCenter.dy - fromCenter.dy;
    final hw = nodeSize.width / 2;
    final hh = nodeSize.height / 2;

    final tx = dx.abs() > 0 ? hw / dx.abs() : double.infinity;
    final ty = dy.abs() > 0 ? hh / dy.abs() : double.infinity;
    final t = math.min(tx, ty);

    return fromCenter + Offset(dx * t, dy * t);
  }

  void _drawDashedLine(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 3.0;
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + dashSpace;
      }
    }
  }

  Color _getColor(String type, bool isHighlighted) {
    if (isHighlighted) return Colors.amberAccent;
    switch (type) {
      case 'strong':
        return Colors.deepPurpleAccent;
      case 'dashed':
        return Colors.tealAccent;
      default:
        return Colors.white70;
    }
  }

  @override
  bool shouldRepaint(covariant ConnectionPainter old) {
    return old.connections != connections ||
        old.nodePositions != nodePositions ||
        old.highlightNodeId != highlightNodeId ||
        old.animationProgress != animationProgress ||
        old.nodeSize != nodeSize;
  }
}
