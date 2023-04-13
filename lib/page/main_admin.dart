import 'dart:async';
import 'dart:io';

//import 'package:firebase_auth/firebase_auth.dart';
import 'package:baeng_bao/page/category/category_add.dart';
import 'package:baeng_bao/page/order/order_list.dart';
import 'package:baeng_bao/page/staff/staff_add.dart';
import 'package:baeng_bao/page/staff/staff_list.dart';
import 'package:baeng_bao/utility/my_constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:baeng_bao/constants/firestore_constants.dart';

import 'package:baeng_bao/model/user_model.dart';
import 'package:baeng_bao/providers/home_provider.dart';
import 'package:baeng_bao/page/history_borrow.dart';
import 'package:baeng_bao/login.dart';
import 'package:baeng_bao/page/item/item_add.dart';
import 'package:baeng_bao/page/order/order_list_staff.dart';
import 'package:baeng_bao/page/tab/home_page_staff.dart';
import 'package:baeng_bao/page/tab/user_page.dart';
import 'package:baeng_bao/utils.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title

    importance: Importance.high,
    playSound: true);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  //print('A bg message just showed up :  ${message.messageId}');
}

class MainAdmin extends StatefulWidget {
  UserModel my_account;
  String from;
  MainAdmin({Key? key, required this.from, required this.my_account})
      : super(key: key);
  @override
  _MainAdmin createState() => _MainAdmin();
}

class _MainAdmin extends State<MainAdmin> {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final ScrollController listScrollController = ScrollController();

  int selectedIndex = 0;
  SharedPreferences? prefs;
  String? name = '', imagePath = '', intent_from;

  @override
  initState() {
    super.initState();

    intent_from = widget.from;
    if (intent_from == 'edit_user') {
      selectedIndex = 2;
    } else if (intent_from == 'chat') {
      selectedIndex = 1;
    } else {
      selectedIndex = 0;
    }
  }

  Future<bool> Logout() async {
    return (await logoutMethod(context)) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      StaffList(my_account: widget.my_account),
      OrderList(my_account: widget.my_account),
      HistoryPage(my_account: widget.my_account),
      UserPage(my_account: widget.my_account),
    ];
    return WillPopScope(
        onWillPop: Logout,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: MyConstant.primary,
            title: Text(
              setName(selectedIndex),
              style: const TextStyle(color: Colors.white),
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.logout,
                ),
                onPressed: () => widget.my_account.user_id == ""
                    ? Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => const Login(),
                        ))
                    : logoutMethod(context),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xff57b79b), Color(0xff57b79b)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: BottomNavigationBar(
              unselectedItemColor: Colors.white.withOpacity(0.7),
              selectedItemColor: Colors.white,
              backgroundColor: Colors.transparent,
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              currentIndex: selectedIndex,
              onTap: (index) => setState(() {
                selectedIndex = index;
              }),
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'หน้าหลัก',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.assignment),
                  label: 'ยืมคืน',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history),
                  label: 'ประวัติ',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.manage_accounts),
                  label: 'บัญชี',
                ),
              ],
            ),
          ),
          body: selectedIndex == 0
              ? SafeArea(
                  child: tabs[selectedIndex],
                )
              : Container(
                  child: tabs[selectedIndex],
                ),
          floatingActionButton: widget.my_account.user_id == ""
              ? Container()
              : setFloatingButton(selectedIndex),
        ));
  }

  setFloatingButton(int selectedIndex) {
    if (selectedIndex == 0) {
      return FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        backgroundColor: Colors.black,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => StaffAdd(my_account: widget.my_account)),
        ),
        child: const Icon(Icons.add),
      );
    } else {
      return Container();
    }
  }

  logoutMethod(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('⭐ แจ้งเตือน'),
          content: const Text("คุณต้องการออกจากระบบ ใช่หรือไม่?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('ไม่ใช่'),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.clear();

                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) => Login(),
                    ),
                    (route) => false);
              },
              child: const Text('ใช่'),
            ),
          ],
        );
      },
    );
  }
}

String setName(int selectedIndex) {
  if (selectedIndex == 0) {
    return 'หน้าหลัก';
  } else if (selectedIndex == 1) {
    return 'ยืมคืน';
  } else if (selectedIndex == 2) {
    return 'ประวัติ';
  } else {
    return 'บัญชี';
  }
}
