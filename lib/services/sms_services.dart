import 'package:expense_tracker/models/transaction_model.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:intl/intl.dart';

class SmsService {
  // Existing regex patterns
  final RegExp _transactionRegex1 = RegExp(
    r"Dear\s+(UPI|SBI|AXIS|HDFC|ICICI|.*)\s+user.*?(debited|credited)\s+by\s+(Rs\.)?\s*(\d+\.\d+|\d+)\s+on\s+(date\s+)?(\d+\w+\d+)\s+(trf\s+to|transfer\s+from)\s+([\w\s]+)\s+Ref\s*No\s*\d+.*-(\w+)",
    caseSensitive: false,
  );

  final RegExp _transactionRegex2 = RegExp(
    r"Your\s+a\/c\s+no\.\s+\w+.*?linked\s+to\s+UPI\s+ID\s+(\w+@\w+)\s+is\s+(debited|credited)\s+for\s+Rs\.\s*(\d+\.\d+)\s+on\s+([\d-]{10})\s+(\d{2}:\d{2}:\d{2})\s*\(UPI\s+Ref\s+no\s+(\w+)\)\s*-\s*(\w+)",
    caseSensitive: false,
  );

  final RegExp _transactionRegex3 = RegExp(
    r"You\s+have\s+received\s+a\s+payment\s+of\s+Rs\.\s*(\d+\.\d+)\s+in\s+a\/c\s+\w+.*?\s+on\s+(\d{2}\/\d{2}\/\d{4})\s+(\d{2}:\d{2})\s+from\s+([\w\s]+)\s+.*?Info:\s+UPI\/CREDIT\/\d+\.\s*-(\w+)",
    caseSensitive: false,
  );

  final RegExp _transactionRegex4 = RegExp(
    r"Your\s+a\/c\s+no\.\s+\w+.*?linked\s+to\s+UPI\s+ID\s+(\w+@\w+)\s+is\s+(debited|credited)\s+for\s+Rs\.\s*(\d+\.\d+)\s+on\s+(\d{2}-\d{2}-\d{4})\s+(\d{2}:\d{2}:\d{2})\s+\(UPI\s+Ref\s+no\s+(\\w+)\)\s*-\s*(\w+)",
    caseSensitive: false,
  );

  // New regex patterns for Kotak Bank transactions
  final RegExp _transactionRegex5 = RegExp(
    r"Received\s+Rs\.(\d+\.\d+)\s+in\s+your\s+Kotak\s+Bank\s+AC\s+\w+\s+from\s+(\w+@\w+)\s+on\s+(\d{2}-\d{2}-\d{2})\.\s*UPI\s+Ref:(\d+)\.",
    caseSensitive: false,
  );

  final RegExp _transactionRegex6 = RegExp(
    r"Sent\s+Rs\.(\d+\.\d+)\s+from\s+Kotak\s+Bank\s+AC\s+\w+\s+to\s+(\w+@\w+)\s+on\s+(\d{2}-\d{2}-\d{2})\.\s*UPI\s+Ref\s+(\d+)\.\s*Not\s+you,\s+kotak\.com\/fraud",
    caseSensitive: false,
  );

  final RegExp _transactionRegex7 = RegExp(
    r'Rs\.(\d+(?:\.\d{1,2})?)\s(?:Credited|transferred from A/c .+?)(?:\s.*?UPI/\d+)?\s.*?Total Bal:Rs\.(\d+(?:\.\d{1,2})?)CR.*?\((\d{2}-\d{2}-\d{4}\s\d{2}:\d{2}:\d{2})\)',
    caseSensitive: false,
  );

  Future<List<SmsMessage>> getMessages() async {
    SmsQuery query = SmsQuery();
    List<SmsMessage> messages = await query.querySms(
      kinds: [SmsQueryKind.inbox, SmsQueryKind.sent],
    );
    return messages;
  }

  List<TransactionModel> categorizeMessages(List<SmsMessage> messages) {
    List<TransactionModel> transactions = [];

    for (var message in messages) {
      if (_isTransactionMessage(message.body)) {
        final match1 = _transactionRegex1.firstMatch(message.body!);
        final match2 = _transactionRegex2.firstMatch(message.body!);
        final match3 = _transactionRegex3.firstMatch(message.body!);
        final match4 = _transactionRegex4.firstMatch(message.body!);
        final match5 = _transactionRegex5.firstMatch(message.body!);
        final match6 = _transactionRegex6.firstMatch(message.body!);
        final match7 = _transactionRegex7.firstMatch(message.body!);

        if (match1 != null) {
          transactions.add(_parseTransactionFromMatch1(match1,message.date!));
        } else if (match2 != null) {
          transactions.add(_parseTransactionFromMatch2(match2,message.date!));
        } else if (match3 != null) {
          transactions.add(_parseTransactionFromMatch3(match3,message.date!));
        } else if (match4 != null) {
          transactions.add(_parseTransactionFromMatch4(match4,message.date!));
        } else if (match5 != null) {
          transactions.add(_parseTransactionFromMatch5(match5,message.date!));
        } else if (match6 != null) {
          transactions.add(_parseTransactionFromMatch6(match6,message.date!));
        } else if (match7 != null) {
          transactions.add(_parseTransactionFromMatch7(match7,message.date!));
        }
      }
    }

    return transactions;
  }

