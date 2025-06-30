// mind_map_screen.dart - Hive destekli zihin haritası ekranı

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../types/node_model.dart';
import '../../widgets/node/connection_model.dart';
import '../../widgets/node/help_dialog.dart';
import '../../widgets/node/mind_map_app_bar.dart';
import '../../widgets/node/mind_map_canvas.dart';
import '../../widgets/node/trash_bin.dart';
import '../../widgets/node/node_widget.dart';

class MindMapScreen extends StatefulWidget {
  const MindMapScreen({super.key});

  @override
  State<MindMapScreen> createState() => _MindMapScreenState();
}

class _MindMapScreenState extends State<MindMapScreen> {
  late Box<NodeModel> nodeBox;
  late Box<ConnectionModel> connectionBox;

  List<NodeModel> nodes = [];
  List<ConnectionModel> connections = [];

  double _scale = 1.0;
  double _previousScale = 1.0;
  Offset _offset = Offset.zero;
  Offset _startPanOffset = Offset.zero;

  String? _connectingNodeId;
  String? _selectedNodeId;

  final GlobalKey trashKey = GlobalKey();
  bool isDragging = false;

  final double nodeWidth = 160;
  final double nodeHeight = 100;

  @override
  void initState() {
    super.initState();
    nodeBox = Hive.box<NodeModel>('nodes');
    connectionBox = Hive.box<ConnectionModel>('connections');

    nodes = nodeBox.values.toList();
    connections = connectionBox.values.toList();
  }

  void _saveNodesToHive() {
    nodeBox.clear();
    for (var node in nodes) {
      nodeBox.put(node.id, node);
    }
  }

  void _saveConnectionsToHive() {
    connectionBox.clear();
    for (var connection in connections) {
      connectionBox.put(connection.id, connection);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nodePositions = {
      for (var node in nodes) node.id: Offset(node.posX, node.posY),
    };

    return Scaffold(
      appBar: MindMapAppBar(
        onAddNode: _addNode,
        onAutoLayout: _autoLayout,
        onUndo: _undo,
        onRedo: _redo,
        onCreateGroup: _createGroup,
        onShowHelp: () => showHelpDialog(context),
      ),
      body: Stack(
        children: [
          MindMapCanvas(
            nodes:
                nodes
                    .map(
                      (n) => {
                        'id': n.id,
                        'title': n.title,
                        'posX': n.posX,
                        'posY': n.posY,
                        'groupColor': n.groupColorValue,
                        'noteType': n.noteType,
                      },
                    )
                    .toList(),
            connections: connections,
            nodePositions: nodePositions,
            scale: _scale,
            offset: _offset,
            onScaleStart: _onScaleStart,
            onScaleUpdate: _onScaleUpdate,
            clearHighlights: () => setState(() => _selectedNodeId = null),
            nodeWidth: nodeWidth,
            nodeHeight: nodeHeight,
            connectingNodeId: _connectingNodeId,
            buildNodes:
                () => Stack(
                  children:
                      nodes.map((node) {
                        return NodeWidget(
                          key: ValueKey(node.id),
                          node: node,
                          isSelected: _selectedNodeId == node.id,
                          isInConnectionMode: _connectingNodeId != null,
                          connectionStartId: _connectingNodeId,
                          connections: connections,
                          nodeCenters: nodePositions,
                          nodeWidth: nodeWidth,
                          nodeHeight: nodeHeight,
                          onEdit: (updatedNode) {
                            setState(() {
                              final index = nodes.indexWhere(
                                (n) => n.id == updatedNode.id,
                              );
                              if (index != -1) {
                                nodes[index] = updatedNode;
                                _saveNodesToHive();
                              }
                            });
                          },
                          onPositionChanged: (
                            updatedNode,
                            center, {
                            isDragEnd = false,
                          }) {
                            setState(() {
                              final index = nodes.indexWhere(
                                (n) => n.id == updatedNode.id,
                              );
                              if (index != -1) {
                                nodes[index] = updatedNode;
                                _saveNodesToHive();
                              }
                            });
                          },
                          onConnect: (fromId, toId) {
                            setState(() {
                              final newConn = ConnectionModel(
                                id: UniqueKey().toString(),
                                fromId: fromId,
                                toId: toId,
                              );
                              connections.add(newConn);
                              _connectingNodeId = null;
                              _saveConnectionsToHive();
                            });
                          },
                          onStartConnection: (nodeId) {
                            setState(() => _connectingNodeId = nodeId);
                          },
                          trashKey: trashKey,
                          onDelete: (nodeId) {
                            setState(() {
                              nodes.removeWhere((n) => n.id == nodeId);
                              connections.removeWhere(
                                (c) => c.fromId == nodeId || c.toId == nodeId,
                              );
                              _saveNodesToHive();
                              _saveConnectionsToHive();
                            });
                          },
                          onDraggingChanged: (dragging) {
                            setState(() => isDragging = dragging);
                          },
                          onSelect: (nodeId) {
                            setState(() => _selectedNodeId = nodeId);
                          },
                        );
                      }).toList(),
                ),
          ),
          TrashBin(isVisible: isDragging, key: trashKey),
        ],
      ),
    );
  }

  void _onScaleStart(ScaleStartDetails details) {
    _previousScale = _scale;
    _startPanOffset = _offset;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _scale = _previousScale * details.scale;
      if (details.scale == 1.0) {
        _offset = _startPanOffset + details.focalPointDelta;
      }
    });
  }

  void _addNode() {
    setState(() {
      final id = UniqueKey().toString();
      final newNode = NodeModel.createDefault(
        id: id,
        offset: const Offset(100, 100),
      );
      nodes.add(newNode);
      _selectedNodeId = id;
      _saveNodesToHive();
    });
  }

  void _autoLayout() {}
  void _undo() {}
  void _redo() {}
  void _createGroup(Color color) {}
}
