import 'package:hive_flutter/hive_flutter.dart';

import '../../types/type.dart';

class ExpenseAdapter extends TypeAdapter<Expense> {
  @override
  final int typeId = 2;

  @override
  Expense read(BinaryReader reader) {
    final id = reader.readString();
    final title = reader.readString();
    final amount = reader.readDouble();
    final millis = reader.readInt();
    final date = DateTime.fromMillisecondsSinceEpoch(millis);
    final category = reader.readString();

    return Expense(
      id: id,
      title: title,
      amount: amount,
      date: date,
      category: category,
    );
  }

  @override
  void write(BinaryWriter writer, Expense obj) {
    writer.writeString(obj.id);
    writer.writeString(obj.title);
    writer.writeDouble(obj.amount);
    writer.writeInt(obj.date.millisecondsSinceEpoch);
    writer.writeString(obj.category);
  }
}
