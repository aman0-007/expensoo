import 'package:expense_tracker/database/db_helper.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting the date

class WeeklyTransactionChart extends StatefulWidget {
  final dbHelper = DbHelper();

  WeeklyTransactionChart({Key? key}) : super(key: key);

  @override
  _WeeklyTransactionChartState createState() => _WeeklyTransactionChartState();
}

class _WeeklyTransactionChartState extends State<WeeklyTransactionChart> {
  int? touchedIndex; // Index of the bar touched

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Transactions')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: widget.dbHelper.getCurrentWeekDailyTotals(), // Fetch data directly here
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Show loading spinner
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // Handle errors
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No Data Available')); // Handle empty data
          } else {
            return _buildChart(snapshot.data!); // Build the chart with data
          }
        },
      ),
    );
  }

  // Build the bar chart widget with custom height and appearance
  Widget _buildChart(List<Map<String, dynamic>> data) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: IntrinsicHeight(
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 8,
                offset: const Offset(0, 4), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Weekly Transactions',
                  style: TextStyle(
                    fontSize: 20, // Adjust font size as needed
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              SizedBox(
                height: 300, // Adjusted height for better visibility
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceEvenly,
                    maxY: _getMaxY(data),
                    barGroups: _buildBarGroups(data),
                    borderData: FlBorderData(
                      show: false, // Remove border lines
                    ),
                    gridData: FlGridData(
                      show: false, // Hide grid lines
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()}',
                              style: const TextStyle(fontSize: 14, color: Colors.black),
                            );
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false, // Hide right side titles
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 60,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            final day = DateFormat('EEE').format(DateTime.now().subtract(Duration(days: 6 - index)));
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              child: Text(day, style: const TextStyle(fontSize: 12, color: Colors.black)),
                            );
                          },
                        ),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false, // Hide top titles
                        ),
                      ),
                    ),
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        tooltipPadding: const EdgeInsets.all(8), // Customize padding if needed
                        tooltipMargin: 8, // Customize margin if needed
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          if (groupIndex >= data.length) return null; // Avoid index out of range

                          String day = DateFormat('EEE').format(DateTime.now().subtract(Duration(days: 6 - groupIndex)));
                          double totalCredit = (data[groupIndex]['totalCredit'] ?? 0.0) as double; // Safe cast to double
                          double totalDebit = (data[groupIndex]['totalDebit'] ?? 0.0) as double; // Safe cast to double
                          return BarTooltipItem(
                            '$day\nTotal Credit: \$${totalCredit.toStringAsFixed(2)}\nTotal Debit: \$${totalDebit.toStringAsFixed(2)}',
                            const TextStyle(color: Colors.white),
                          );
                        },
                      ),
                      touchCallback: (FlTouchEvent event, barTouchResponse) {
                        if (event is FlTapUpEvent && barTouchResponse != null && barTouchResponse.spot != null) {
                          final index = barTouchResponse.spot!.touchedBarGroupIndex;
                          if (index >= data.length) return; // Avoid index out of range

                          final date = DateTime.now().subtract(Duration(days: 6 - index));
                          final totalCredit = (data[index]['totalCredit'] ?? 0.0) as double; // Safe cast to double
                          final totalDebit = (data[index]['totalDebit'] ?? 0.0) as double; // Safe cast to double
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Details for ${DateFormat('EEE').format(date)}'),
                              content: Text(
                                'Total Credit: \$${totalCredit.toStringAsFixed(2)}\n'
                                    'Total Debit: \$${totalDebit.toStringAsFixed(2)}',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build the bar groups for the chart
  List<BarChartGroupData> _buildBarGroups(List<Map<String, dynamic>> data) {
    // Create a map with default values for each day of the week
    Map<int, Map<String, dynamic>> weeklyData = {};
    for (int i = 0; i < 7; i++) {
      final day = DateTime.now().subtract(Duration(days: 6 - i));
      final dayStr = DateFormat('yyyy-MM-dd').format(day);
      weeklyData[i] = {'date': dayStr, 'totalCredit': 0.0, 'totalDebit': 0.0};
    }

    // Fill in the actual data
    for (var entry in data) {
      final date = DateTime.parse(entry['date']);
      final index = DateTime.now().difference(date).inDays;
      if (index >= 0 && index < 7) {
        weeklyData[6 - index] = {
          'date': entry['date'],
          'totalCredit': (entry['totalCredit'] ?? 0.0) as double,
          'totalDebit': (entry['totalDebit'] ?? 0.0) as double,
        };
      }
    }

    return List.generate(7, (index) {
      final dayData = weeklyData[index]!;
      final totalCredit = dayData['totalCredit'] as double;
      final totalDebit = dayData['totalDebit'] as double;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: totalCredit,
            width: 14,
            color: touchedIndex == index ? Colors.lightGreen : Colors.green, // Highlight on touch
            borderRadius: BorderRadius.circular(4),
          ),
          BarChartRodData(
            toY: totalDebit,
            width: 14,
            color: touchedIndex == index ? Colors.redAccent : Colors.red, // Highlight on touch
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }

  // Get the maximum Y value for scaling the chart
  double _getMaxY(List<Map<String, dynamic>> data) {
    double maxY = 0.0;
    for (var entry in data) {
      final totalCredit = (entry['totalCredit'] ?? 0.0) as double; // Safe cast to double
      final totalDebit = (entry['totalDebit'] ?? 0.0) as double; // Safe cast to double
      maxY = maxY < totalCredit ? totalCredit : maxY;
      maxY = maxY < totalDebit ? totalDebit : maxY;
    }
    return maxY + 500; // Add buffer space for scaling
  }
}

void main() {
  runApp(MaterialApp(home: WeeklyTransactionChart()));
}
