import 'package:expense_tracker/ads/admanager.dart';
import 'package:expense_tracker/bottomnavigation/bottomnavigationpage.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:expense_tracker/screens/onboardscreen.dart';
import 'package:expense_tracker/database/db_helper.dart';
import 'package:expense_tracker/sharedpref/sharedpreferencehelper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DbHelper().database;
  MobileAds.instance.initialize();
  AdManager.loadRewardedAd(); // Load ad at app start
  final SharedPrefHelper sharedPrefHelper = SharedPrefHelper();
  bool loggedIn = await sharedPrefHelper.isLoggedIn();

  runApp(MyApp(loggedIn: loggedIn));
}

class MyApp extends StatelessWidget {
  final bool loggedIn;

  const MyApp({super.key, required this.loggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: loggedIn ? FloatingBottomBarPage() : const OnboardingScreen(),
    );
  }
}
