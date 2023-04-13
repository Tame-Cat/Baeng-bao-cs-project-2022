import 'package:flutter/material.dart';
import 'package:baeng_bao/main.dart';

class CheckInternet extends StatefulWidget {
  const CheckInternet({Key? key}) : super(key: key);

  @override
  _CheckInternet createState() => _CheckInternet();
}

class _CheckInternet extends State<CheckInternet> {
  @override
  Widget build(BuildContext context) {
    // หน้า UI
    return Scaffold(
      appBar: AppBar(
        title: const Text("Page Not Found"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/no-internet.png',
              height: 200,
            ),
            const Text(
              'Please check your internet',
              style: TextStyle(fontSize: 18),
            ),
            ElevatedButton(
                onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => const SplashScreen(),
                    ),
                    (route) => false),
                child: const Text('Reload'))
          ],
        ),
      ),
    );
  }
}
