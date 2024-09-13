import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/database/db_helper.dart';
import 'package:expense_tracker/models/transaction_model.dart';

class PieChartSample2 extends StatefulWidget {
  const PieChartSample2({super.key});

  @override
  State<StatefulWidget> createState() => PieChart2State();
}

class PieChart2State extends State<PieChartSample2> {
  double creditTotal = 0;
  double debitTotal = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final dbHelper = DbHelper();

    // Get the current month
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    // Fetch credit and debit transactions for the current month
    final credits = await dbHelper.getCredits();
    final debits = await dbHelper.getDebits();

    print('Fetched ${credits.length} credit transactions.');
    print('Fetched ${debits.length} debit transactions.');

    setState(() {
      creditTotal = credits
          .where((t) {
        final date = DateTime.parse(t.date);
        return date.isAfter(startOfMonth) && date.isBefore(endOfMonth);
      })
          .fold(0.0, (sum, t) => sum + t.amount);

      debitTotal = debits
          .where((t) {
        final date = DateTime.parse(t.date);
        return date.isAfter(startOfMonth) && date.isBefore(endOfMonth);
      })
          .fold(0.0, (sum, t) => sum + t.amount);

      print('Credit Total: $creditTotal');
      print('Debit Total: $debitTotal');
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = creditTotal + debitTotal;

    return Scaffold(
      appBar: AppBar(
        title: Text('Pie Chart Comparison'),
      ),
      body: Center(
        child: creditTotal == 0 && debitTotal == 0
            ? const CircularProgressIndicator()
            : totalAmount == 0
            ? const Text('No data available for the selected month.')
            : PieChart(
          PieChartData(
            sections: [
              PieChartSectionData(
                value: creditTotal,
                title: '${(creditTotal / totalAmount * 100).toStringAsFixed(1)}%',
                color: Colors.blue,
                radius: 50,
                titleStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              PieChartSectionData(
                value: debitTotal,
                title: '${(debitTotal / totalAmount * 100).toStringAsFixed(1)}%',
                color: Colors.red,
                radius: 50,
                titleStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
            borderData: FlBorderData(show: false),
            sectionsSpace: 0,
            centerSpaceRadius: 40,
          ),
        ),
      ),
    );
  }
}
