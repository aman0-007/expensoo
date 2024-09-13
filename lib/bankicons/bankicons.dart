import 'package:flutter/material.dart';

String getBankIcon(String bankName) {
  switch (bankName.toLowerCase()) {
    case 'sbi':
      return 'assets/icons/sbi128.png';
    case 'ippb':
      return 'assets/icons/ippb128.png';
    case 'bank of baroda':
      return 'assets/icons/bob.png';
    default:
      return 'assets/icons/default_bank128.png';
  }
}

Future<double?> showAmountInputDialog(BuildContext context) async {
  TextEditingController controller = TextEditingController();
  return await showDialog<double>(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        backgroundColor: Colors.white,
        title: const Text(
          'Enter Amount',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
            color: Colors.black87,
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 16.0, color: Colors.black87),
          decoration: InputDecoration(
            hintText: 'Enter amount',
            hintStyle: const TextStyle(color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            filled: true,
            fillColor: Colors.grey[100],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(double.tryParse(controller.text)),
            child: const Text(
              'OK',
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );
}

Future<List<double>?> showAmountRangeDialog(BuildContext context) async {
  TextEditingController minController = TextEditingController();
  TextEditingController maxController = TextEditingController();
  return await showDialog<List<double>>(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        backgroundColor: Colors.white,
        title: const Text(
          'Enter Amount Range',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
            color: Colors.black87,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: minController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 16.0, color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'Min amount',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: maxController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 16.0, color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'Max amount',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              double? min = double.tryParse(minController.text);
              double? max = double.tryParse(maxController.text);
              if (min != null && max != null) {
                Navigator.of(context).pop([min, max]);
              } else {
                Navigator.of(context).pop(null);
              }
            },
            child: const Text(
              'OK',
              style: TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );
}
