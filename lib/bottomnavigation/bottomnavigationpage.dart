import 'package:expense_tracker/database/db_helper.dart';
import 'package:expense_tracker/models/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:molten_navigationbar_flutter/molten_navigationbar_flutter.dart';
import 'package:expense_tracker/screens/alltransaction.dart';
import 'package:expense_tracker/screens/mainscreen.dart';

class FloatingBottomBarPage extends StatefulWidget {
  @override
  _FloatingBottomBarPageState createState() => _FloatingBottomBarPageState();
}

class _FloatingBottomBarPageState extends State<FloatingBottomBarPage> {
  int _selectedIndex = 0;

  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          MainScreen(), // Home Page
          const AllTransactionsPage(), // All Transactions Page
          const Center(child: Text('Plus Icon Page')), // Center page with plus icon
          ChartsScreen(), // Charts and Representation Page
          ProfileScreen(), // Profile Page
        ],
      ),
      bottomNavigationBar: MoltenBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onTabChange: _onTabChange,
        barHeight: 60.0,
        domeHeight: 15.0,
        domeWidth: 100.0,
        domeCircleColor: Colors.blue,
        domeCircleSize: 40.0,
        margin: const EdgeInsets.all(8.0),
        barColor: Colors.white, // Set background color to white
        tabs: [
          MoltenTab(
            icon: Icon(Icons.home, color: _selectedIndex == 0 ? Colors.white : Colors.blue), // Non-selected icon color blue
            selectedColor: Colors.white,
            unselectedColor: Colors.blue,
          ),
          MoltenTab(
            icon: Icon(Icons.list, color: _selectedIndex == 1 ? Colors.white : Colors.blue), // Non-selected icon color blue
            selectedColor: Colors.white,
            unselectedColor: Colors.blue,
          ),
          MoltenTab(
            icon: const Icon(Icons.add, color: Colors.white), // Plus icon is always white
            selectedColor: Colors.white,
            unselectedColor: Colors.blue, // This property is not used here as this tab is always selected
          ),
          MoltenTab(
            icon: Icon(Icons.show_chart, color: _selectedIndex == 3 ? Colors.white : Colors.blue), // Non-selected icon color blue
            selectedColor: Colors.white,
            unselectedColor: Colors.blue,
          ),
          MoltenTab(
            icon: Icon(Icons.person, color: _selectedIndex == 4 ? Colors.white : Colors.blue), // Non-selected icon color blue
            selectedColor: Colors.white,
            unselectedColor: Colors.blue,
          ),
        ],
      ),
    );
  }
}

class ChartsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Charts and Representation Page'));
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Profile Page'));
  }
}