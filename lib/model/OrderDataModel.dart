import 'package:hive/hive.dart';

@HiveType(typeId: 1) // Unique typeId for OrderDataModel
class OrderDataModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String merchant;
  @HiveField(2)
  final String amount;
  @HiveField(3)
  final String state;
  @HiveField(4)
  final String tradeNumber;
  @HiveField(5)
  final String createdAt;

  OrderDataModel({
    required this.id,
    required this.merchant,
    required this.amount,
    required this.state,
    required this.tradeNumber,
    required this.createdAt,
  });

  factory OrderDataModel.fromJson(Map<String, dynamic> json) {
    return OrderDataModel(
      id: json['_id'] ?? '',
      merchant: json['merchant'] ?? '',
      amount: json['amount'] ?? '',
      state: json['state'] ?? '',
      tradeNumber: json['tradeNumber'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}

// Create an adapter for OrderDataModel with a unique typeId (e.g., 1)
class OrderDataModelAdapter extends TypeAdapter<OrderDataModel> {
  @override
  final int typeId = 1; // Unique typeId for OrderDataModel

  @override
  OrderDataModel read(BinaryReader reader) {
    final id = reader.read() as String;
    final merchant = reader.read() as String;
    final amount = reader.read() as String;
    final state = reader.read() as String;
    final tradeNumber = reader.read() as String;
    final createdAt = reader.read() as String;

    return OrderDataModel(
      id: id,
      merchant: merchant,
      amount: amount,
      state: state,
      tradeNumber: tradeNumber,
      createdAt: createdAt,
    );
  }

  @override
  void write(BinaryWriter writer, OrderDataModel obj) {
    writer.write(obj.id);
    writer.write(obj.merchant);
    writer.write(obj.amount);
    writer.write(obj.state);
    writer.write(obj.tradeNumber);
    writer.write(obj.createdAt);
  }
}
