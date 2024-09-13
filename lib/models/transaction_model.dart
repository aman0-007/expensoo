class TransactionModel {
  final int? id;
  final String source;
  final String transactionType;
  final double amount;
  final String date;
  final String time;
  final String recipient;
  final String bankName;

  TransactionModel({
    this.id,
    required this.source,
    required this.transactionType,
    required this.amount,
    required this.date,
    required this.time,
    required this.recipient,
    required this.bankName,
  });

  // Convert a TransactionModel into a Map object
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'source': source,
      'transactionType': transactionType,
      'amount': amount,
      'date': date,
      'time': time,
      'recipient': recipient,
      'bankName': bankName,
    };
  }

  // Convert a Map object into a TransactionModel
  static TransactionModel fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      source: map['source'],
      transactionType: map['transactionType'],
      amount: map['amount'],
      date: map['date'],
      time: map['time'],
      recipient: map['recipient'],
      bankName: map['bankName'],
    );
  }
}
