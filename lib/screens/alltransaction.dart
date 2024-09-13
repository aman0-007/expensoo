import 'package:expense_tracker/ads/admanager.dart';
import 'package:expense_tracker/bankicons/bankicons.dart';
import 'package:expense_tracker/database/db_helper.dart';
import 'package:expense_tracker/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';

class AllTransactionsPage extends StatefulWidget {

  const AllTransactionsPage({Key? key}) : super(key: key);

  @override
  _AllTransactionsPageState createState() => _AllTransactionsPageState();
}

class _AllTransactionsPageState extends State<AllTransactionsPage> {
  List<TransactionModel> _filteredTransactions = [];
  List<TransactionModel> _allTransactions = [];
  List<DateTime?> _dates = [];

  @override
  void initState() {
    super.initState();
    _filteredTransactions = _allTransactions;
    _fetchTransactions();
    AdManager.loadRewardedAd(); // Load ad when this screen is initialized
    AdManager.loadInterstitialAd();
  }

  @override
  void dispose() {
    // Call showInterstitialAd before the page is disposed (removed)
    AdManager.showInterstitialAd(context, () {
      // Callback after the interstitial ad is closed
      print("Interstitial ad closed, now disposing the page.");
      super.dispose(); // Dispose the page after the ad is closed
    });
  }

  Future<void> _fetchTransactions() async {
    try {
      // Assuming you have a method getTransactions() in a service class
      final transactions = await DbHelper().getTransactions();
      setState(() {
        _allTransactions = transactions;
        _filteredTransactions = _allTransactions;
      });
    } catch (e) {
      // Handle the error (e.g., show a message to the user)
      print('Error fetching transactions: $e');
    }
  }

  Future<Map<String, double>> _fetchTotalsByBank(String bankName) async {
    final totals = await DbHelper().getTotalsByBankName(bankName);

    // Print the totals for debugging
    print('Bank Name: $bankName');
    print('Fetched Totals: $totals');

    return totals;
  }


