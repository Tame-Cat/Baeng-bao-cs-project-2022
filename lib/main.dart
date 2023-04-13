import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:baeng_bao/constants/color_constants.dart';
import 'package:baeng_bao/page/main_admin.dart';
import 'package:baeng_bao/page/main_staff.dart';
import 'package:baeng_bao/page/staff/staff_list.dart';
import 'package:baeng_bao/zz.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:baeng_bao/check_internet.dart';
import 'package:baeng_bao/model/user_model.dart';
import 'package:baeng_bao/providers/chat_provider.dart';
import 'package:baeng_bao/providers/home_provider.dart';
import 'package:baeng_bao/page/main_user.dart';
import 'package:baeng_bao/login.dart';
import 'package:baeng_bao/utility/my_constant.dart';
import 'package:baeng_bao/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(MyApp(prefs: prefs));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  MyApp({Key? key, required this.prefs}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          Provider<HomeProvider>(
            create: (_) => HomeProvider(
              firebaseFirestore: this.firebaseFirestore,
            ),
          ),
          Provider<ChatProvider>(
            create: (_) => ChatProvider(
              prefs: this.prefs,
              firebaseFirestore: this.firebaseFirestore,
              firebaseStorage: this.firebaseStorage,
            ),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: MyConstant.dark,
            fontFamily: 'Kanit',
          ),
          title: MyConstant.appName,
          home: const SplashScreen(),
        ));
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SplashScreen();
}

class _SplashScreen extends State<SplashScreen> {
  @override
  initState() {
    super.initState();
    checkNet();
  }

  checkNet() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        print('connected');
        load();
      }
    } on SocketException catch (_) {
      print('not connected');
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) => const CheckInternet(),
          ),
          (route) => false);
    }
  }

  load() async {
    final prefs = await SharedPreferences.getInstance();
    var check = prefs.getBool('check') ?? false;
    var type = prefs.getString('type') ?? '';
    var email = prefs.getString('email') ?? '';
    var firstname = prefs.getString('firstname') ?? '';
    var lastname = prefs.getString('lastname') ?? '';
    var address = prefs.getString('address') ?? '';
    var brithday = prefs.getString('birthday') ?? '';
    var id_card = prefs.getString('id_card') ?? '0';
    var password = prefs.getString('password') ?? '';
    var photo = prefs.getString('photo') ?? '';
    var photo_house = prefs.getString('photo_house') ?? '';
    var photo_id_card = prefs.getString('photo_id_card') ?? '';
    var status = prefs.getString('status') ?? '';
    var tel = prefs.getString('tel') ?? '';
    var token = prefs.getString('token') ?? '';
    var user_id = prefs.getString('user_id') ?? '';

    final my_account = UserModel(
      address: address,
      email: email,
      firstname: firstname,
      lastname: lastname,
      password: password,
      photo: photo,
      photo_house: photo_house,
      photo_id_card: photo_id_card,
      status: status,
      token: token,
      user_id: user_id,
      birthday: brithday,
      id_card: id_card,
      tel: tel,
      type: type,
    );

    if (check) {
      // ignore: use_build_context_synchronously

      if (type == "แอดมิน") {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) =>
                  MainAdmin(my_account: my_account, from: 'login'),
            ),
            (route) => false);
      } else if (type == "เจ้าหน้าที่") {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  MainStaff(from: 'login', my_account: my_account)),
          (Route<dynamic> route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  MainUser(from: 'login', my_account: my_account)),
          (Route<dynamic> route) => false,
        );
      }
    } else {
      Timer(const Duration(seconds: 2), () async {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => const Login(),
            ),
            (route) => false);
      });
    }
  }

  // void dispose() {
  //   _controller.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    // หน้า UI
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // FadeTransition(
            //   opacity: _animation,
            //   child: Image.asset(
            //     'assets/logo.png',
            //     height: 200,
            //   ),
            // )

            Image.asset(
              'assets/logo.png',
              height: 200,
            )
          ],
        ),
      ),
    );
  }
}
