import 'package:expense_tracker/ads/admanager.dart';
import 'package:expense_tracker/database/db_helper.dart';
import 'package:expense_tracker/models/transaction_model.dart';
import 'package:expense_tracker/screens/alltransaction.dart';
import 'package:expense_tracker/services/sms_services.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;

  double _totalCredit = 0.0;
  double _totalDebit = 0.0;
  String _currentDate = '';


  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _loadDailyTotals();
  }

  Future<void> _loadDailyTotals() async {
    final dbHelper = DbHelper();
    final dailyTotals = await dbHelper.getDailyTotals();

    setState(() {
      _totalCredit = dailyTotals['totalCredit'];
      _totalDebit = dailyTotals['totalDebit'];
      _currentDate = dailyTotals['currentDate'];
    });
  }

  Future<void> _checkPermissions() async {
    var status = await Permission.sms.status;
    if (status.isGranted) {
      await _fetchMessages();
    } else if (status.isDenied) {
      await Permission.sms.request();
      _checkPermissions();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> _fetchMessages() async {
    try {
      SmsService smsService = SmsService();
      List<SmsMessage> messages = await smsService.getMessages();
      List<TransactionModel> transactions = smsService.categorizeMessages(messages);

      int duplicateCount = 0;

      for (var transaction in transactions) {
        bool isDuplicate = await DbHelper().isDuplicateTransaction(transaction);

        if (isDuplicate) {
          duplicateCount++;
          if (duplicateCount > 5) {
            print("More than 5 duplicates found. Stopping further checks.");
            break;
          }
        } else {
          await DbHelper().insertTransaction(transaction);
        }
      }

      // Load transactions from the database regardless of duplicate count
      await _loadTransactions();

    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error fetching SMS: $e");
    }
  }

  Future<void> _loadTransactions() async {
    try {
      List<TransactionModel> transactions = await DbHelper().getTransactions();
      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error loading transactions: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalAmount = _totalCredit + _totalDebit; // Calculate total amount for ratio
    double creditRatio = totalAmount > 0 ? _totalCredit / totalAmount : 0; // Credit percentage

    return Scaffold(
      backgroundColor: Colors.white, // Light grey background for the entire page
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        backgroundColor: Colors.white, // Darker AppBar color
        elevation: 0, // Remove shadow for a flatter design
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Credit vs Debit',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[800],
                        ),
                      ),
                      Text(
                        '${(creditRatio * 100).toStringAsFixed(1)}% Credit',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10), // Rounded corners for the indicator
                    child: LinearProgressIndicator(
                      value: creditRatio, // Ratio of credit to the total amount
                      backgroundColor: Colors.red.withOpacity(0.3), // Background representing debit
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.green), // Progress representing credit
                      minHeight: 10, // Adjust height for better visibility
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTotalBox('Total Credit', _totalCredit, Colors.green, Icons.arrow_upward),
                  const SizedBox(width: 8),
                  _buildTotalBox('Total Debit', _totalDebit, Colors.red, Icons.arrow_downward),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.all(12.0), // Outer margin for spacing
              padding: const EdgeInsets.all(16.0), // Inner padding for content
              decoration: BoxDecoration(
                color: Colors.white, // White background
                borderRadius: BorderRadius.circular(10), // Rounded corners
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2), // Slight shadow for depth
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3), // Shadow positioning
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Make the Column height intrinsic
                crossAxisAlignment: CrossAxisAlignment.start, // Align the label to the left
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Transactions',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          AdManager.showRewardedAd(context, () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AllTransactionsPage(),
                              ),
                            );
                          });
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          foregroundColor: Colors.blue,
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Colors.blue, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text(
                          'See All',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12), // Add space between the label and list
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _transactions.isEmpty
                      ? const Center(child: Text('No transactions found.'))
                      : ListView.builder(
                    shrinkWrap: true, // Make ListView take only as much space as its items
                    physics: const NeverScrollableScrollPhysics(), // Disable ListView's scrolling
                    itemCount: _transactions.length > 5 ? 5 : _transactions.length, // Display only the first 5 transactions
                    itemBuilder: (context, index) {
                      final transaction = _transactions[index];
        
                      // Determine the correct bank icon
                      String bankIcon = 'assets/icons/default_bank128.png'; // Default icon
                      if (transaction.bankName.toLowerCase() == 'sbi') {
                        bankIcon = 'assets/icons/sbi128.png';
                      } else if (transaction.bankName.toLowerCase() == 'ippb') {
                        bankIcon = 'assets/icons/ippb128.png';
                      }
        
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0), // Space between items
                        child: ListTile(
                          leading: Image.asset(
                            transaction.transactionType.toLowerCase() == 'credited'
                                ? 'assets/icons/income128.png'
                                : 'assets/icons/spend128.png',
                            width: 32,
                            height: 32,
                          ),
                          title: Text(
                            transaction.recipient,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1, // Limit to a single line
                            overflow: TextOverflow.ellipsis, // Display ellipsis if text is too long
                            softWrap: false, // Prevent wrapping to next line
                          ),
                          subtitle: Text(
                            "${transaction.amount} ",
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                          trailing: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                bankIcon,
                                width: 24,  // Adjusted size for a more uniform look
                                height: 24,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "${transaction.date.toString().split(' ')[0]}",  // Show only the date
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


Widget _buildTotalBox(String label, double amount, Color color, IconData icon) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), // Light color for background
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 1.5), // Border with color
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                icon,
                color: color,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    ),
  );
}

