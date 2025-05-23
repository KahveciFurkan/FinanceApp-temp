import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../types/type.dart';

class SubscriptionAdapter extends TypeAdapter<Subscription> {
  @override
  final int typeId = 1;

  @override
  Subscription read(BinaryReader reader) {
    final name = reader.readString();
    final price = reader.readDouble();
    final renewDate = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final category = reader.readString();
    final iconCodePoint = reader.readInt();
    final colorValue = reader.readInt();
    final isFrozen = reader.readBool();
    final isPaid = reader.readBool();

    // paidMonth null olabilir, bu yüzden önce bool ile kontrol ediyoruz
    final hasPaidMonth = reader.readBool();
    final paidMonth =
        hasPaidMonth
            ? DateTime.fromMillisecondsSinceEpoch(reader.readInt())
            : null;

    return Subscription(
      name: name,
      price: price,
      renewDate: renewDate,
      category: category,
      iconCodePoint: iconCodePoint,
      colorValue: colorValue,
      isFrozen: isFrozen,
      isPaid: isPaid,
      paidMonth: paidMonth,
    );
  }

  @override
  void write(BinaryWriter writer, Subscription obj) {
    writer.writeString(obj.name);
    writer.writeDouble(obj.price);
    writer.writeInt(obj.renewDate.millisecondsSinceEpoch);
    writer.writeString(obj.category);
    writer.writeInt(obj.iconCodePoint);
    writer.writeInt(obj.colorValue);
    writer.writeBool(obj.isFrozen);
    writer.writeBool(obj.isPaid);

    // paidMonth null olabilir
    writer.writeBool(obj.paidMonth != null);
    if (obj.paidMonth != null) {
      writer.writeInt(obj.paidMonth!.millisecondsSinceEpoch);
    }
  }
}