  bool _isTransactionMessage(String? message) {
    if (message == null) return false;
    return _transactionRegex1.hasMatch(message) ||
        _transactionRegex2.hasMatch(message) ||
        _transactionRegex3.hasMatch(message) ||
        _transactionRegex4.hasMatch(message) ||
        _transactionRegex5.hasMatch(message) ||
        _transactionRegex6.hasMatch(message) ||
        _transactionRegex7.hasMatch(message);
  }


  // Existing parsing methods for older patterns...
  TransactionModel _parseTransactionFromMatch1(RegExpMatch match, DateTime messageDate) {
    String source = match.group(1)!;
    String transactionType = match.group(2)!;
    double amount = double.parse(match.group(4)!);
    String date = DateFormat('yyyy-MM-dd').format(messageDate);  // Save only the date
    String time = DateFormat('HH:mm:ss').format(messageDate);    // Save only the time
    String recipient = match.group(8)!;
    String bankName = match.group(9)!;

    return TransactionModel(
      source: source,
      transactionType: transactionType,
      amount: amount,
      date: date,
      time: time,
      recipient: recipient,
      bankName: bankName,
    );
  }

  TransactionModel _parseTransactionFromMatch2(RegExpMatch match, DateTime messageDate) {
    String source = match.group(1)!;
    String transactionType = match.group(2)!;
    double amount = double.parse(match.group(3)!);
    String date = DateFormat('yyyy-MM-dd').format(messageDate);  // Save only the date
    String time = DateFormat('HH:mm:ss').format(messageDate);
    String recipient = ''; // Adjust if needed
    String bankName = match.group(6)!;

    return TransactionModel(
      source: source,
      transactionType: transactionType,
      amount: amount,
      date: date,
      time: time,
      recipient: recipient,
      bankName: bankName,
    );
  }

  TransactionModel _parseTransactionFromMatch3(RegExpMatch match, DateTime messageDate) {
    double amount = double.parse(match.group(1)!);
    String date = DateFormat('yyyy-MM-dd').format(messageDate);  // Save only the date
    String time = DateFormat('HH:mm:ss').format(messageDate);
    String recipient = match.group(4)!;
    String bankName = match.group(5)!;

    return TransactionModel(
      source: 'UPI', // Adjust if needed
      transactionType: 'credited', // Adjust if needed
      amount: amount,
      date: date,
      time: time,
      recipient: recipient,
      bankName: bankName,
    );
  }

  TransactionModel _parseTransactionFromMatch4(RegExpMatch match, DateTime messageDate) {
    String source = match.group(1)!;
    String transactionType = match.group(2)!;
    double amount = double.parse(match.group(3)!);
    String date = DateFormat('yyyy-MM-dd').format(messageDate);  // Save only the date
    String time = DateFormat('HH:mm:ss').format(messageDate);
    String recipient = ''; // Adjust if needed
    String bankName = match.group(7)!;

    return TransactionModel(
      source: source,
      transactionType: transactionType,
      amount: amount,
      date: date,
      time: time,
      recipient: recipient,
      bankName: bankName,
    );
  }

  // New parsing methods for Kotak Bank and Bank of Baroda patterns
  TransactionModel _parseTransactionFromMatch5(RegExpMatch match, DateTime messageDate) {
    double amount = double.parse(match.group(1)!);
    String recipient = match.group(2)!;
    String date = DateFormat('yyyy-MM-dd').format(messageDate);  // Save only the date
    String time = DateFormat('HH:mm:ss').format(messageDate);
    String reference = match.group(4)!;

    return TransactionModel(
      source: 'Kotak Bank',
      transactionType: 'credited',
      amount: amount,
      date: date,
      time: time,
      recipient: recipient,
      bankName: reference,
    );
  }

  TransactionModel _parseTransactionFromMatch6(RegExpMatch match, DateTime messageDate) {
    double amount = double.parse(match.group(1)!);
    String recipient = match.group(2)!;
    String date = DateFormat('yyyy-MM-dd').format(messageDate);  // Save only the date
    String time = DateFormat('HH:mm:ss').format(messageDate);
    String reference = match.group(4)!;

    return TransactionModel(
      source: 'Kotak Bank',
      transactionType: 'debited',
      amount: amount,
      date: date,
      time: time,
      recipient: recipient,
      bankName: reference,
    );
  }

  TransactionModel _parseTransactionFromMatch7(RegExpMatch match, DateTime messageDate) {
    double amount = double.parse(match.group(1)!);
    String balance = match.group(2)!;
    String date = match.group(3)!;

    // Determine if the message is credited or transferred
    String transactionType = match.group(0)!.contains('Credited') ? 'credited' : 'debited';

    return TransactionModel(
      source: 'Bank of Baroda',
      transactionType: transactionType,
      amount: amount,
      date: DateFormat('yyyy-MM-dd').format(messageDate),
      time: DateFormat('HH:mm:ss').format(messageDate),
      recipient: '', // Adjust if needed
      bankName: 'Bank of Baroda',
    );
  }
}
