import 'package:hive/hive.dart';
import 'type.dart';

class SavingsTransactionAdapter extends TypeAdapter<SavingsTransaction> {
  @override
  final int typeId = 0;  // Her adapter için benzersiz olmalı

  @override
  SavingsTransaction read(BinaryReader reader) {
    final title = reader.readString();
    final amount = reader.readDouble();
    final date = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final type = reader.readString();
    final currency = reader.readString();

    return SavingsTransaction(
      title: title,
      amount: amount,
      date: date,
      type: type,
      currency: currency,
    );
  }

  @override
  void write(BinaryWriter writer, SavingsTransaction obj) {
    writer.writeString(obj.title);
    writer.writeDouble(obj.amount);
    writer.writeInt(obj.date.millisecondsSinceEpoch);
    writer.writeString(obj.type);
    writer.writeString(obj.currency);
  }
}
