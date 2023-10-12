import 'package:hive/hive.dart';

@HiveType(typeId: 2) // Unique typeId for SettlementDataModel
class SettlementDataModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String merchant;
  @HiveField(2)
  final String amount;
  @HiveField(3)
  final String yppReferenceNumber;
  @HiveField(4)
  final String txnStatus;
  @HiveField(5)
  final String createdAt;
  @HiveField(6)
  final String utr;
  @HiveField(7)
  final String Mode;
  @HiveField(8)
  final int amountNum;
  @HiveField(9)
  final String failureReason;
  @HiveField(10)
  final String initiationDate;

  SettlementDataModel({
    required this.id,
    required this.merchant,
    required this.amount,
    required this.yppReferenceNumber,
    required this.txnStatus,
    required this.createdAt,
    required this.utr,
    required this.Mode,
    required this.amountNum,
    required this.failureReason,
    required this.initiationDate,
  });

  factory SettlementDataModel.fromJson(Map<String, dynamic> json) {
    return SettlementDataModel(
      id: json['_id'] ?? '',
      merchant: json['merchant'] ?? '',
      amount: json['amount'] ?? '',
      yppReferenceNumber: json['yppReferenceNumber'] ?? '',
      txnStatus: json['txnStatus'] ?? '',
      createdAt: json['createdAt'] ?? '',
      utr: json['utr'] ?? '',
      Mode: json['Mode'] ?? '',
      amountNum: json['amountNum'] ?? 0,
      // Default to 0 if not provided
      failureReason: json['failureReason'] ?? '',
      initiationDate: json['initiationDate'] ?? '',
    );
  }
}

// Create an adapter for SettlementDataModel with a unique typeId (e.g., 3)
class SettlementDataModelAdapter extends TypeAdapter<SettlementDataModel> {
  @override
  final int typeId = 2; // Unique typeId for SettlementDataModel

  @override
  SettlementDataModel read(BinaryReader reader) {
    final id = reader.read() as String;
    final merchant = reader.read() as String;
    final amount = reader.read() as String;
    final yppReferenceNumber = reader.read() as String;
    final txnStatus = reader.read() as String;
    final createdAt = reader.read() as String;
    final utr = reader.read() as String;
    final Mode = reader.read() as String;
    final amountNum = reader.read() as int;
    final failureReason = reader.read() as String;
    final initiationDate = reader.read() as String;

    return SettlementDataModel(
      id: id,
      merchant: merchant,
      amount: amount,
      yppReferenceNumber: yppReferenceNumber,
      txnStatus: txnStatus,
      createdAt: createdAt,
      utr: utr,
      Mode: Mode,
      amountNum: amountNum,
      failureReason: failureReason,
      initiationDate: initiationDate,
    );
  }

  @override
  void write(BinaryWriter writer, SettlementDataModel obj) {
    writer.write(obj.id);
    writer.write(obj.merchant);
    writer.write(obj.amount);
    writer.write(obj.yppReferenceNumber);
    writer.write(obj.txnStatus);
    writer.write(obj.createdAt);
    writer.write(obj.utr);
    writer.write(obj.Mode);
    writer.write(obj.amountNum);
    writer.write(obj.failureReason);
    writer.write(obj.initiationDate);
  }
}
