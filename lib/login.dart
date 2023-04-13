import 'dart:async';

import 'package:baeng_bao/page/main_admin.dart';
import 'package:baeng_bao/page/main_staff.dart';
import 'package:baeng_bao/widgets/button_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:legacy_progress_dialog/legacy_progress_dialog.dart';
import 'package:baeng_bao/forget_password.dart';
import 'package:baeng_bao/model/user_model.dart';
import 'package:baeng_bao/page/main_user.dart';
import 'package:baeng_bao/register.dart';
import 'package:baeng_bao/utility/my_constant.dart';
import 'package:baeng_bao/utils.dart';
import 'package:baeng_bao/widgets/Show_title.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final formKey = GlobalKey<FormState>();
  bool statusRadEye = true;
  final idCardController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    idCardController.text = '';
    passwordController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 15),
            buildImage(size),
            const SizedBox(height: 15),
            buildAppName(),
            buildIdCard(size),
            buildPassword(size),
            buildLogin(size),
            const SizedBox(height: 10),
            buildCreateAccount(size),
          ],
        ),
      )),
    );
  }

  Widget buildAppName() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShowTitle(
            title: "ลงชื่อเข้าสู่ระบบ",
            textStyle: TextStyle(
              fontSize: 20,
              color: MyConstant.dark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );

  Widget buildImage(double size) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
              width: size * 0.4,
              child: Image.asset(MyConstant.image1),
            ),
          
        ],
      );

  // buildForgetPassword() => Container(
  //       margin: const EdgeInsets.fromLTRB(0, 10, 20, 0),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.end,
  //         children: [
  //           GestureDetector(
  //               onTap: () => Navigator.push(
  //                     context,
  //                     MaterialPageRoute(builder: (context) => ForgetPassword()),
  //                   ),
  //               child: const Text(
  //                 "Forget Password",
  //                 style: TextStyle(color: Colors.blue),
  //               ))
  //         ],
  //       ),
  //     );

  Widget buildCreateAccount(double size) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShowTitle(
            title: 'ยังไม่มีบัญชีใช่หรือไม่ ?',
            textStyle: MyConstant().h3Style(),
          ),
          const SizedBox(
            width: 10,
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterPage()),
            ),
            child: const Text(
              'สร้างบัญชี',
              style: TextStyle(fontSize: 16, color: Color(0xff57b79b)),
            ),
          ),
        ],
      );

  Row buildIdCard(double size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 20),
          width: size * 0.9,
          child: TextFormField(
            keyboardType: TextInputType.emailAddress,
            controller: idCardController,
            decoration: InputDecoration(
              labelStyle: MyConstant().h3Style(),
              labelText: 'เลขประจำตัวประชาชน',
              prefixIcon: Icon(
                Icons.account_circle,
                color: MyConstant.dark,
              ),
              suffixIcon: idCardController.text.isEmpty
                  ? Container(width: 0)
                  : IconButton(
                      icon: const Icon(Icons.close),
                      color: MyConstant.dark,
                      onPressed: () => idCardController.clear(),
                    ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: MyConstant.dark),
                borderRadius: BorderRadius.circular(15),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: MyConstant.light),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Row buildPassword(double size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 10),
          width: size * 0.9,
          child: TextFormField(
            validator: RequiredValidator(errorText: "กรุณากรอก Password"),
            controller: passwordController,
            obscureText: statusRadEye,
            decoration: InputDecoration(
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    statusRadEye = !statusRadEye;
                  });
                },
                icon: statusRadEye
                    ? Icon(
                        Icons.remove_red_eye,
                        color: MyConstant.dark,
                      )
                    : Icon(
                        Icons.visibility_off,
                        color: MyConstant.dark,
                      ),
              ),
              labelStyle: MyConstant().h3Style(),
              labelText: 'รหัสผ่าน',
              prefixIcon: Icon(Icons.lock_outline, color: MyConstant.dark),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: MyConstant.dark),
                borderRadius: BorderRadius.circular(15),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: MyConstant.light),
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildLogin(double size) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              margin: const EdgeInsets.only(top: 10),
              width: size * 0.9,
              child: ButtonWidget(
                color: MyConstant.buttonColor,
                textColor: Colors.black,
                onPressed: () => login(),
                title: 'เข้าสู่ระบบ',
              )

              // ElevatedButton(
              //   style: MyConstant().myButtonStyle(),
              //   onPressed: () => login(),
              //   child: const Text(
              //     'เข้าสู่ระบบ',
              //     style: TextStyle(color: Colors.black),
              //   ),
              // ),
              ),
        ],
      );

  login() async {
    FocusScope.of(context).unfocus();
    final idCard = idCardController.text.trim();
    final password = passwordController.text.trim();

    if (idCard.isEmpty) {
      Utils.showToast(context, 'กรุณาใส่เลขบัตรประชาชนก่อน', Colors.red);
      return;
    }

    if (idCard.length != 13) {
      Utils.showToast(context, 'เลขบัตรประชาชนต้องมี 13 หลัก', Colors.red);
      return;
    }

    if (password.isEmpty) {
      Utils.showToast(context, 'กรุณาใส่รหัสก่อน', Colors.red);
      return;
    }

    if (password.length < 5) {
      Utils.showToast(context, 'รหัสผ่านต้องมีอย่างน้อย 6 ตัว', Colors.red);
      return;
    }

    ProgressDialog pd = ProgressDialog(
      loadingText: 'กรุณารอสักครู่...',
      context: context,
      backgroundColor: Colors.white,
      textColor: Colors.black,
    );
    pd.show();

    final ref = await FirebaseFirestore.instance
        .collection('user')
        .where('id_card', isEqualTo: idCard)
        .where('password', isEqualTo: password)
        .get();

    if (ref.size == 0) {
      Utils.showToast(context, "ข้อมูลไม่ถูกต้องกรุณาลองใหม่", Colors.red);
      pd.dismiss();
      return;
    }

    await FirebaseFirestore.instance
        .collection('user')
        .where('id_card', isEqualTo: idCard)
        .where('password', isEqualTo: password)
        .limit(1)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((result) async {
        var address = result.data()['address'];
        var birthday = result.data()['birthday'];
        var email = result.data()['email'];
        var firstname = result.data()['firstname'];
        var id_card = result.data()['id_card'];
        var lastname = result.data()['lastname'];
        var password = result.data()['password'];
        var photo = result.data()['photo'];
        var photo_house = result.data()['photo_house'];
        var photo_id_card = result.data()['photo_id_card'];
        var status = result.data()['status'];
        var tel = result.data()['tel'];
        var type = result.data()['type'];
        var userId = result.data()['user_id'];

        print(birthday);

        final prefs = await SharedPreferences.getInstance();
        prefs.setBool("check", true);
        prefs.setString('address', address);
        prefs.setString('birthday', birthday);
        prefs.setString('email', email);
        prefs.setString('firstname', firstname);
        prefs.setString('id_card', id_card);
        prefs.setString('lastname', lastname);
        prefs.setString('password', password);
        prefs.setString('photo', photo);
        prefs.setString('photo_house', photo_house);
        prefs.setString('photo_id_card', photo_id_card);
        prefs.setString('status', status);
        prefs.setString('tel', tel);
        prefs.setString('type', type);
        prefs.setString('user_id', userId);

        final my_account = UserModel(
          address: address,
          email: email,
          password: password,
          photo: photo,
          photo_house: photo_house,
          photo_id_card: photo_id_card,
          status: status,
          user_id: userId,
          firstname: firstname,
          lastname: lastname,
          token: '',
          birthday: birthday,
          id_card: id_card,
          tel: tel,
          type: type,
        );

        print(type);

        if (type == "แอดมิน") {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    MainAdmin(from: 'login', my_account: my_account)),
            (Route<dynamic> route) => false,
          );
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
      });
    });

    pd.dismiss();
    // }
    // } on FirebaseAuthException catch (e) {
    //   pd.dismiss();
    //   if (e.code == 'user-not-found') {
    //     pd.dismiss();
    //     Utils.showToast(
    //         context, 'ไม่มีข้อมูลบัญชีนี้ กรุณาลองใหม่', Colors.red);
    //   } else if (e.code == 'wrong-password') {
    //     pd.dismiss();
    //     Utils.showToast(context, 'รหัสผ่านไม่ถูกต้อง กรุณาลองใหม่', Colors.red);
    //   } else {
    //     pd.dismiss();
    //     Utils.showToast(context, 'เกิดข้อผิดพลาด กรุณาลองใหม่', Colors.red);
    //   }
    // }
  }
}
