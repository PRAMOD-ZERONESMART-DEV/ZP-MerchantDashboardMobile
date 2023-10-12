import 'package:hive/hive.dart';

@HiveType(typeId: 3) // Unique typeId for RefundDataModel
class RefundDataModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String transaction;
  @HiveField(2)
  final String amount;
  @HiveField(3)
  final String state;
  @HiveField(4)
  final String createdAt;
  @HiveField(5)
  final String updatedAt;
  @HiveField(6)
  final String refundReason;
  @HiveField(7)
  final String raisedBy;
  @HiveField(8)
  final int amountNum;

  RefundDataModel({
    required this.id,
    required this.amount,
    required this.transaction,
    required this.state,
    required this.createdAt,
    required this.updatedAt,
    required this.refundReason,
    required this.raisedBy,
    required this.amountNum,
  });

  factory RefundDataModel.fromJson(Map<String, dynamic> json) {
    return RefundDataModel(
      id: json['_id'] ?? '',
      transaction: json['transaction'] ?? '',
      amount: json['amount'] ?? '',
      state: json['state'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      refundReason: json['refundReason'] ?? '',
      raisedBy: json['raisedBy'] ?? '',
      amountNum: json['amountNum'] ?? 0, // Default to 0 if not provided
    );
  }
}

// Create an adapter for RefundDataModel with a unique typeId (e.g., 2)
class RefundDataModelAdapter extends TypeAdapter<RefundDataModel> {
  @override
  final int typeId = 3; // Unique typeId for RefundDataModel

  @override
  RefundDataModel read(BinaryReader reader) {
    final id = reader.read() as String;
    final transaction = reader.read() as String;
    final amount = reader.read() as String;
    final state = reader.read() as String;
    final createdAt = reader.read() as String;
    final updatedAt = reader.read() as String;
    final refundReason = reader.read() as String;
    final raisedBy = reader.read() as String;
    final amountNum = reader.read() as int;

    return RefundDataModel(
      id: id,
      transaction: transaction,
      amount: amount,
      state: state,
      createdAt: createdAt,
      updatedAt: updatedAt,
      refundReason: refundReason,
      raisedBy: raisedBy,
      amountNum: amountNum,
    );
  }

  @override
  void write(BinaryWriter writer, RefundDataModel obj) {
    writer.write(obj.id);
    writer.write(obj.transaction);
    writer.write(obj.amount);
    writer.write(obj.state);
    writer.write(obj.createdAt);
    writer.write(obj.updatedAt);
    writer.write(obj.refundReason);
    writer.write(obj.raisedBy);
    writer.write(obj.amountNum);
  }
}
