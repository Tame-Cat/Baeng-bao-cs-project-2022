import 'package:baeng_bao/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:legacy_progress_dialog/legacy_progress_dialog.dart';

class ZZ extends StatefulWidget {
  const ZZ({Key? key}) : super(key: key);

  @override
  State<ZZ> createState() => _ZZ();
}

class _ZZ extends State<ZZ> {
  final testController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          title: const Text('ZZ'),
        ),
        body: SafeArea(
            child: ElevatedButton(
                onPressed: () => popUpConfrimPassword(context),
                child: const Text("test"))));
  }

  void popUpConfrimPassword(BuildContext context) => showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('⭐ กรุณาใส่รหัสผ่าน'),
            content: TextFormField(
              maxLines: 1,
              controller: testController,
              decoration: const InputDecoration(
                hintText: 'ยืนยันรหัสผ่าน',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                  Utils.showToast(context, testController.text, Colors.green);
                },
                child: const Text('ตกลง'),
              ),
            ],
          );
        },
      );
}
