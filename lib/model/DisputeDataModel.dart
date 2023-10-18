
import 'package:hive/hive.dart';

@HiveType(typeId: 4)
class DisputeDataModel {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String merchant;
  @HiveField(2)
  final String amount;
  @HiveField(3)
  final int amountNum;
  @HiveField(4)
  final String disputeType;
  @HiveField(5)
  final String complainNumber;
  @HiveField(6)
  final String deadline;
  @HiveField(7)
  final String description;
  @HiveField(8)
  final String complainantsName;
  @HiveField(9)
  final String complainantsPhone;
  @HiveField(10)
  final String complainantsEmail;
  @HiveField(11)
  final String complainantsAccountNo;
  @HiveField(12)
  final String complainantsIfsc;
  @HiveField(13)
  final String transaction;
  @HiveField(14)
  final String state;
  @HiveField(15)
  final String createdAt;
  @HiveField(16)
  final String updatedAt;

  DisputeDataModel(
      {required this.id,
      required this.merchant,
      required this.amount,
      required this.amountNum,
      required this.disputeType,
      required this.createdAt,
      required this.complainNumber,
      required this.deadline,
      required this.description,
      required this.complainantsName,
      required this.complainantsPhone,
      required this.complainantsEmail,
      required this.complainantsAccountNo,
      required this.complainantsIfsc,
      required this.transaction,
      required this.state,
      required this.updatedAt});

  factory DisputeDataModel.fromJson(Map<String, dynamic> json) {
    return DisputeDataModel(
      id: json['_id'] ?? '',
      merchant: json['merchant'] ?? '',
      amount: json['amount'] ?? '',
      disputeType: json['disputeType'] ?? '',
      createdAt: json['createdAt'] ?? '',
      state: json['state'] ?? '',
      deadline: json['deadline'] ?? '',
      description: json['description'] ?? '',
      amountNum: json['amountNum'] ?? '',
      complainantsName: json['complainantsName'] ?? '',
      complainantsPhone: json['complainantsPhone'] ?? '',
      complainantsEmail: json['complainantsEmail'] ?? '',
      complainantsAccountNo: json['complainantsAccountNo'] ?? '',
      complainantsIfsc: json['complainantsIfsc'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      complainNumber: json['complainNumber'] ?? '',
      transaction: json['transaction'] ?? '',
    );
  }
}

// Create an adapter for MyModel with a unique typeId (e.g., 0)
class DisputeDataAdapter extends TypeAdapter<DisputeDataModel> {
  @override
  final int typeId = 4; // Unique typeId for DisputeDataModel

  @override
  DisputeDataModel read(BinaryReader reader) {
    final id = reader.read() as String;
    final merchant = reader.read() as String;
    final amount = reader.read() as String;
    final amountNum = reader.read() as int;
    final disputeType = reader.read() as String;
    final createdAt = reader.read() as String;
    final state = reader.read() as String;
    final deadline = reader.read() as String;
    final description = reader.read() as String;
    final complainantsName = reader.read() as String;
    final complainantsPhone = reader.read() as String;
    final complainantsEmail = reader.read() as String;
    final complainantsAccountNo = reader.read() as String;
    final complainantsIfsc = reader.read() as String;
    final updatedAt = reader.read() as String;
    final complainNumber = reader.read() as String;
    final transaction = reader.read() as String;

    return DisputeDataModel(
      id: id,
      merchant: merchant,
      amount: amount,
      amountNum: amountNum,
      disputeType: disputeType,
      createdAt: createdAt,
      state: state,
      deadline: deadline,
      description: description,
      complainantsName: complainantsName,
      complainantsPhone: complainantsPhone,
      complainantsEmail: complainantsEmail,
      complainantsAccountNo: complainantsAccountNo,
      complainantsIfsc: complainantsIfsc,
      updatedAt: updatedAt,
      complainNumber: complainNumber,
      transaction: transaction,
    );
  }

  @override
  void write(BinaryWriter writer, DisputeDataModel obj) {
    writer.write(obj.id);
    writer.write(obj.merchant);
    writer.write(obj.amount);
    writer.write(obj.amountNum);
    writer.write(obj.disputeType);
    writer.write(obj.createdAt);
    writer.write(obj.state);
    writer.write(obj.deadline);
    writer.write(obj.description);
    writer.write(obj.complainantsName);
    writer.write(obj.complainantsPhone);
    writer.write(obj.complainantsEmail);
    writer.write(obj.complainantsAccountNo);
    writer.write(obj.complainantsIfsc);
    writer.write(obj.updatedAt);
    writer.write(obj.complainNumber);
    writer.write(obj.transaction);
  }
}
