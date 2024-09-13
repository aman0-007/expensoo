// import 'package:expense_tracker/bottomnavigation/bottomnavigationpage.dart';
// import 'package:expense_tracker/sharedpref/sharedpreferencehelper.dart';
// import 'package:flutter/material.dart';
// import 'package:introduction_screen/introduction_screen.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// class OnboardingScreen extends StatelessWidget {
//   const OnboardingScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: IntroductionScreen(
//         pages: [
//           PageViewModel(
//             title: "Welcome to Expense Tracker",
//             body: "Track your expenses, manage your finances, and gain insights with ease.",
//             image: _buildImage('assets/onboard/money.jpeg'),
//             footer: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 30.0),
//               child: ElevatedButton(
//                 onPressed: () async {
//                   PermissionStatus status = await Permission.sms.request();
//
//                   if (status.isGranted) {
//                     final SharedPrefHelper sharedPrefHelper = SharedPrefHelper();
//                     await sharedPrefHelper.setLoggedIn(true);
//
//                     Navigator.of(context).pushReplacement(
//                       MaterialPageRoute(builder: (context) => FloatingBottomBarPage()),
//                     );
//                   } else if (status.isDenied || status.isPermanentlyDenied) {
//                     openAppSettings();
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Theme.of(context).colorScheme.secondary,
//                   padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(30.0),
//                   ),
//                   elevation: 5.0,
//                 ),
//                 child: const Text(
//                   'Allow SMS Access',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontFamily: 'Montserrat',
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//             decoration: _getPageDecoration(),
//           ),
//           // PageViewModel(
//           //   title: "Track Your Expenses",
//           //   body: "Automatically categorize your expenses from SMS, and keep track of your spending.",
//           //   image: _buildImage('assets/onboard/trackdata.jpeg'),
//           //   decoration: _getPageDecoration(),
//           // ),
//           // PageViewModel(
//           //   title: "Visualize with Charts",
//           //   body: "View your spending habits with easy-to-understand charts and graphs.",
//           //   image: _buildImage('assets/onboard/chart.jpeg'),
//           //   decoration: _getPageDecoration(),
//           // ),
//           // PageViewModel(
//           //   title: "Grant Permissions",
//           //   body: "We need access to your SMS to automatically track expenses. Your data remains secure and private.",
//           //   image: _buildImage('assets/onboard/smspermission.jpeg'),
//           //   footer: Padding(
//           //     padding: const EdgeInsets.symmetric(horizontal: 30.0),
//           //     child: ElevatedButton(
//           //       onPressed: () async {
//           //         PermissionStatus status = await Permission.sms.request();
//           //
//           //         if (status.isGranted) {
//           //           final SharedPrefHelper sharedPrefHelper = SharedPrefHelper();
//           //           await sharedPrefHelper.setLoggedIn(true);
//           //
//           //           Navigator.of(context).pushReplacement(
//           //             MaterialPageRoute(builder: (context) => FloatingBottomBarPage()),
//           //           );
//           //         } else if (status.isDenied || status.isPermanentlyDenied) {
//           //           openAppSettings();
//           //         }
//           //       },
//           //       style: ElevatedButton.styleFrom(
//           //         backgroundColor: Theme.of(context).colorScheme.secondary,
//           //         padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
//           //         shape: RoundedRectangleBorder(
//           //           borderRadius: BorderRadius.circular(30.0),
//           //         ),
//           //         elevation: 5.0,
//           //       ),
//           //       child: const Text(
//           //         'Allow SMS Access',
//           //         style: TextStyle(
//           //           color: Colors.white,
//           //           fontFamily: 'Montserrat',
//           //           fontSize: 16,
//           //           fontWeight: FontWeight.bold,
//           //         ),
//           //       ),
//           //     ),
//           //   ),
//           //   decoration: _getPageDecoration(),
//           // ),
//         ],
//         onDone: () async {
//           final SharedPrefHelper sharedPrefHelper = SharedPrefHelper();
//           await sharedPrefHelper.setLoggedIn(true);
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(builder: (context) => FloatingBottomBarPage()),
//           );
//         },
//         // onSkip: () {
//         //   Navigator.of(context).pushReplacementNamed('/home');
//         // },
//         // showSkipButton: true,
//         // skip: const Text("Skip", style: TextStyle(color: Colors.black)),
//         // next: const Icon(Icons.arrow_forward, color: Colors.black),
//         //done: const Text("Start Now", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
//         //dotsDecorator: _getDotsDecorator(context),
//         globalBackgroundColor: Colors.white,
//       ),
//     );
//   }
//
//   Widget _buildImage(String path) {
//     return Padding(
//       padding: const EdgeInsets.all(24.0),
//       child: Image.asset(path),
//     );
//   }
//
//   PageDecoration _getPageDecoration() {
//     return PageDecoration(
//       titleTextStyle: const TextStyle(
//         fontFamily: 'Montserrat',
//         fontSize: 24,
//         fontWeight: FontWeight.bold,
//         color: Colors.black,
//       ),
//       bodyTextStyle: const TextStyle(
//         fontFamily: 'Roboto',
//         fontSize: 16,
//         color: Colors.black,
//       ),
//       imagePadding: EdgeInsets.symmetric(vertical: 40),
//       contentMargin: EdgeInsets.symmetric(horizontal: 16),
//       pageColor: Colors.white,
//     );
//   }
//
//   // DotsDecorator _getDotsDecorator(BuildContext context) {
//   //   return DotsDecorator(
//   //     size: const Size.square(10.0),
//   //     activeSize: const Size(22.0, 10.0),
//   //     activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
//   //     activeColor: Theme.of(context).colorScheme.secondary,
//   //     color: Colors.grey,
//   //   );
//   // }
// }