  void _filterTransactions(String filterType) async {
    if (filterType == 'Date') {
      String? dateFilterOption = await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0), // Rounded corners
            ),
            backgroundColor: Colors.white, // Set background color to white
            title: const Text(
              'Select Date Filter',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                color: Colors.black87, // Make title bold and darker color
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text(
                    'Get Previous',
                    style: TextStyle(
                      color: Colors.blueGrey, // Subtle color for options
                      fontSize: 16.0,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_back_ios, color: Colors.blueAccent), // Add trailing icon
                  onTap: () {
                    Navigator.of(context).pop('Previous');
                  },
                ),
                Divider(height: 1, color: Colors.grey[300]), // Add divider
                ListTile(
                  title: const Text(
                    'Get After',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 16.0,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
                  onTap: () {
                    Navigator.of(context).pop('After');
                  },
                ),
                Divider(height: 1, color: Colors.grey[300]),
                ListTile(
                  title: const Text(
                    'Get In Between',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 16.0,
                    ),
                  ),
                  trailing: const Icon(Icons.date_range, color: Colors.blueAccent),
                  onTap: () {
                    Navigator.of(context).pop('In Between');
                  },
                ),
              ],
            ),
          );
        },
      );

      if (dateFilterOption != null) {
        if (dateFilterOption == 'Previous' || dateFilterOption == 'After') {
          DateTime? selectedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );

          if (selectedDate != null) {
            setState(() {
              if (dateFilterOption == 'Previous') {
                _filteredTransactions = _allTransactions.where((transaction) {
                  DateTime transactionDate = DateTime.parse(transaction.date.toString());
                  return transactionDate.isBefore(selectedDate);
                }).toList();
              } else if (dateFilterOption == 'After') {
                _filteredTransactions = _allTransactions.where((transaction) {
                  DateTime transactionDate = DateTime.parse(transaction.date.toString());
                  return transactionDate.isAfter(selectedDate);
                }).toList();
              }
            });
          }
        } else if (dateFilterOption == 'In Between') {
          var results = await showCalendarDatePicker2Dialog(
            context: context,
            config: CalendarDatePicker2WithActionButtonsConfig(
              calendarType: CalendarDatePicker2Type.range,
              firstDayOfWeek: 1, // Monday
              selectedDayTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              selectedDayHighlightColor: Colors.purple[800],
              centerAlignModePicker: true,
              customModePickerIcon: const SizedBox(), // Custom icon or widget if needed
            ),
            dialogSize: const Size(325, 400),
            value: _dates,
            borderRadius: BorderRadius.circular(15),
          );

          if (results != null && results.length == 2) {
            DateTime startDate = results[0]!;
            DateTime endDate = results[1]!;

            setState(() {
              _filteredTransactions = _allTransactions.where((transaction) {
                DateTime transactionDate = DateTime.parse(transaction.date.toString());
                return transactionDate.isAfter(startDate) && transactionDate.isBefore(endDate);
              }).toList();
            });
          }
        }
      }
    }
    if (filterType == 'Bank') {
      // Extract unique banks from the transactions
      List<String> uniqueBanks = _allTransactions.map((t) => t.bankName).toSet().toList();

      // Await the showDialog to capture the selected bank
      final selectedBank = await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0), // Rounded corners
            ),
            backgroundColor: Colors.white, // Set background color to white
            title: const Text(
              'Select Bank',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                color: Colors.black87, // Bold title with a subtle color
              ),
            ),
            content: SingleChildScrollView(
              child: Wrap(
                spacing: 15, // Increased space between logos
                runSpacing: 15, // Increased space between rows
                alignment: WrapAlignment.center, // Center-align the items
                children: uniqueBanks.map((bankName) {
                  String bankIcon = getBankIcon(bankName); // Function to get the correct bank icon

                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop(bankName); // Close dialog and return bank name
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle, // Make the icon appear in a circle
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 5,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(bankIcon, width: 48, height: 48),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          bankName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey, // Softer color for text
                            fontSize: 14.0,
                          ),
                          textAlign: TextAlign.center, // Align text centrally
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      );

      // Filter transactions by the selected bank
      if (selectedBank != null) {
        setState(() {
          _filteredTransactions = _allTransactions.where((transaction) {
            return transaction.bankName == selectedBank;
          }).toList();
        });
      }
    }
    if (filterType == 'Amount') {
      // Show a dialog with three options
      String? amountFilterOption = await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0), // Rounded corners for a modern look
            ),
            backgroundColor: Colors.white, // White background for a clean appearance
            title: const Text(
              'Select Amount Filter',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
                color: Colors.black87, // Bold and subtle title color
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text(
                    'Get Greater Than',
                    style: TextStyle(
                      color: Colors.blueGrey, // Subtle color for text
                      fontSize: 16.0,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_upward, color: Colors.greenAccent), // Icon for emphasis
                  onTap: () {
                    Navigator.of(context).pop('Greater');
                  },
                ),
                Divider(height: 1, color: Colors.grey[300]), // Divider for better separation
                ListTile(
                  title: const Text(
                    'Get Less Than',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 16.0,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_downward, color: Colors.redAccent),
                  onTap: () {
                    Navigator.of(context).pop('Less');
                  },
                ),
                Divider(height: 1, color: Colors.grey[300]),
                ListTile(
                  title: const Text(
                    'Get In Between',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 16.0,
                    ),
                  ),
                  trailing: const Icon(Icons.compare_arrows, color: Colors.blueAccent),
                  onTap: () {
                    Navigator.of(context).pop('In Between');
                  },
                ),
              ],
            ),
          );
        },
      );
      if (amountFilterOption != null) {
        // Depending on the selected filter option, show the corresponding dialog
        if (amountFilterOption == 'Greater' || amountFilterOption == 'Less') {
          double? selectedAmount = await showAmountInputDialog(context);

          if (selectedAmount != null) {
            setState(() {
              if (amountFilterOption == 'Greater') {
                _filteredTransactions = _allTransactions.where((transaction) {
                  double amount = double.parse(transaction.amount.toString());
                  return amount > selectedAmount;
                }).toList();
              } else if (amountFilterOption == 'Less') {
                _filteredTransactions = _allTransactions.where((transaction) {
                  double amount = double.parse(transaction.amount.toString());
                  return amount < selectedAmount;
                }).toList();
              }
            });
          }
        } else if (amountFilterOption == 'In Between') {
          List<double>? selectedRange = await showAmountRangeDialog(context);

          if (selectedRange != null && selectedRange.length == 2) {
            double minAmount = selectedRange[0];
            double maxAmount = selectedRange[1];

            setState(() {
              _filteredTransactions = _allTransactions.where((transaction) {
                double amount = double.parse(transaction.amount.toString());
                return amount >= minAmount && amount <= maxAmount;
              }).toList();
            });
          }
        }
      }
    }
  }


  @override
  Widget build(BuildContext context) {

    List<String> uniqueBanks = _allTransactions.map((t) => t.bankName).toSet().toList();


    return Scaffold(
      appBar: AppBar(
        title: const Text('All Transactions'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _filterTransactions,
            itemBuilder: (context) {
              return [
                const PopupMenuItem(value: 'Date', child: Text('Filter by Date')),
                const PopupMenuItem(value: 'Bank', child: Text('Filter by Bank')),
                const PopupMenuItem(value: 'Amount', child: Text('Filter by Amount')),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.grey[200],
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: uniqueBanks.map((bankName) {
                  return FutureBuilder<Map<String, double>>(
                    future: _fetchTotalsByBank(bankName),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      } else if (snapshot.hasError) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Center(child: Text('Error')),
                        );
                      } else if (snapshot.hasData) {
                        final totals = snapshot.data!;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                getBankIcon(bankName),
                                width: 50,
                                height: 50,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                bankName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Credit: ₹${totals['totalCredit']?.toStringAsFixed(2) ?? '0.0'}',
                                style: const TextStyle(fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                'Debit: ₹${totals['totalDebit']?.toStringAsFixed(2) ?? '0.0'}',
                                style: const TextStyle(fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0),
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Center(child: Text('No data')),
                        );
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: Colors.white, // Set the background color to white
              child: ListView.builder(
                itemCount: _filteredTransactions.length,
                itemBuilder: (context, index) {
                  final transaction = _filteredTransactions[index];

                  // Determine the correct bank icon
                  String bankIcon = 'assets/icons/default_bank128.png'; // Default icon
                  if (transaction.bankName.toLowerCase() == 'sbi') {
                    bankIcon = 'assets/icons/sbi128.png';
                  } else if (transaction.bankName.toLowerCase() == 'ippb') {
                    bankIcon = 'assets/icons/ippb128.png';
                  } else if (transaction.bankName.toLowerCase() == 'bank of baroda') {
                    bankIcon = 'assets/icons/bob.png';
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                      ),
                      subtitle: Text(
                        "₹${transaction.amount}", // Add ₹ symbol for currency formatting
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
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "${transaction.date.toString().split(' ')[0]}", // Format the date
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
            ),
          ),
        ],
      ),
    );
  }
}
