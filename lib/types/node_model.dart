import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'node_model.g.dart';

@HiveType(typeId: 3)
class NodeModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  double posX;

  @HiveField(3)
  double posY;

  @HiveField(4)
  int? groupColorValue;

  @HiveField(5)
  String? noteType;

  NodeModel({
    required this.id,
    required this.title,
    required this.posX,
    required this.posY,
    this.groupColorValue,
    this.noteType,
  });

  /// Renk değerini Color nesnesi olarak döndürür
  Color? get groupColor =>
      groupColorValue != null ? Color(groupColorValue!) : null;

  /// Color nesnesi verip integer değere çeviren yardımcı fonksiyon
  set groupColor(Color? color) {
    groupColorValue = color?.value;
  }

  /// Yeni bir kopya oluşturur, sadece verilen alanları değiştirir
  NodeModel copyWith({
    String? id,
    String? title,
    double? posX,
    double? posY,
    int? groupColorValue,
    String? noteType,
  }) {
    return NodeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      posX: posX ?? this.posX,
      posY: posY ?? this.posY,
      groupColorValue: groupColorValue ?? this.groupColorValue,
      noteType: noteType ?? this.noteType,
    );
  }

  /// Varsayılan node oluşturucu (fabrika)
  factory NodeModel.createDefault({
    required String id,
    required Offset offset,
  }) {
    return NodeModel(
      id: id,
      title: "Yeni Not",
      posX: offset.dx,
      posY: offset.dy,
      groupColorValue: Colors.blue.value,
      noteType: "idea",
    );
  }
}