import 'package:expense_tracker/ads/admanager.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/bottomnavigation/bottomnavigationpage.dart';
import 'package:expense_tracker/sharedpref/sharedpreferencehelper.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:permission_handler/permission_handler.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IntroductionScreen(
        pages: [
          PageViewModel(
            title: "Welcome to Expense Tracker",
            body: "We need access to your SMS to track expenses automatically. Your data will remain secure.",
            image: _buildImage('assets/onboard/smspermission.jpeg'),
            footer: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: ElevatedButton(
                onPressed: () async {
                  PermissionStatus status = await Permission.sms.request();

                  if (status.isGranted) {
                    final SharedPrefHelper sharedPrefHelper = SharedPrefHelper();
                    await sharedPrefHelper.setLoggedIn(true);

                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => FloatingBottomBarPage()),
                    );
                  } else if (status.isDenied || status.isPermanentlyDenied) {
                    openAppSettings();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  elevation: 5.0,
                ),
                child: const Text(
                  'Allow SMS Access',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Montserrat',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            decoration: _getPageDecoration(),
          ),
        ],
        onDone: () async {
          final SharedPrefHelper sharedPrefHelper = SharedPrefHelper();
          await sharedPrefHelper.setLoggedIn(true);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => FloatingBottomBarPage()),
          );
        },
        showNextButton: false,
        showSkipButton: false,
        showDoneButton: false,
        globalBackgroundColor: Colors.white,
      ),
    );
  }

  Widget _buildImage(String path) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Image.asset(path),
    );
  }

  PageDecoration _getPageDecoration() {
    return PageDecoration(
      titleTextStyle: const TextStyle(
        fontFamily: 'Montserrat',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      bodyTextStyle: const TextStyle(
        fontFamily: 'Roboto',
        fontSize: 16,
        color: Colors.black,
      ),
      imagePadding: EdgeInsets.symmetric(vertical: 40),
      contentMargin: EdgeInsets.symmetric(horizontal: 16),
      pageColor: Colors.white,
    );
  }
}
