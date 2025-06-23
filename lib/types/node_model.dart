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

  NodeModel({
    required this.id,
    required this.title,
    required this.posX,
    required this.posY,
  });

  NodeModel copyWith({String? id, String? title, double? posX, double? posY}) {
    return NodeModel(
      id: id ?? this.id,
      title: title ?? this.title,
      posX: posX ?? this.posX,
      posY: posY ?? this.posY,
    );
  }
}
