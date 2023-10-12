import 'package:hive/hive.dart';

@HiveType(typeId: 1) // Unique typeId for OrderDataModel
class Transaction {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String merchant;
  @HiveField(2)
  final String amount;
  @HiveField(3)
  final String state;
  @HiveField(4)
  final String createdAt;

  @HiveField(5)
  final String order;
  @HiveField(6)
  final String paymentMode;
  @HiveField(7)
  final String payerName;
  @HiveField(8)
  final String payerVPA;

  Transaction({
    required this.id,
    required this.merchant,
    required this.amount,
    required this.state,
    required this.createdAt,
    required this.order,
    required this.paymentMode,
    required this.payerName,
    required this.payerVPA,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['_id'] ?? '',
      merchant: json['merchant'] ?? '',
      order: json['order'] ?? '',
      amount: json['amount'] ?? '',
      state: json['state'] ?? '',
      paymentMode: json['paymentMode'] ?? '',
      payerName: json['payerName'] ?? '',
      payerVPA: json['payerVPA'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}

// Create an adapter for OrderDataModel with a unique typeId (e.g., 1)
class TransactionAdapter extends TypeAdapter<Transaction> {
  @override
  final int typeId = 6; // Unique typeId for OrderDataModel

  @override
  Transaction read(BinaryReader reader) {
    final id = reader.read() as String;
    final merchant = reader.read() as String;
    final amount = reader.read() as String;
    final state = reader.read() as String;
    final tradeNumber = reader.read() as String;
    final createdAt = reader.read() as String;

    final order = reader.read() as String;
    final paymentMode = reader.read() as String;
    final payerName = reader.read() as String;
    final payerVPA = reader.read() as String;

    return Transaction(
      id: id,
      merchant: merchant,
      amount: amount,
      state: state,
      createdAt: createdAt,
      order: order,
      payerName: payerName,
      payerVPA: payerVPA,
      paymentMode: paymentMode,
    );
  }

  @override
  void write(BinaryWriter writer, Transaction obj) {
    writer.write(obj.id);
    writer.write(obj.merchant);
    writer.write(obj.amount);
    writer.write(obj.state);
    writer.write(obj.createdAt);
    writer.write(obj.order);
    writer.write(obj.payerName);
    writer.write(obj.payerVPA);
    writer.write(obj.paymentMode);
  }
}
