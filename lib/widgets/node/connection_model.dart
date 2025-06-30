import 'package:hive/hive.dart';

part 'connection_model.g.dart';

@HiveType(typeId: 4)
class ConnectionModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String fromId;

  @HiveField(2)
  String toId;

  @HiveField(3)
  String type; // örnek: 'normal', 'dashed', 'strong'

  ConnectionModel({
    required this.id,
    required this.fromId,
    required this.toId,
    this.type = 'normal',
  });
}
