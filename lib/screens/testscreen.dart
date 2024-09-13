import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';

class SmsMessagesScreen extends StatefulWidget {
  @override
  _SmsMessagesScreenState createState() => _SmsMessagesScreenState();
}

class _SmsMessagesScreenState extends State<SmsMessagesScreen> {
  List<SmsMessage> _messages = [];
  bool _isLoading = false;

  // Updated regex to capture both credited and transferred messages from Bank of Baroda
  final RegExp _bankOfBarodaRegex = RegExp(
    r'Rs\.(\d+(?:\.\d{1,2})?)\s(?:Credited|transferred from A/c .+?)(?:\s.*?UPI/\d+)?\s.*?Total Bal:Rs\.(\d+(?:\.\d{1,2})?)CR.*?\((\d{2}-\d{2}-\d{4}\s\d{2}:\d{2}:\d{2})\)',
    caseSensitive: false,
  );

  @override
  void initState() {
    super.initState();
    _fetchSmsMessages();
  }

  Future<void> _fetchSmsMessages() async {
    setState(() {
      _isLoading = true;
    });

    SmsQuery query = SmsQuery();
    List<SmsMessage> messages = await query.querySms(
      kinds: [SmsQueryKind.inbox], // Only fetch inbox messages
    );

    // Filter messages using regex for "Bank of Baroda"
    List<SmsMessage> filteredMessages = messages
        .where((message) =>
    message.body != null && _bankOfBarodaRegex.hasMatch(message.body!))
        .toList();

    // Print the matched messages to the console
    for (var message in filteredMessages) {
      var match = _bankOfBarodaRegex.firstMatch(message.body!);
      if (match != null) {
        String amount = match.group(1)!;
        String balance = match.group(2)!;
        String date = match.group(3)!;

        // Determine if the message is credited or transferred
        String transactionType = message.body!.contains('Credited') ? 'Credited' : 'transferred from A/c';

        print(
            "From: ${message.address}, Message: Rs.$amount $transactionType, Balance: Rs.$balance, Date: $date");
      }
    }

    setState(() {
      _messages = filteredMessages;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bank of Baroda SMS Messages'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _messages.isEmpty
          ? Center(child: Text('No Bank of Baroda messages found'))
          : ListView.builder(
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          SmsMessage message = _messages[index];
          var match = _bankOfBarodaRegex.firstMatch(message.body!);
          if (match != null) {
            String amount = match.group(1)!;
            String balance = match.group(2)!;
            String date = match.group(3)!;
            String transactionType = message.body!.contains('Credited') ? 'Credited' : 'transferred from A/c';

            return ListTile(
              title: Text('${message.address ?? 'Unknown Sender'}'),
              subtitle: Text(
                  'Rs.$amount $transactionType\nBalance: Rs.$balance\nDate: $date'),
            );
          }
          return SizedBox.shrink(); // If no match, return an empty widget
        },
      ),
    );
  }
}
